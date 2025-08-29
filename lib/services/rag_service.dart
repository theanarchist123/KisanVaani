import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RAGService {
  // Dynamic base URL based on platform
  static String get baseUrl {
    // For web (Chrome), use localhost
    if (kIsWeb) {
      return 'http://localhost:8000'; // Back to the real port
    }
    // For mobile devices, use network IP
    try {
      // Check if we're on a real device and get the local IP
      // Use a different network IP if 192.168.0.101 doesn't work for you
      return 'http://192.168.0.101:8000'; // Updated to match your actual IP from ipconfig
    } catch (e) {
      // Fallback to localhost if we can't determine the network IP
      print('Error getting network IP, falling back to localhost: $e');
      return 'http://10.0.2.2:8000'; // 10.0.2.2 is localhost from Android emulator
    }
  }
  
  static const String ragEndpoint = '/query';
  static const String searchEndpoint = '/search';
  static const String healthEndpoint = '/health';

  /// Test if RAG backend is available
  static Future<bool> isHealthy() async {
    try {
      final url = '$baseUrl$healthEndpoint';
      print('Checking RAG Backend health at: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      print('RAG Health check response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('RAG Backend health check failed: $e');
      
      // Try a different endpoint if health check fails
      try {
        final rootUrl = baseUrl;
        print('Trying fallback root check at: $rootUrl');
        
        final rootResponse = await http.get(
          Uri.parse(rootUrl),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 3));
        
        print('Fallback root check: ${rootResponse.statusCode} - ${rootResponse.body}');
        return rootResponse.statusCode == 200;
      } catch (e2) {
        print('Fallback check also failed: $e2');
        return false;
      }
    }
  }

  /// Query the RAG backend for answers
  static Future<RAGResponse?> queryRAG({
    required String question,
    int maxChunks = 5,
    double similarityThreshold = 0.7,
  }) async {
    try {
      final requestBody = {
        'question': question,
        'max_chunks': maxChunks,
        'similarity_threshold': similarityThreshold,
      };

      final response = await http.post(
        Uri.parse('$baseUrl$ragEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RAGResponse.fromJson(data);
      } else {
        print('RAG query failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error querying RAG backend: $e');
      return null;
    }
  }

  /// Search documents in the RAG backend
  static Future<List<DocumentChunk>?> searchDocuments({
    required String query,
    int limit = 10,
  }) async {
    try {
      final requestBody = {
        'query': query,
        'limit': limit,
      };

      final response = await http.post(
        Uri.parse('$baseUrl$searchEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> chunks = data['chunks'] ?? [];
        return chunks.map((chunk) => DocumentChunk.fromJson(chunk)).toList();
      } else {
        print('Search failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error searching documents: $e');
      return null;
    }
  }
}

/// RAG Response model
class RAGResponse {
  final String question;
  final String answer;
  final List<DocumentChunk> chunks;
  final String processingTime;
  final bool success;

  RAGResponse({
    required this.question,
    required this.answer,
    required this.chunks,
    required this.processingTime,
    required this.success,
  });

  factory RAGResponse.fromJson(Map<String, dynamic> json) {
    return RAGResponse(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      chunks: (json['chunks'] as List<dynamic>? ?? [])
          .map((chunk) => DocumentChunk.fromJson(chunk))
          .toList(),
      processingTime: json['processing_time'] ?? '',
      success: json['success'] ?? false,
    );
  }
}

/// Document Chunk model
class DocumentChunk {
  final int id;
  final String content;
  final Map<String, dynamic> metadata;
  final double? similarity;

  DocumentChunk({
    required this.id,
    required this.content,
    required this.metadata,
    this.similarity,
  });

  factory DocumentChunk.fromJson(Map<String, dynamic> json) {
    return DocumentChunk(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      metadata: json['metadata'] ?? {},
      similarity: json['similarity']?.toDouble(),
    );
  }
}
