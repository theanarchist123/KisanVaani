import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../utils/app_theme.dart';

class PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = false;
  String? _error;
  File? _pdfFile;
  int? _fileSize;
  DateTime? _lastModified;

  @override
  void initState() {
    super.initState();
    _loadPdfInfo();
  }

  void _loadPdfInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        final stat = await file.stat();
        setState(() {
          _pdfFile = file;
          _fileSize = stat.size;
          _lastModified = stat.modified;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'PDF file not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showPdfInfo,
            tooltip: 'PDF Info',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            ),
            SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorView();
    }

    return _buildPdfPreview();
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load PDF',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPdfInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // PDF Icon and Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
                Icon(
                  Icons.picture_as_pdf,
                  size: 80,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (_fileSize != null)
                  Text(
                    'Size: ${(_fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                if (_lastModified != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Downloaded: ${_formatDate(_lastModified!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
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
                  'PDF Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openPdfExternally,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open with External PDF Viewer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _sharePdf,
                    icon: const Icon(Icons.share),
                    label: const Text('Share PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showFileLocation,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Show File Location'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // PDF Reading Tips
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
                  '• This PDF is saved offline and can be read anytime\n'
                  '• Use external PDF apps for better reading experience\n'
                  '• Bookmark important pages in your PDF reader\n'
                  '• Take notes while reading for better retention',
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
    );
  }

  void _openPdfExternally() async {
    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        // Show dialog to let user choose how to open the PDF
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Open PDF'),
            content: const Text('How would you like to open this PDF?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _shareFile();
                },
                child: const Text('Share with App'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openWithIntent();
                },
                child: const Text('Open with PDF Viewer'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      } else {
        _showErrorSnackBar('PDF file not found');
      }
    } catch (e) {
      _showErrorSnackBar('Error accessing PDF: $e');
    }
  }

  void _shareFile() async {
    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(widget.filePath)],
          text: 'Check out this agricultural guide: ${widget.title}',
          subject: widget.title,
        );
        _showSuccessSnackBar('PDF shared successfully');
      } else {
        _showErrorSnackBar('PDF file not found');
      }
    } catch (e) {
      _showErrorSnackBar('Error sharing PDF: $e');
    }
  }

  void _openWithIntent() async {
    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        if (Platform.isAndroid) {
          // Use open_filex for better Android file opening
          final result = await OpenFilex.open(widget.filePath);
          if (result.type == ResultType.done) {
            _showSuccessSnackBar('Opening PDF with external viewer');
          } else if (result.type == ResultType.noAppToOpen) {
            _showErrorSnackBar('No PDF viewer app found. Please install a PDF viewer.');
            // Fallback: Share so user can choose to install a viewer
            await Share.shareXFiles(
              [XFile(widget.filePath)],
              text: 'Install a PDF viewer to open this file',
              subject: 'View PDF: ${widget.title}',
            );
          } else {
            _showErrorSnackBar('Error opening PDF: ${result.message}');
            _shareFile();
          }
        } else if (Platform.isWindows) {
          // For Windows, try to open with default app
          await Process.run('start', ['""', widget.filePath], runInShell: true);
          _showSuccessSnackBar('Opening PDF with default app');
        } else {
          // Fallback: try url_launcher
          final uri = Uri.file(widget.filePath);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            _showSuccessSnackBar('Opening PDF with external viewer');
          } else {
            _shareFile(); // Fallback to share
          }
        }
      } else {
        _showErrorSnackBar('PDF file not found');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening PDF: $e');
      // Fallback to share if direct opening fails
      _shareFile();
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _sharePdf() async {
    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(widget.filePath)],
          text: 'Check out this agricultural guide: ${widget.title}',
          subject: widget.title,
        );
        _showSuccessSnackBar('PDF shared successfully');
      } else {
        _showErrorSnackBar('PDF file not found');
      }
    } catch (e) {
      // Fallback to copying path to clipboard
      await Clipboard.setData(ClipboardData(text: widget.filePath));
      _showSuccessSnackBar('PDF file path copied to clipboard');
    }
  }

  void _showFileLocation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Location'),
        content: SelectableText(
          widget.filePath,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPdfInfo() {
    if (_pdfFile != null && _fileSize != null && _lastModified != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${widget.title}'),
              const SizedBox(height: 8),
              Text('Size: ${(_fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB'),
              const SizedBox(height: 8),
              Text('Downloaded: ${_formatDate(_lastModified!)}'),
              const SizedBox(height: 8),
              Text('Location: ${widget.filePath}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
