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

  // Get categorized resources
  List<KnowledgeCategory> getKnowledgeCategories() {
    final categories = [
      KnowledgeCategory(
        id: 'crop_science',
        title: 'Crop Science',
        emoji: '🌱',
        description: 'Crop cultivation, varieties, and farming techniques',
        resources: _offlinePacks.where((pack) => pack.category == 'Crop Science').toList(),
        supportedLanguages: ['en', 'hi', 'gu', 'ta'],
      ),
      KnowledgeCategory(
        id: 'farm_equipment',
        title: 'Farm Equipment',
        emoji: '🚜',
        description: 'Agricultural machinery and tools',
        resources: _offlinePacks.where((pack) => pack.category == 'Farm Equipment').toList(),
        supportedLanguages: ['en', 'hi', 'gu', 'ta'],
      ),
      KnowledgeCategory(
        id: 'pest_management',
        title: 'Pest Management',
        emoji: '🐛',
        description: 'Pest control and plant protection',
        resources: _offlinePacks.where((pack) => pack.category == 'Pest Management').toList(),
        supportedLanguages: ['en', 'hi', 'gu', 'ta'],
      ),
      KnowledgeCategory(
        id: 'irrigation',
        title: 'Irrigation',
        emoji: '💧',
        description: 'Water management and irrigation systems',
        resources: _offlinePacks.where((pack) => pack.category == 'Irrigation').toList(),
        supportedLanguages: ['en', 'hi', 'gu', 'ta'],
      ),
      KnowledgeCategory(
        id: 'organic_farming',
        title: 'Organic Farming',
        emoji: '🌿',
        description: 'Organic and sustainable farming practices',
        resources: _offlinePacks.where((pack) => pack.category == 'Organic Farming').toList(),
        supportedLanguages: ['en', 'hi', 'gu', 'ta'],
      ),
      KnowledgeCategory(
        id: 'market_trends',
        title: 'Market Trends',
        emoji: '💰',
        description: 'Market analysis and agricultural economics',
        resources: _offlinePacks.where((pack) => pack.category == 'Market Trends').toList(),
        supportedLanguages: ['en', 'hi', 'ta'],
      ),
    ];
    
    return categories;
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
      // === CROP SCIENCE ===
      // English - TNAU Crop Production Guide
      OfflinePack(
        id: 'tnau_crop_production_guide_en',
        title: 'TNAU Crop Production Guide',
        description: 'Comprehensive crop production guidelines from Tamil Nadu Agricultural University.',
        pdfUrl: 'https://tnau.ac.in/cpg/wp-content/uploads/2020/03/CPG_Final-1.pdf',
        fileName: 'tnau_crop_production_guide.pdf',
        sizeBytes: 5120000, // ~5MB
        category: 'Crop Science',
        language: 'en',
        publishedDate: DateTime(2020, 3, 1),
      ),
      
      // Hindi - Traditional Agricultural Knowledge
      OfflinePack(
        id: 'traditional_knowledge_hindi',
        title: 'कृषि में पारंपरिक ज्ञान',
        description: 'Traditional agricultural knowledge and practices documented by ICAR in Hindi.',
        pdfUrl: 'https://icar.org.in/sites/default/files/2022-06/IITKA_Book_krishi-me-paramparik-gyan-Hindi-1.pdf',
        fileName: 'traditional_knowledge_hindi.pdf',
        sizeBytes: 3840000, // ~3.8MB
        category: 'Crop Science',
        language: 'hi',
        publishedDate: DateTime(2022, 6, 1),
      ),
      
      // Gujarati - Cost of Cultivation
      OfflinePack(
        id: 'cost_cultivation_gujarati',
        title: 'ખેતીની કિંમત ગણતરી',
        description: 'Cost of cultivation analysis and guidelines in Gujarati from AAU.',
        pdfUrl: 'https://aau.in/sites/default/files/2020-09/Cost_of_Cultivation_Gujarati.pdf',
        fileName: 'cost_cultivation_gujarati.pdf',
        sizeBytes: 2560000, // ~2.5MB
        category: 'Crop Science',
        language: 'gu',
        publishedDate: DateTime(2020, 9, 1),
      ),
      
      // Tamil - Agricultural Handbook
      OfflinePack(
        id: 'agri_handbook_tamil',
        title: 'வேளாண் கையேடு',
        description: 'Comprehensive agricultural handbook covering crop practices in Tamil.',
        pdfUrl: 'https://agri.py.gov.in/sites/default/files/Agricultural_Handbook_Tamil.pdf',
        fileName: 'agricultural_handbook_tamil.pdf',
        sizeBytes: 4096000, // ~4MB
        category: 'Crop Science',
        language: 'ta',
        publishedDate: DateTime(2023, 1, 1),
      ),

      // === FARM EQUIPMENT ===
      // English - SMAM Guidelines 2025
      OfflinePack(
        id: 'smam_guidelines_2025_en',
        title: 'SMAM Guidelines 2025 (English)',
        description: 'Revised Sub-Mission on Agricultural Mechanization guidelines for 2025.',
        pdfUrl: 'https://farmech.dac.gov.in/Content/New_Folder/Revised_SMAM_Guidelines_(2025)_With_Covering.pdf',
        fileName: 'smam_guidelines_2025_english.pdf',
        sizeBytes: 3072000, // ~3MB
        category: 'Farm Equipment',
        language: 'en',
        publishedDate: DateTime(2025, 1, 1),
      ),
      
      // Hindi - SMAM Guidelines 2025
      OfflinePack(
        id: 'smam_guidelines_2025_hi',
        title: 'SMAM दिशानिर्देश 2025',
        description: 'कृषि यंत्रीकरण पर उप-मिशन के संशोधित दिशानिर्देश 2025.',
        pdfUrl: 'https://farmech.dac.gov.in/Content/New_Folder/SMAM_Guidelines_(2025)_Hindi.pdf',
        fileName: 'smam_guidelines_2025_hindi.pdf',
        sizeBytes: 3072000, // ~3MB
        category: 'Farm Equipment',
        language: 'hi',
        publishedDate: DateTime(2025, 1, 1),
      ),
      
      // Gujarati - Drone SOP
      OfflinePack(
        id: 'drone_sop_gujarati',
        title: 'કૃષિ ડ્રોન સંચાલન માર્ગદર્શિકા',
        description: 'Standard Operating Procedures for Agricultural Drone Operations in Gujarati.',
        pdfUrl: 'https://farmech.dac.gov.in/Content/pdf/SOP_for_Agro_Drone_Operations_Gujarati.pdf',
        fileName: 'drone_sop_gujarati.pdf',
        sizeBytes: 1536000, // ~1.5MB
        category: 'Farm Equipment',
        language: 'gu',
        publishedDate: DateTime(2024, 6, 1),
      ),
      
      // Tamil - Millet Machinery
      OfflinePack(
        id: 'millet_machinery_tamil',
        title: 'தினை இயந்திர கையேடு',
        description: 'Comprehensive guide on millet-based farm machinery in Tamil.',
        pdfUrl: 'https://farmech.dac.gov.in/Content/pdf/Book_of_Millet_Based_Farm_Machinery_Tamil.pdf',
        fileName: 'millet_machinery_tamil.pdf',
        sizeBytes: 2048000, // ~2MB
        category: 'Farm Equipment',
        language: 'ta',
        publishedDate: DateTime(2024, 8, 1),
      ),

      // === PEST MANAGEMENT ===
      // English - IPM Technology Packages
      OfflinePack(
        id: 'ipm_technology_packages_en',
        title: 'IPM Technology Packages',
        description: 'Comprehensive technology packages for Integrated Pest Management.',
        pdfUrl: 'https://nriipm.res.in/images/Resource/Technology_packages_in_IPM.pdf',
        fileName: 'ipm_technology_packages.pdf',
        sizeBytes: 2560000, // ~2.5MB
        category: 'Pest Management',
        language: 'en',
        publishedDate: DateTime(2024, 3, 1),
      ),
      
      // Hindi - IPM Handbook for Farmers
      OfflinePack(
        id: 'ipm_handbook_hindi',
        title: 'किसानों के लिए IPM हैंडबुक',
        description: 'Integrated Pest Management handbook for farmers in Hindi.',
        pdfUrl: 'https://nriipm.res.in/images/Resource/handbook_of_ipm_for_farmers_hindi.pdf',
        fileName: 'ipm_handbook_hindi.pdf',
        sizeBytes: 2048000, // ~2MB
        category: 'Pest Management',
        language: 'hi',
        publishedDate: DateTime(2024, 3, 1),
      ),
      
      // Gujarati - Cotton Crop Guide
      OfflinePack(
        id: 'cotton_crop_guide_gujarati',
        title: 'કપાસ પાક માર્ગદર્શિકા',
        description: 'Cotton crop cultivation guide including pest control in Gujarati.',
        pdfUrl: 'https://www.jau.in/attachments/publications/00000_cotton_book.pdf',
        fileName: 'cotton_crop_guide_gujarati.pdf',
        sizeBytes: 3584000, // ~3.5MB
        category: 'Pest Management',
        language: 'gu',
        publishedDate: DateTime(2023, 6, 1),
      ),
      
      // Tamil - IPM Basics
      OfflinePack(
        id: 'ipm_basics_tamil',
        title: 'ஒருங்கிணைந்த பூச்சி மேலாண்மை அடிப்படைகள்',
        description: 'Basic principles of Integrated Pest Management in Tamil.',
        pdfUrl: 'https://www.doa.gov.lk/wp-content/uploads/2021/01/IPM-Tamil.pdf',
        fileName: 'ipm_basics_tamil.pdf',
        sizeBytes: 1024000, // ~1MB
        category: 'Pest Management',
        language: 'ta',
        publishedDate: DateTime(2021, 1, 1),
      ),

      // === IRRIGATION ===
      // English - Drip Irrigation Guide
      OfflinePack(
        id: 'drip_irrigation_guide_en',
        title: 'Drip Irrigation Technology Guide',
        description: 'Comprehensive guide on drip irrigation systems and implementation.',
        pdfUrl: 'http://agritech.tnau.ac.in/pdf/Drip_irrigation.pdf',
        fileName: 'drip_irrigation_guide.pdf',
        sizeBytes: 2048000, // ~2MB
        category: 'Irrigation',
        language: 'en',
        publishedDate: DateTime(2023, 4, 1),
      ),
      
      // Hindi - Micro-Irrigation Guidelines
      OfflinePack(
        id: 'micro_irrigation_hindi',
        title: 'सूक्ष्म सिंचाई दिशानिर्देश',
        description: 'Micro-irrigation guidelines under PMKSY scheme in Hindi.',
        pdfUrl: 'https://pmksy.gov.in/microirrigation/Guidelines_Hindi.pdf',
        fileName: 'micro_irrigation_hindi.pdf',
        sizeBytes: 1536000, // ~1.5MB
        category: 'Irrigation',
        language: 'hi',
        publishedDate: DateTime(2024, 2, 1),
      ),
      
      // Gujarati - Water Conservation Guide
      OfflinePack(
        id: 'water_conservation_gujarati',
        title: 'જળ સંરક્ષણ અને કૃષિ કાર્યક્રમો માર્ગદર્શિકા',
        description: 'Water conservation and agricultural programmes compendium in Gujarati.',
        pdfUrl: 'https://gad.gujarat.gov.in/writereaddata/Portal/Images/pdf/margdarshak_suchi_2014.pdf',
        fileName: 'water_conservation_gujarati.pdf',
        sizeBytes: 4096000, // ~4MB
        category: 'Irrigation',
        language: 'gu',
        publishedDate: DateTime(2014, 12, 1),
      ),
      
      // Tamil - Irrigation Planning Handbook
      OfflinePack(
        id: 'irrigation_planning_tamil',
        title: 'நீர்ப்பாசன திட்டமிடல் கையேடு',
        description: 'Irrigation planning handbook and project implementation primer in Tamil.',
        pdfUrl: 'https://www.tn.gov.in/spc/IAMWARM/PIP_Final.pdf',
        fileName: 'irrigation_planning_tamil.pdf',
        sizeBytes: 2560000, // ~2.5MB
        category: 'Irrigation',
        language: 'ta',
        publishedDate: DateTime(2023, 8, 1),
      ),

      // === ORGANIC FARMING ===
      // English - TNAU Organic Farming
      OfflinePack(
        id: 'organic_farming_tnau_en',
        title: 'TNAU Organic Farming Guide',
        description: 'Comprehensive organic farming guide from Tamil Nadu Agricultural University.',
        pdfUrl: 'http://agritech.tnau.ac.in/pdf/organic_farming.pdf',
        fileName: 'organic_farming_tnau.pdf',
        sizeBytes: 3072000, // ~3MB
        category: 'Organic Farming',
        language: 'en',
        publishedDate: DateTime(2023, 5, 1),
      ),
      
      // Hindi - Natural/Organic Farming Introduction
      OfflinePack(
        id: 'natural_farming_hindi',
        title: 'प्राकृतिक/जैविक खेती का परिचय',
        description: 'Introduction to Natural and Organic Farming methods in Hindi.',
        pdfUrl: 'https://agricoop.nic.in/sites/default/files/Natural_Organic_Farming_Hindi.pdf',
        fileName: 'natural_farming_hindi.pdf',
        sizeBytes: 2048000, // ~2MB
        category: 'Organic Farming',
        language: 'hi',
        publishedDate: DateTime(2024, 1, 1),
      ),
      
      // Gujarati - Natural Farming Guide
      OfflinePack(
        id: 'natural_farming_gujarati',
        title: 'પ્રાકૃતિક ખેતી માર્ગદર્શિકા',
        description: 'Natural farming methodology and practices guide in Gujarati.',
        pdfUrl: 'https://www.cooperation.gujarat.gov.in/writereaddata/images/pdf/Prakrutik-Kheti-Book.pdf',
        fileName: 'natural_farming_gujarati.pdf',
        sizeBytes: 1792000, // ~1.75MB
        category: 'Organic Farming',
        language: 'gu',
        publishedDate: DateTime(2023, 10, 1),
      ),
      
      // Tamil - Natural Agriculture
      OfflinePack(
        id: 'natural_agriculture_tamil',
        title: 'இயற்கை விவசாயம்',
        description: 'Natural agriculture principles and practices guide in Tamil.',
        pdfUrl: 'http://agritech.tnau.ac.in/ta/pdf/Iyarkai_Vivasayam.pdf',
        fileName: 'natural_agriculture_tamil.pdf',
        sizeBytes: 1536000, // ~1.5MB
        category: 'Organic Farming',
        language: 'ta',
        publishedDate: DateTime(2023, 7, 1),
      ),

      // === MARKET TRENDS ===
      // English - e-NAM Overview
      OfflinePack(
        id: 'enam_overview_en',
        title: 'e-NAM Platform Overview',
        description: 'Electronic National Agriculture Market (e-NAM) overview and factsheet.',
        pdfUrl: 'https://static.pib.gov.in/WriteReadData/specificdocs/documents/2023/apr/doc2023414181301.pdf',
        fileName: 'enam_overview.pdf',
        sizeBytes: 1024000, // ~1MB
        category: 'Market Trends',
        language: 'en',
        publishedDate: DateTime(2023, 4, 14),
      ),
      
      // Hindi - Agricultural Marketing
      OfflinePack(
        id: 'agri_marketing_hindi',
        title: 'कृषि विपणन - अवधारणाएं और संरचनाएं',
        description: 'Agricultural marketing concepts, structures and methodologies in Hindi.',
        pdfUrl: 'https://egyankosh.ac.in/bitstream/123456789/21975/1/Unit-16.pdf',
        fileName: 'agri_marketing_hindi.pdf',
        sizeBytes: 512000, // ~500KB
        category: 'Market Trends',
        language: 'hi',
        publishedDate: DateTime(2022, 1, 1),
      ),
      
      // Tamil - Farmer-Centric Portal
      OfflinePack(
        id: 'farmer_portal_tamil',
        title: 'விவசாயி மைய போர்டல்',
        description: 'Farmer-centric portal overview covering market access and services in Tamil.',
        pdfUrl: 'https://agritech.tnau.ac.in/ta/pdf/Farmers_Centric_Portal.pdf',
        fileName: 'farmer_portal_tamil.pdf',
        sizeBytes: 768000, // ~750KB
        category: 'Market Trends',
        language: 'ta',
        publishedDate: DateTime(2023, 11, 1),
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
