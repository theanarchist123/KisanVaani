import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/knowledge_models.dart';
import '../utils/app_theme.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Article Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareArticle(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'AGRICULTURE NEWS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Meta Info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.article.timeAgo,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (widget.article.source.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.source,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.article.source,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Article Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.article.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textDark,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Actions
            if (widget.article.url.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                    const Text(
                      'Read Full Article',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openFullArticle(context),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open in Browser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Tips Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Reading Tips',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• This article is cached for offline reading\n'
                    '• Share with fellow farmers to spread knowledge\n'
                    '• Visit the source for more detailed information\n'
                    '• Check back for updated articles regularly',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareArticle(BuildContext context) async {
    try {
      if (widget.article.url.isNotEmpty) {
        await Share.share(
          '${widget.article.title}\n\n${widget.article.description}\n\nRead more: ${widget.article.url}',
          subject: widget.article.title,
        );
      } else {
        await Share.share(
          '${widget.article.title}\n\n${widget.article.description}',
          subject: widget.article.title,
        );
      }
    } catch (e) {
      // Fallback to clipboard
      if (widget.article.url.isNotEmpty) {
        Clipboard.setData(ClipboardData(text: widget.article.url));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article URL copied to clipboard'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No URL available to share'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _openFullArticle(BuildContext context) async {
    if (widget.article.url.isNotEmpty) {
      // Show dialog to let user choose how to open the article
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Open Article'),
          content: const Text('How would you like to read this article?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _openInBrowser();
              },
              child: const Text('Open in Browser'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _shareArticleUrl();
              },
              child: const Text('Share Article'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No URL available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _openInBrowser() async {
    try {
      final uri = Uri.parse(widget.article.url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        _showSuccessSnackBar('Opening article in browser...');
      } else {
        // Fallback for different platforms
        if (Platform.isAndroid) {
          // Try sharing the URL so user can choose browser
          await Share.share(
            widget.article.url,
            subject: 'Open with your preferred browser',
          );
          _showSuccessSnackBar('Choose a browser from the options');
        } else if (Platform.isWindows) {
          await Process.run('start', ['""', widget.article.url], runInShell: true);
          _showSuccessSnackBar('Opening article in default browser');
        } else {
          throw Exception('Cannot open URL on this platform');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error opening URL: $e');
      // Fallback to sharing
      _shareArticleUrl();
    }
  }

  void _shareArticleUrl() async {
    try {
      await Share.share(
        '${widget.article.title}\n\n${widget.article.url}',
        subject: 'Check out this article: ${widget.article.title}',
      );
      _showSuccessSnackBar('Article shared successfully');
    } catch (e) {
      // Final fallback to clipboard
      await Clipboard.setData(ClipboardData(text: widget.article.url));
      _showSuccessSnackBar('Article URL copied to clipboard');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
