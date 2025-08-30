import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/knowledge_provider.dart';
import '../models/knowledge_models.dart';
import '../widgets/pdf_viewer.dart';
import 'article_detail_screen.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KnowledgeProvider>(context, listen: false).fetchLatestArticles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () => Provider.of<KnowledgeProvider>(context, listen: false).refreshAll(),
        color: AppTheme.primaryGreen,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              _buildSearchBar(),
              
              const SizedBox(height: 20),
              
              // Offline Packs Section
              _buildOfflinePacksSection(),
              
              const SizedBox(height: 24),
              
              // Latest Articles Section
              _buildLatestArticlesSection(),
              
              const SizedBox(height: 24),
              
              // Learning Categories
              _buildCategoriesSection(),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: const InputDecoration(
          hintText: 'ज्ञान पैक और लेख खोजें...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppTheme.primaryGreen),
        ),
      ),
    );
  }

  Widget _buildOfflinePacksSection() {
    return Consumer<KnowledgeProvider>(
      builder: (context, provider, child) {
        List<OfflinePack> filteredPacks = provider.offlinePacks;
        
        if (_searchQuery.isNotEmpty) {
          filteredPacks = filteredPacks.where((pack) =>
            pack.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            pack.description.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        return Column(
          children: [
            _buildSectionHeader('ऑफलाइन ज्ञान पैक', Icons.offline_pin, 
              subtitle: 'ऑफलाइन पढ़ने के लिए डाउनलोड करें'),
            const SizedBox(height: 12),
            
            if (filteredPacks.isEmpty && _searchQuery.isNotEmpty)
              _buildEmptySearch('कोई ऑफलाइन पैक नहीं मिला\n(No offline packs found)')
            else
              ...filteredPacks.map((pack) => _buildOfflinePackCard(pack)),
          ],
        );
      },
    );
  }

  Widget _buildLatestArticlesSection() {
    return Consumer<KnowledgeProvider>(
      builder: (context, provider, child) {
        List<Article> filteredArticles = provider.articles;
        
        if (_searchQuery.isNotEmpty) {
          filteredArticles = filteredArticles.where((article) =>
            article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            article.description.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        return Column(
          children: [
            _buildSectionHeader('नवीनतम कृषि समाचार', Icons.article,
              subtitle: 'खेती के रुझानों से अपडेट रहें'),
            const SizedBox(height: 12),
            
            if (provider.isLoadingArticles)
              _buildLoadingIndicator('नवीनतम लेख लोड हो रहे हैं...\n(Loading latest articles...)')
            else if (filteredArticles.isEmpty && _searchQuery.isNotEmpty)
              _buildEmptySearch('कोई लेख नहीं मिला\n(No articles found)')
            else if (filteredArticles.isEmpty)
              _buildEmptyState('कोई लेख उपलब्ध नहीं\n(No articles available)', 'नवीनतम समाचार के लिए पुल करें\n(Pull to refresh for latest news)')
            else
              ...filteredArticles.take(5).map((article) => _buildArticleCard(article)),
              
            if (filteredArticles.isNotEmpty && filteredArticles.length > 5) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _showAllArticles(filteredArticles),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primaryGreen),
                child: const Text('सभी लेख देखें\n(View All Articles)'),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'emoji': '🌱', 'title': 'फसल विज्ञान', 'count': '25 विषय'},
      {'emoji': '🚜', 'title': 'खेती उपकरण', 'count': '15 विषय'},
      {'emoji': '🐛', 'title': 'कीट प्रबंधन', 'count': '20 विषय'},
      {'emoji': '💧', 'title': 'सिंचाई', 'count': '18 विषय'},
      {'emoji': '🌿', 'title': 'जैविक खेती', 'count': '12 विषय'},
      {'emoji': '💰', 'title': 'बाजार रुझान', 'count': '10 विषय'},
    ];

    List<Map<String, String>> filteredCategories = categories;
    
    if (_searchQuery.isNotEmpty) {
      filteredCategories = categories.where((category) =>
        category['title']!.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return Column(
      children: [
        _buildSectionHeader('ज्ञान श्रेणियां', Icons.category,
          subtitle: 'खेती के विषयों का अन्वेषण करें'),
        const SizedBox(height: 12),
        
        if (filteredCategories.isEmpty)
          _buildEmptySearch('कोई श्रेणी नहीं मिली\n(No categories found)')
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: filteredCategories.map((category) =>
              _buildCategoryCard(
                category['emoji']!,
                category['title']!,
                category['count']!,
              )
            ).toList(),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOfflinePackCard(OfflinePack pack) {
    return Consumer<KnowledgeProvider>(
      builder: (context, provider, child) {
        final isDownloading = provider.downloadProgress.containsKey(pack.id);
        final progress = provider.downloadProgress[pack.id] ?? 0.0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getStatusColor(pack.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      _getStatusIcon(pack.status),
                      color: _getStatusColor(pack.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pack.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pack.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.file_present, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              pack.formattedSize,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.language, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              'Hindi & English',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _handlePackAction(pack),
                    icon: Icon(
                      pack.status == OfflinePackStatus.downloaded ? Icons.open_in_new : Icons.download,
                      color: _getStatusColor(pack.status),
                    ),
                  ),
                ],
              ),
              
              if (isDownloading) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                ),
                const SizedBox(height: 4),
                Text(
                  'डाउनलोड हो रहा है... ${(progress * 100).toInt()}%\n(Downloading... ${(progress * 100).toInt()}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildArticleCard(Article article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openArticle(article),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    article.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEWS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              article.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  article.timeAgo,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (article.imageUrl.isNotEmpty)
                  Icon(Icons.image, size: 14, color: Colors.grey[500]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String emoji, String title, String count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openCategory(title),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearch(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OfflinePackStatus status) {
    switch (status) {
      case OfflinePackStatus.downloaded:
        return Colors.green;
      case OfflinePackStatus.notDownloaded:
        return AppTheme.primaryGreen;
      case OfflinePackStatus.downloading:
        return Colors.orange;
      case OfflinePackStatus.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OfflinePackStatus status) {
    switch (status) {
      case OfflinePackStatus.downloaded:
        return Icons.check_circle;
      case OfflinePackStatus.notDownloaded:
        return Icons.download;
      case OfflinePackStatus.downloading:
        return Icons.downloading;
      case OfflinePackStatus.error:
        return Icons.error;
    }
  }

  void _handlePackAction(OfflinePack pack) {
    final provider = Provider.of<KnowledgeProvider>(context, listen: false);
    
    if (pack.status == OfflinePackStatus.downloaded) {
      // Open the downloaded PDF
      if (pack.localPath != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              filePath: pack.localPath!,
              title: pack.title,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF file path not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Download the pack
      provider.downloadPack(pack.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading ${pack.title}...'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  void _openArticle(Article article) {
    // Navigate to article detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }

  void _openCategory(String categoryTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening category: $categoryTitle'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _showAllArticles(List<Article> articles) {
    // Navigate to all articles screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing all ${articles.length} articles'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }
}
