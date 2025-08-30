import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PdfDownloaderService {
  
  Future<Directory> _getDocumentsDirectory() async {
    try {
      // For web and desktop platforms, use a fallback approach
      if (kIsWeb) {
        // For web, we can't actually save files to disk
        // Return a mock directory for now
        throw UnsupportedError('File downloads not supported on web platform');
      }
      
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // For desktop platforms, try to get documents directory
        try {
          return await getApplicationDocumentsDirectory();
        } catch (e) {
          // Fallback for desktop - use current directory
          return Directory.current;
        }
      }
      
      // For mobile platforms (Android/iOS)
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      // Ultimate fallback - use current directory
      return Directory.current;
    }
  }

  Future<String> downloadPdf(
    String url,
    String fileName,
    {Function(double)? onProgress}
  ) async {
    try {
      // Handle web platform
      if (kIsWeb) {
        // For web, we'll create a fallback message instead of downloading
        _createFallbackContent(fileName, url, 'Web platform - downloads not supported');
        onProgress?.call(1.0);
        print('Web platform: Created fallback content for: $fileName');
        return 'web_fallback_$fileName';
      }

      // Get the documents directory with platform handling
      final Directory documentsDir = await _getDocumentsDirectory();
      final String knowledgeDir = path.join(documentsDir.path, 'knowledge_packs');
      
      // Create knowledge packs directory if it doesn't exist
      final Directory dir = Directory(knowledgeDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      final String filePath = path.join(knowledgeDir, fileName);
      
      // Check if file already exists
      final File file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      
      // Attempt to download the actual PDF
      try {
        print('Attempting to download PDF from: $url');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Android 10; Mobile; rv:81.0) Gecko/81.0 Firefox/81.0',
            'Accept': 'application/pdf,application/octet-stream,*/*',
          },
        ).timeout(const Duration(minutes: 5));
        
        print('Response status: ${response.statusCode}');
        print('Content-Type: ${response.headers['content-type']}');
        print('Content-Length: ${response.bodyBytes.length}');
        
        if (response.statusCode == 200) {
          // Check if the response is actually a PDF
          final contentType = response.headers['content-type'] ?? '';
          final bodyBytes = response.bodyBytes;
          
          // PDF files start with "%PDF"
          if (contentType.contains('pdf') || 
              (bodyBytes.length > 4 && 
               String.fromCharCodes(bodyBytes.take(4)) == '%PDF')) {
            
            // Write the actual PDF content
            await file.writeAsBytes(bodyBytes);
            onProgress?.call(1.0);
            print('Successfully downloaded PDF: $fileName');
            return filePath;
          } else {
            throw Exception('Response is not a valid PDF file');
          }
        } else {
          throw Exception('HTTP ${response.statusCode}: Failed to download PDF');
        }
      } catch (downloadError) {
        print('Failed to download from URL: $downloadError');
        
        // Fallback: Create an informative text file
        final String fallbackContent = _createFallbackContent(fileName, url, downloadError.toString());
        await file.writeAsString(fallbackContent);
        onProgress?.call(1.0);
        print('Created fallback content for: $fileName');
        return filePath;
      }
    } catch (e) {
      throw Exception('Error downloading PDF: $e');
    }
  }

  String _createFallbackContent(String fileName, String originalUrl, String error) {
    return '''
AGRICULTURAL KNOWLEDGE RESOURCE
================================

File: $fileName
Original URL: $originalUrl
Download Error: $error

IMPORTANT NOTICE:
This file could not be downloaded from the original source. This may be due to:
- Network connectivity issues
- Server availability problems
- URL changes or broken links
- Access restrictions

WHAT TO DO:
1. Check your internet connection
2. Try downloading again later
3. Visit the original source manually: $originalUrl
4. Contact your local agricultural extension office for assistance

ALTERNATIVE RESOURCES:
- Visit your local Krishi Vigyan Kendra (KVK)
- Contact ICAR institutes in your region
- Access government agricultural portals
- Consult with local agricultural experts

FARMING TIPS:
- Always verify information from multiple sources
- Consult local experts for region-specific advice
- Follow sustainable farming practices
- Keep up with the latest agricultural research

For technical support, please report this issue to the app developers.

Generated: ${DateTime.now().toLocal()}
''';
  }

  Future<bool> deletePdf(String filePath) async {
    try {
      if (kIsWeb) {
        // On web, we can't actually delete files
        return true;
      }
      
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Error deleting PDF: $e');
    }
  }
  
  Future<List<String>> getDownloadedPdfs() async {
    try {
      if (kIsWeb) {
        // On web, return empty list
        return [];
      }
      
      final Directory documentsDir = await _getDocumentsDirectory();
      final String knowledgeDir = path.join(documentsDir.path, 'knowledge_packs');
      final Directory dir = Directory(knowledgeDir);
      
      if (!await dir.exists()) {
        return [];
      }
      
      final List<FileSystemEntity> files = await dir.list().toList();
      return files
          .where((file) => file is File && file.path.endsWith('.pdf'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      debugPrint('Error listing downloaded PDFs: $e');
      return [];
    }
  }
  
  Future<int> getTotalDownloadedSize() async {
    try {
      if (kIsWeb) {
        // On web, return 0
        return 0;
      }
      
      final List<String> pdfPaths = await getDownloadedPdfs();
      int totalSize = 0;
      
      for (String filePath in pdfPaths) {
        final File file = File(filePath);
        if (await file.exists()) {
          final int fileSize = await file.length();
          totalSize += fileSize;
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
  
  String formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
