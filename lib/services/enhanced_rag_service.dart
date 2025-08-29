import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EnhancedRagService {
  static const String baseUrl = 'http://10.145.241.241:8000';
  
  // Enhanced query with agricultural intelligence
  static Future<EnhancedRagResponse?> queryWithContext({
    required String question,
    Map<String, dynamic>? userContext,
    String? conversationId,
    int maxChunks = 5,
    double similarityThreshold = 0.6,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question,
          'max_chunks': maxChunks,
          'similarity_threshold': similarityThreshold,
          'user_context': userContext,
          'conversation_id': conversationId,
        }),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return EnhancedRagResponse.fromJson(responseData);
      } else {
        debugPrint('Enhanced RAG query failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error in enhanced RAG query: $e');
      return null;
    }
  }
  
  // Check if enhanced RAG server is running
  static Future<bool> isEnhancedServerRunning() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final healthData = jsonDecode(response.body);
        return healthData['status'] == 'healthy' && 
               healthData['details']['overall'] == true &&
               healthData['details']['enhanced_features'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Enhanced RAG server health check failed: $e');
      return false;
    }
  }
  
  // Get server information
  static Future<Map<String, dynamic>?> getServerInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting server info: $e');
      return null;
    }
  }
  
  // VAPI call initiation
  static Future<bool> initiateVoiceCall({
    required String phoneNumber,
    Map<String, dynamic>? farmerContext,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vapi-call'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'farmer_context': farmerContext,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error initiating VAPI call: $e');
      return false;
    }
  }
  
  // Create VAPI assistant
  static Future<String?> createVoiceAssistant() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vapi-assistant'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['assistant_id'];
      }
      return null;
    } catch (e) {
      debugPrint('Error creating VAPI assistant: $e');
      return null;
    }
  }
}

class EnhancedRagResponse {
  final String answer;
  final String question;
  final int chunksUsed;
  final List<DocumentChunk> chunks;
  final double confidence;
  final List<String> suggestions;
  final List<String> relatedTopics;
  final String urgency;
  final Map<String, dynamic> processingMetadata;
  
  EnhancedRagResponse({
    required this.answer,
    required this.question,
    required this.chunksUsed,
    required this.chunks,
    required this.confidence,
    required this.suggestions,
    required this.relatedTopics,
    required this.urgency,
    required this.processingMetadata,
  });
  
  factory EnhancedRagResponse.fromJson(Map<String, dynamic> json) {
    return EnhancedRagResponse(
      answer: json['answer'] ?? '',
      question: json['question'] ?? '',
      chunksUsed: json['chunks_used'] ?? 0,
      chunks: (json['chunks'] as List?)
          ?.map((chunk) => DocumentChunk.fromJson(chunk))
          .toList() ?? [],
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      relatedTopics: List<String>.from(json['related_topics'] ?? []),
      urgency: json['urgency'] ?? 'normal',
      processingMetadata: json['processing_metadata'] ?? {},
    );
  }
}

class DocumentChunk {
  final String content;
  final Map<String, dynamic> metadata;
  final double similarity;
  
  DocumentChunk({
    required this.content,
    required this.metadata,
    required this.similarity,
  });
  
  factory DocumentChunk.fromJson(Map<String, dynamic> json) {
    return DocumentChunk(
      content: json['content'] ?? '',
      metadata: json['metadata'] ?? {},
      similarity: (json['similarity'] ?? 0.0).toDouble(),
    );
  }
}
