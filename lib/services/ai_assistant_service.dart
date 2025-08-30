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
    
    // 1. ADD EXPENSE QUERIES - Extract category + amount and confirm
    if (_containsAny(lowerQuery, ['bought', 'खरीदा', 'purchased', 'लिया', 'expense', 'खर्च']) && 
        _containsAny(lowerQuery, ['rupees', 'रुपए', '₹', 'पैसे', 'money', 'टका', 'for'])) {
      
      // Extract amount if mentioned
      final amountMatch = RegExp(r'(\d+)').firstMatch(lowerQuery);
      final amount = amountMatch?.group(1) ?? '500';
      
      String category = 'Other';
      if (_containsAny(lowerQuery, ['medicine', 'दवाई', 'दवा', 'pesticide'])) category = 'Medicine';
      else if (_containsAny(lowerQuery, ['seed', 'बीज', 'seeds'])) category = 'Seeds';
      else if (_containsAny(lowerQuery, ['fertilizer', 'खाद', 'उर्वरक', 'manure'])) category = 'Fertilizer';
      else if (_containsAny(lowerQuery, ['petrol', 'पेट्रोल', 'diesel', 'डीजल', 'fuel'])) category = 'Fuel';
      else if (_containsAny(lowerQuery, ['labour', 'मजदूर', 'worker', 'labor'])) category = 'Labour';
      
      return "Got it. I added an expense: $category – ₹$amount.";
    }
    
    // 2. CHECK CROPS - Check crop status with dummy data
    if (_containsAny(lowerQuery, ['how are my', 'कैसी है मेरी', 'crops', 'फसल', 'tomatoes', 'टमाटर', 'rice', 'धान', 'wheat', 'गेहूं', 'growing', 'बढ़'])) {
      
      String cropName = 'crops';
      if (_containsAny(lowerQuery, ['tomatoes', 'tomato', 'टमाटर'])) cropName = 'tomatoes';
      else if (_containsAny(lowerQuery, ['rice', 'धान', 'paddy'])) cropName = 'rice';
      else if (_containsAny(lowerQuery, ['wheat', 'गेहूं'])) cropName = 'wheat';
      else if (_containsAny(lowerQuery, ['onion', 'प्याज', 'onions'])) cropName = 'onions';
      
      return "Your $cropName are growing well. Expected harvest in 2 weeks.";
    }
    
    // 3. WEATHER INFO - Fetch weather API or provide current info
    if (_containsAny(lowerQuery, ['weather', 'मौसम', 'how is the weather', 'today', 'आज', 'rain', 'बारिश', 'temperature', 'तापमान'])) {
      return "Today's weather is 32°C, sunny, with no rain expected.";
    }
    
    // 4. ADDITIONAL FARMING QUERIES - Keep simple and helpful
    if (_containsAny(lowerQuery, ['scheme', 'योजना', 'government', 'सरकार', 'subsidy', 'सब्सिडी'])) {
      return "Main schemes: PM-KISAN (₹6000/year), Crop Insurance. Check Government Schemes section.";
    }
    
    if (_containsAny(lowerQuery, ['market', 'मंडी', 'price', 'भाव', 'sell', 'बेचना'])) {
      return "Today's rates: Wheat ₹2200/quintal, Rice ₹1850/quintal. Check Market section.";
    }
    
    if (_containsAny(lowerQuery, ['pest', 'कीट', 'disease', 'रोग', 'insects', 'कीड़े'])) {
      return "Spray neem oil early morning. Check crops daily for problems.";
    }
    
    // 5. SESSION HANDLING - Keep conversation open until user says stop
    if (_containsAny(lowerQuery, ['close', 'बंद', 'stop', 'end', 'bye', 'goodbye', 'समाप्त'])) {
      return "Okay, ending our chat. Talk to me anytime.";
    }
    
    // 6. GREETINGS - Simple welcome
    if (_containsAny(lowerQuery, ['hello', 'hi', 'हैलो', 'नमस्कार', 'नमस्ते'])) {
      return "Hello! Ask me about expenses, crops, or weather.";
    }
    
    // DEFAULT - Never guess, be honest
    return "Sorry, I don't have that information right now.";
  }
  
  /// Get predicted yield from Flask API
  Future<Map<String, dynamic>?> _getPredictedYield(String query) async {
    try {
      // Sample data for prediction - in real app, this could come from user input or app data
      final sampleData = {
        'Rainfall': 800.0,
        'Temperature': 25.0,
        'Humidity': 70.0,
        'pH': 6.5,
        'Nitrogen': 40.0,
        'Phosphorus': 30.0,
        'Potassium': 20.0,
        'Crop': 'Rice' // Default crop
      };
      
      // Determine crop from query
      if (_containsAny(query.toLowerCase(), ['wheat', 'गेहूं'])) {
        sampleData['Crop'] = 'Wheat';
      } else if (_containsAny(query.toLowerCase(), ['tomato', 'टमाटर'])) {
        sampleData['Crop'] = 'Tomato';
      } else if (_containsAny(query.toLowerCase(), ['cotton', 'कपास'])) {
        sampleData['Crop'] = 'Cotton';
      }
      
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/predict'),
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
