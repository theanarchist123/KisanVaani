import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../models/knowledge_models.dart';
import '../providers/knowledge_provider.dart';
import '../widgets/pdf_viewer.dart';

class CategoryDetailScreen extends StatefulWidget {
  final KnowledgeCategory category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  String _selectedLanguage = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.category.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.category.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.category.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.library_books,
                      size: 20,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.category.resourceCountText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Language Filter
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Language: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildLanguageChip('all', 'All'),
                        ...widget.category.supportedLanguages.map(
                          (lang) => _buildLanguageChip(lang, _getLanguageName(lang)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Resources List
          Expanded(
            child: Consumer<KnowledgeProvider>(
              builder: (context, provider, child) {
                final filteredResources = _selectedLanguage == 'all'
                    ? widget.category.resources
                    : widget.category.resources
                        .where((resource) => resource.language == _selectedLanguage)
                        .toList();

                if (filteredResources.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No resources available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_selectedLanguage != 'all') ...[
                          const SizedBox(height: 8),
                          Text(
                            'for ${_getLanguageName(_selectedLanguage)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredResources.length,
                  itemBuilder: (context, index) {
                    final resource = filteredResources[index];
                    return _buildResourceCard(resource, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String langCode, String langName) {
    final isSelected = _selectedLanguage == langCode;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(langName),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedLanguage = langCode;
          });
        },
        selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryGreen,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryGreen : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildResourceCard(OfflinePack resource, KnowledgeProvider provider) {
    final isDownloading = provider.downloadProgress.containsKey(resource.id);
    final progress = provider.downloadProgress[resource.id] ?? 0.0;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLanguageColor(resource.language).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getLanguageName(resource.language).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getLanguageColor(resource.language),
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                _getStatusIcon(resource.status),
                color: _getStatusColor(resource.status),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            resource.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resource.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.file_present,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                resource.formattedSize,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              if (resource.isDownloaded)
                ElevatedButton.icon(
                  onPressed: () => _openResource(resource),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Open'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                )
              else if (isDownloading)
                Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 4,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: () => provider.downloadPack(resource.id),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _openResource(OfflinePack resource) {
    if (resource.localPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            filePath: resource.localPath!,
            title: resource.title,
          ),
        ),
      );
    }
  }

  String _getLanguageName(String langCode) {
    switch (langCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'gu':
        return 'ગુજરાતી';
      case 'ta':
        return 'தமிழ்';
      default:
        return langCode.toUpperCase();
    }
  }

  Color _getLanguageColor(String langCode) {
    switch (langCode) {
      case 'en':
        return Colors.blue;
      case 'hi':
        return Colors.orange;
      case 'gu':
        return Colors.green;
      case 'ta':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(OfflinePackStatus status) {
    switch (status) {
      case OfflinePackStatus.downloaded:
        return Icons.check_circle;
      case OfflinePackStatus.downloading:
        return Icons.download;
      case OfflinePackStatus.error:
        return Icons.error;
      case OfflinePackStatus.notDownloaded:
        return Icons.cloud_download;
    }
  }

  Color _getStatusColor(OfflinePackStatus status) {
    switch (status) {
      case OfflinePackStatus.downloaded:
        return Colors.green;
      case OfflinePackStatus.downloading:
        return Colors.blue;
      case OfflinePackStatus.error:
        return Colors.red;
      case OfflinePackStatus.notDownloaded:
        return Colors.grey;
    }
  }
}
