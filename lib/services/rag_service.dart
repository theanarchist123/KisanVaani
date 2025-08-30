import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to communicate with the RAG backend API
class RagService {
  // Local RAG backend URL - use 10.0.2.2 for Android emulator to access host machine
  static const String _baseUrl = 'http://10.0.2.2:8001';
  
  /// Query the RAG backend for agricultural knowledge
  Future<Map<String, dynamic>> queryRAG(String question) async {
    try {
      print('🔍 RAG Service: Querying backend with: $question');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/query'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'question': question,
          'max_chunks': 5,
          'similarity_threshold': 0.7,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('RAG backend timeout - please ensure the backend is running');
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ RAG Service: Received response from backend');
        return data;
      } else {
        print('❌ RAG Service: Backend error ${response.statusCode}');
        throw Exception('RAG backend error: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ RAG Service: Error - $e');
      throw Exception('Failed to query RAG backend: $e');
    }
  }
  
  /// Search document chunks without generating an answer
  Future<List<Map<String, dynamic>>> searchChunks(String query) async {
    try {
      print('🔍 RAG Service: Searching chunks for: $query');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/search'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': query,
          'limit': 10,
        }),
      ).timeout(
        const Duration(seconds: 15),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Search error: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ RAG Service: Search error - $e');
      throw Exception('Failed to search chunks: $e');
    }
  }
  
  /// Check if RAG backend is available
  Future<bool> isBackendAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
      ).timeout(
        const Duration(seconds: 5),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
      
    } catch (e) {
      print('🔍 RAG Service: Backend not available - $e');
      return false;
    }
  }
  
  /// Get sample chunks for testing
  Future<List<Map<String, dynamic>>> getSampleChunks() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chunks'),
      ).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get sample chunks');
      }
      
    } catch (e) {
      print('❌ RAG Service: Error getting sample chunks - $e');
      throw Exception('Failed to get sample chunks: $e');
    }
  }
  
  /// Test embedding generation
  Future<Map<String, dynamic>> testEmbedding(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/test-embedding'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
        }),
      ).timeout(
        const Duration(seconds: 15),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Embedding test failed: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ RAG Service: Embedding test error - $e');
      throw Exception('Failed to test embedding: $e');
    }
  }
}
