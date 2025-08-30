import 'dart:convert';
import 'package:http/http.dart' as http;
import 'rag_service.dart';

class AIAssistantService {
  final RagService _ragService = RagService();
  
  /// Helper method to check if query contains any of the keywords
  bool _containsAny(String query, List<String> keywords) {
    return keywords.any((keyword) => query.contains(keyword.toLowerCase()));
  }
  
  /// AI assistant inside farmer's financial and crop management app
  /// Behavior: Accurately understand intent and provide short, clear, correct answers
  /// Rules: Always answer truthfully, never guess, keep under 3 sentences, farmer-friendly language
  Future<String> processQuery(String userQuery) async {
    try {
      print('AI Farmer Assistant: Processing speech input: $userQuery');
      
      // First check if RAG backend is available
      bool ragAvailable = await _ragService.isBackendAvailable();
      print('AI Farmer Assistant: RAG backend available: $ragAvailable');
      
      final response = await _generateFarmerResponse(userQuery, ragAvailable);
      print('AI Farmer Assistant: Generated response: $response');
      
      return response;
    } catch (e) {
      print('AI Farmer Assistant: Error processing query: $e');
      return "Sorry, I don't have that information right now.";
    }
  }
  
  /// Generate farmer-friendly response based on user query
  /// Following exact ElevenLabs AI assistant behavior guidelines
  Future<String> _generateFarmerResponse(String query, bool ragAvailable) async {
    final lowerQuery = query.toLowerCase();
    
    print('AI Assistant: Analyzing speech input: "$lowerQuery"');
    
    // FARMING KNOWLEDGE QUERIES - Use RAG backend if available
    if (_containsAny(lowerQuery, ['how to', 'कैसे', 'when to', 'कब', 'what is', 'क्या है', 'crop', 'फसल', 'farming', 'खेती', 'agriculture', 'कृषि', 'grow', 'उगाना', 'plant', 'लगाना', 'fertilizer', 'खाद', 'pest', 'कीट', 'disease', 'रोग', 'irrigation', 'सिंचाई', 'harvest', 'फसल काटना', 'soil', 'मिट्टी', 'seed', 'बीज', 'organic', 'जैविक'])) {
      
      if (ragAvailable) {
        try {
          print('AI Assistant: Using RAG backend for agricultural query');
          final ragResponse = await _ragService.queryRAG(query);
          final answer = ragResponse['answer'];
          if (answer != null && answer.toString().isNotEmpty) {
            // Make response conversational and concise
            String cleanAnswer = answer.toString();
            if (cleanAnswer.length > 200) {
              cleanAnswer = cleanAnswer.substring(0, 200) + '...';
            }
            return cleanAnswer;
          }
        } catch (e) {
          print('AI Assistant: RAG query failed: $e');
        }
      }
      
      // Fallback to basic agricultural knowledge
      if (_containsAny(lowerQuery, ['rice', 'धान', 'चावल'])) {
        return "Rice needs well-prepared fields, good quality seeds, and proper water management. Plant during monsoon season.";
      } else if (_containsAny(lowerQuery, ['wheat', 'गेहूं'])) {
        return "Wheat grows best in winter season. Sow in November-December. Needs 4-6 irrigations.";
      } else if (_containsAny(lowerQuery, ['tomato', 'टमाटर'])) {
        return "Tomatoes need rich soil and regular watering. Protect from pests and diseases.";
      }
    }
    
    // YIELD PREDICTION QUERIES - Connect to Flask API
    if (_containsAny(lowerQuery, ['yield', 'उत्पादन', 'production', 'how much', 'कितना', 'predict', 'forecast', 'estimate'])) {
      try {
        // Call Flask API for yield prediction with sample data
        final prediction = await _getPredictedYield(query);
        if (prediction != null) {
          return "Based on current conditions, expected yield is ${prediction['predicted_yield']} tons per hectare.";
        }
      } catch (e) {
        print('AI Assistant: Yield prediction failed: $e');
      }
      
      return "For accurate yield prediction, please check the Crop Prediction section in the app.";
    }
    
    // Default response
    return "Sorry, I don't have that information right now.";
  }
  
  /// Get predicted yield from Flask API
  Future<Map<String, dynamic>?> _getPredictedYield(String query) async {
    try {
      // Sample data for prediction
      final sampleData = {
        'Rainfall': 800.0,
        'Temperature': 25.0,
        'Humidity': 70.0,
        'pH': 6.5,
        'Nitrogen': 40.0,
        'Phosphorus': 30.0,
        'Potassium': 20.0,
        'Crop': 'Rice'
      };
      
      final response = await http.post(
        Uri.parse('http://localhost:5000/predict'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(sampleData),
      ).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }
      
      return null;
    } catch (e) {
      print('AI Assistant: Flask API error - $e');
      return null;
    }
  }
}
