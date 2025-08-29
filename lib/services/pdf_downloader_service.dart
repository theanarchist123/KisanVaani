import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PdfDownloaderService {
  Future<String> downloadPdf(
    String url,
    String fileName,
    {Function(double)? onProgress}
  ) async {
    try {
      // Get the documents directory
      final Directory documentsDir = await getApplicationDocumentsDirectory();
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
      
      // For demo purposes, create a simple text file with PDF extension
      // In production, this would download from the actual URL
      final String demoContent = '''
%PDF-1.4
Demo PDF Content for $fileName

This is a demonstration PDF file for the Knowledge Pack: $fileName

In a real implementation, this would be downloaded from: $url

Key Topics:
- Agriculture Best Practices
- Crop Management
- Farming Techniques
- Soil Health
- Pest Control
- Irrigation Methods

This PDF contains comprehensive information about farming practices
specifically designed for Indian farmers.

For more information, visit your local agricultural extension office.
''';
      
      // Simulate download progress
      if (onProgress != null) {
        for (int i = 0; i <= 100; i += 20) {
          await Future.delayed(const Duration(milliseconds: 100));
          onProgress(i / 100.0);
        }
      }
      
      // Write the demo file
      await file.writeAsString(demoContent);
      
      return filePath;
    } catch (e) {
      throw Exception('Error downloading PDF: $e');
    }
  }
  
  Future<String> downloadPdfWithProgress(
    String url,
    String fileName,
    {Function(double)? onProgress}
  ) async {
    try {
      // Get the documents directory
      final Directory documentsDir = await getApplicationDocumentsDirectory();
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
      
      // Create HTTP client
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);
      
      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        int downloadedBytes = 0;
        final List<int> bytes = [];
        
        // Listen to response stream
        await for (final chunk in response.stream) {
          bytes.addAll(chunk);
          downloadedBytes += chunk.length;
          
          if (contentLength > 0 && onProgress != null) {
            final progress = downloadedBytes / contentLength;
            onProgress(progress);
          }
        }
        
        // Write the file
        await file.writeAsBytes(Uint8List.fromList(bytes));
        
        // Ensure progress callback shows 100%
        if (onProgress != null) {
          onProgress(1.0);
        }
        
        return filePath;
      } else {
        throw Exception('Failed to download PDF: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading PDF: $e');
    }
  }
  
  Future<bool> isPdfDownloaded(String fileName) async {
    try {
      final Directory documentsDir = await getApplicationDocumentsDirectory();
      final String knowledgeDir = path.join(documentsDir.path, 'knowledge_packs');
      final String filePath = path.join(knowledgeDir, fileName);
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  Future<void> deletePdf(String fileName) async {
    try {
      final Directory documentsDir = await getApplicationDocumentsDirectory();
      final String knowledgeDir = path.join(documentsDir.path, 'knowledge_packs');
      final String filePath = path.join(knowledgeDir, fileName);
      final File file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Error deleting PDF: $e');
    }
  }
  
  Future<List<String>> getDownloadedPdfs() async {
    try {
      final Directory documentsDir = await getApplicationDocumentsDirectory();
      final String knowledgeDir = path.join(documentsDir.path, 'knowledge_packs');
      final Directory dir = Directory(knowledgeDir);
      
      if (!await dir.exists()) {
        return [];
      }
      
      final List<FileSystemEntity> files = await dir.list().toList();
      return files
          .where((file) => file.path.endsWith('.pdf'))
          .map((file) => path.basename(file.path))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<int> getDirectorySize() async {
    try {
      final Directory documentsDir = await getApplicationDocumentsDirectory();
      final String knowledgeDir = path.join(documentsDir.path, 'knowledge_packs');
      final Directory dir = Directory(knowledgeDir);
      
      if (!await dir.exists()) {
        return 0;
      }
      
      int totalSize = 0;
      final List<FileSystemEntity> files = await dir.list(recursive: true).toList();
      
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}
