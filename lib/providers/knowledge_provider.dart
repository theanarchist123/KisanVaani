import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../models/knowledge_models.dart';
import '../services/news_api_service.dart';
import '../services/pdf_downloader_service.dart';

class KnowledgeProvider extends ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  final PdfDownloaderService _pdfDownloader = PdfDownloaderService();
  
  List<OfflinePack> _offlinePacks = [];
  List<Article> _articles = [];
  List<Article> _cachedArticles = [];
  bool _isLoadingArticles = false;
  final bool _isLoadingPacks = false;
  String? _errorMessage;
  final Map<String, double> _downloadProgress = {};

  // Getters
  List<OfflinePack> get offlinePacks => _offlinePacks;
  List<Article> get articles => _articles;
  List<Article> get cachedArticles => _cachedArticles;
  bool get isLoadingArticles => _isLoadingArticles;
  bool get isLoadingPacks => _isLoadingPacks;
  String? get errorMessage => _errorMessage;
  Map<String, double> get downloadProgress => _downloadProgress;

  KnowledgeProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadOfflinePacks();
    await _loadCachedArticles();
    await _loadPredefinedPacks();
    await fetchLatestArticles();
  }

  // Initialize predefined ICAR PDF packs
  Future<void> _loadPredefinedPacks() async {
    final predefinedPacks = [
      OfflinePack(
        id: 'icar_kharif_2025',
        title: 'ICAR खरीफ कृषि सलाह 2025',
        description: 'Complete farming guidance for Kharif season crops including rice, cotton, sugarcane, and pulses.',
        pdfUrl: 'https://icar.org.in/sites/default/files/Circulars/ICAR-En-Kharif-Agro-Advisories-for-Farmers-2025.pdf',
        fileName: 'icar_kharif_advisories_2025.pdf',
        sizeBytes: 2560000, // ~2.5MB
        category: 'Seasonal Advisories',
        publishedDate: DateTime(2025, 3, 15),
      ),
      OfflinePack(
        id: 'traditional_knowledge_hindi',
        title: 'कृषि में पारंपरिक ज्ञान',
        description: 'Traditional agricultural knowledge and practices documented by ICAR in Hindi.',
        pdfUrl: 'https://icar.org.in/sites/default/files/2022-06/IITKA_Book_krishi-me-paramparik-gyan-Hindi-1.pdf',
        fileName: 'traditional_knowledge_hindi.pdf',
        sizeBytes: 3840000, // ~3.8MB
        category: 'Traditional Knowledge',
        publishedDate: DateTime(2022, 6, 1),
      ),
      OfflinePack(
        id: 'geographical_indications',
        title: 'कृषि में भौगोलिक संकेत',
        description: 'Plant species with geographical indications and traditional knowledge in agriculture.',
        pdfUrl: 'https://icar.org.in/sites/default/files/2022-06/Geographical-Indications-of-Plant-Species-in-ITKs-in-Agriculture.pdf',
        fileName: 'geographical_indications_agriculture.pdf',
        sizeBytes: 1920000, // ~1.9MB
        category: 'Research Papers',
        publishedDate: DateTime(2022, 6, 1),
      ),
      OfflinePack(
        id: 'naas_bulletin_dec_2024',
        title: 'NAAS बुलेटिन दिसंबर 2024',
        description: 'Latest research bulletin from National Academy of Agricultural Sciences with cutting-edge findings.',
        pdfUrl: 'https://www.icar-crida.res.in/WDU/Dec_2024/NAAS%20Bulletin-30-December-2024.pdf',
        fileName: 'naas_bulletin_dec_2024.pdf',
        sizeBytes: 2048000, // ~2MB
        category: 'Research Bulletins',
        publishedDate: DateTime(2024, 12, 30),
      ),
      OfflinePack(
        id: 'indigenous_knowledge_inventory',
        title: 'स्वदेशी तकनीकी ज्ञान सूची',
        description: 'Comprehensive inventory of indigenous technical knowledge in agriculture practices.',
        pdfUrl: 'https://icar.org.in/sites/default/files/2022-06/Inventory-of-Indigenous-technical-Knowledge-in-Agriculture-Document-2.2.pdf',
        fileName: 'indigenous_knowledge_inventory.pdf',
        sizeBytes: 4096000, // ~4MB
        category: 'Traditional Knowledge',
        publishedDate: DateTime(2022, 6, 1),
      ),
    ];

    // Load existing packs from storage
    await _loadOfflinePacks();
    
    // Add predefined packs if they don't exist
    for (final pack in predefinedPacks) {
      if (!_offlinePacks.any((p) => p.id == pack.id)) {
        _offlinePacks.add(pack);
      }
    }
    
    await _saveOfflinePacks();
    notifyListeners();
  }

  // Offline Packs Management
  Future<void> _loadOfflinePacks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final packsJson = prefs.getString('offline_packs');
      if (packsJson != null) {
        final List<dynamic> packsList = json.decode(packsJson);
        _offlinePacks = packsList.map((pack) => OfflinePack.fromJson(pack)).toList();
      }
    } catch (e) {
      debugPrint('Error loading offline packs: $e');
    }
  }

  Future<void> _saveOfflinePacks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final packsJson = json.encode(_offlinePacks.map((pack) => pack.toJson()).toList());
      await prefs.setString('offline_packs', packsJson);
    } catch (e) {
      debugPrint('Error saving offline packs: $e');
    }
  }

  Future<void> downloadPack(String packId) async {
    final packIndex = _offlinePacks.indexWhere((pack) => pack.id == packId);
    if (packIndex == -1) return;

    final pack = _offlinePacks[packIndex];
    if (pack.isDownloaded || pack.isDownloading) return;

    // Update status to downloading
    _offlinePacks[packIndex].status = OfflinePackStatus.downloading;
    _offlinePacks[packIndex].downloadProgress = 0.0;
    notifyListeners();

    try {
      final localPath = await _pdfDownloader.downloadPdf(
        pack.pdfUrl,
        pack.fileName,
        onProgress: (progress) {
          _offlinePacks[packIndex].downloadProgress = progress;
          _downloadProgress[pack.id] = progress;
          notifyListeners();
        },
      );

      // Update pack with local path
      _offlinePacks[packIndex].status = OfflinePackStatus.downloaded;
      _offlinePacks[packIndex].localPath = localPath;
      _offlinePacks[packIndex].downloadedAt = DateTime.now();
      _offlinePacks[packIndex].downloadProgress = 1.0;
      _downloadProgress.remove(pack.id);

      await _saveOfflinePacks();
      notifyListeners();
    } catch (e) {
      debugPrint('Error downloading pack: $e');
      _offlinePacks[packIndex].status = OfflinePackStatus.error;
      _offlinePacks[packIndex].downloadProgress = 0.0;
      _downloadProgress.remove(pack.id);
      _errorMessage = 'Failed to download: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deletePack(String packId) async {
    final packIndex = _offlinePacks.indexWhere((pack) => pack.id == packId);
    if (packIndex == -1) return;

    final pack = _offlinePacks[packIndex];
    if (pack.localPath != null && await File(pack.localPath!).exists()) {
      await File(pack.localPath!).delete();
    }

    _offlinePacks[packIndex].status = OfflinePackStatus.notDownloaded;
    _offlinePacks[packIndex].localPath = null;
    _offlinePacks[packIndex].downloadedAt = null;
    _offlinePacks[packIndex].downloadProgress = 0.0;

    await _saveOfflinePacks();
    notifyListeners();
  }

  Future<String?> getPackLocalPath(String packId) async {
    final pack = _offlinePacks.firstWhere((pack) => pack.id == packId);
    if (pack.isDownloaded && pack.localPath != null) {
      final file = File(pack.localPath!);
      if (await file.exists()) {
        return pack.localPath;
      }
    }
    return null;
  }

  // Articles Management
  Future<void> fetchLatestArticles() async {
    _isLoadingArticles = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newArticles = await _newsApiService.fetchAgricultureNews();
      _articles = newArticles;
      
      // Cache the latest 10 articles
      await _cacheLatestArticles();
      
      _isLoadingArticles = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching articles: $e');
      _errorMessage = 'Failed to fetch latest articles: ${e.toString()}';
      _isLoadingArticles = false;
      
      // Load cached articles as fallback
      if (_cachedArticles.isNotEmpty) {
        _articles = _cachedArticles;
      }
      notifyListeners();
    }
  }

  Future<void> _cacheLatestArticles() async {
    try {
      final articlesToCache = _articles.take(10).toList();
      final prefs = await SharedPreferences.getInstance();
      final articlesJson = json.encode(articlesToCache.map((article) => article.toJson()).toList());
      await prefs.setString('cached_articles', articlesJson);
    } catch (e) {
      debugPrint('Error caching articles: $e');
    }
  }

  Future<void> _loadCachedArticles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final articlesJson = prefs.getString('cached_articles');
      if (articlesJson != null) {
        final List<dynamic> articlesList = json.decode(articlesJson);
        _cachedArticles = articlesList.map((article) => Article.fromJson(article)).toList();
      }
    } catch (e) {
      debugPrint('Error loading cached articles: $e');
    }
  }

  Future<void> toggleBookmark(String articleId) async {
    final articleIndex = _articles.indexWhere((article) => article.id == articleId);
    if (articleIndex != -1) {
      _articles[articleIndex].isBookmarked = !_articles[articleIndex].isBookmarked;
      notifyListeners();
      // Save bookmarks to preferences
      await _saveBookmarks();
    }
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedIds = _articles
          .where((article) => article.isBookmarked)
          .map((article) => article.id)
          .toList();
      await prefs.setStringList('bookmarked_articles', bookmarkedIds);
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
    }
  }

  Future<void> refreshArticles() async {
    await fetchLatestArticles();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchLatestArticles(),
      _initializeData(),
    ]);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
