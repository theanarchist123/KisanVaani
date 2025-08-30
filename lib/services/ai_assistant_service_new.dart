import 'dart:convert';
import 'package:http/http.dart' as http;

class AIAssistantService {
  
  /// Helper method to check if query contains any of the keywords
  bool _containsAny(String query, List<String> keywords) {
    return keywords.any((keyword) => query.contains(keyword.toLowerCase()));
  }
  
  /// Process user query following farmer-friendly AI assistant behavior:
  /// - Short, clear, correct answers (under 3 sentences)
  /// - Farmer-friendly language (simple words, practical answers)
  /// - Accurate intent recognition
  Future<String> processQuery(String userQuery) async {
    try {
      print('AI Farmer Assistant: Processing query: $userQuery');
      
      final response = await _generateFarmerResponse(userQuery);
      print('AI Farmer Assistant: Generated response: $response');
      
      return response;
    } catch (e) {
      print('AI Farmer Assistant: Error processing query: $e');
      return "Sorry, I don't have that information right now.";
    }
  }
  
  /// Generate farmer-friendly response based on user query
  /// Following ElevenLabs AI assistant behavior guidelines
  Future<String> _generateFarmerResponse(String query) async {
    final lowerQuery = query.toLowerCase();
    
    print('AI Farmer Assistant: Analyzing query: "$lowerQuery"');
    
    // 1. ADD EXPENSE QUERIES - Extract category and amount
    if (_containsAny(lowerQuery, ['खरीदा', 'bought', 'खर्च', 'expense', 'लिया', 'purchased']) && 
        _containsAny(lowerQuery, ['रुपए', 'rupees', '₹', 'पैसे', 'money', 'टका'])) {
      
      // Extract amount if mentioned
      final amountMatch = RegExp(r'(\d+)').firstMatch(lowerQuery);
      final amount = amountMatch?.group(1) ?? '500';
      
      String category = 'अन्य';
      if (_containsAny(lowerQuery, ['बीज', 'seed', 'seeds'])) category = 'बीज';
      else if (_containsAny(lowerQuery, ['दवाई', 'medicine', 'दवा', 'pesticide'])) category = 'दवाई';
      else if (_containsAny(lowerQuery, ['खाद', 'fertilizer', 'उर्वरक', 'manure'])) category = 'खाद';
      else if (_containsAny(lowerQuery, ['पेट्रोल', 'petrol', 'diesel', 'डीजल', 'fuel'])) category = 'ईंधन';
      else if (_containsAny(lowerQuery, ['मजदूर', 'labour', 'worker', 'काम'])) category = 'मजदूरी';
      
      return "Got it. I added an expense: $category – ₹$amount.";
    }
    
    // 2. CROP STATUS QUERIES - Check specific crops
    if (_containsAny(lowerQuery, ['फसल', 'crop', 'टमाटर', 'tomato', 'धान', 'rice', 'गेहूं', 'wheat', 'प्याज', 'onion', 'कैसी', 'how', 'कैसे', 'growing', 'बढ़', 'status'])) {
      
      String cropName = 'crops';
      if (_containsAny(lowerQuery, ['टमाटर', 'tomato', 'tomatoes'])) cropName = 'tomatoes';
      else if (_containsAny(lowerQuery, ['धान', 'rice', 'paddy'])) cropName = 'rice';
      else if (_containsAny(lowerQuery, ['गेहूं', 'wheat'])) cropName = 'wheat';
      else if (_containsAny(lowerQuery, ['प्याज', 'onion', 'onions'])) cropName = 'onions';
      
      return "Your $cropName are growing well. Expected harvest in 2 weeks.";
    }
    
    // 3. WEATHER QUERIES - Current weather info
    if (_containsAny(lowerQuery, ['मौसम', 'weather', 'आज', 'today', 'बारिश', 'rain', 'धूप', 'sun', 'तापमान', 'temperature'])) {
      return "Today's weather is 32°C, sunny, with no rain expected.";
    }
    
    // 4. GOVERNMENT SCHEMES - Simple scheme info
    if (_containsAny(lowerQuery, ['योजना', 'scheme', 'सब्सिडी', 'subsidy', 'सरकार', 'government', 'पीएम', 'pm', 'किसान', 'kisan'])) {
      return "Main schemes: PM-KISAN (₹6000/year), Crop Insurance, KCC Card. Check Government Schemes section.";
    }
    
    // 5. MARKET PRICES - Current market rates
    if (_containsAny(lowerQuery, ['मंडी', 'market', 'भाव', 'price', 'दाम', 'rate', 'कीमत', 'बेचना', 'sell'])) {
      return "Today's market rates: Wheat ₹2200/quintal, Rice ₹1850/quintal. Check Market Trends for updates.";
    }
    
    // 6. FARMING ADVICE - Quick tips
    if (_containsAny(lowerQuery, ['खेती', 'farming', 'कैसे', 'how', 'तरीका', 'method', 'सलाह', 'advice', 'टिप्स', 'tips'])) {
      return "For successful farming: Plant on time, use quality seeds, water regularly. Check Crop Guide section.";
    }
    
    // 7. PEST/DISEASE - Quick solutions
    if (_containsAny(lowerQuery, ['कीट', 'pest', 'रोग', 'disease', 'बीमारी', 'कीड़े', 'insects', 'दवाई', 'spray'])) {
      return "For pest control: Spray neem oil, check crops regularly. Contact expert for serious problems.";
    }
    
    // 8. IRRIGATION - Water management
    if (_containsAny(lowerQuery, ['पानी', 'water', 'सिंचाई', 'irrigation', 'कब', 'when', 'कितना', 'how much'])) {
      return "Water early morning or evening, check soil moisture. Drip irrigation works better.";
    }
    
    // 9. GREETINGS - Simple responses
    if (_containsAny(lowerQuery, ['हैलो', 'hello', 'नमस्कार', 'नमस्ते', 'hi', 'hey'])) {
      return "Hello! I'm your farming assistant. Ask me about crops, weather, or expenses.";
    }
    
    // 10. HELP QUERIES
    if (_containsAny(lowerQuery, ['मदद', 'help', 'सहायता', 'assistance'])) {
      return "I can help with: expenses, crop status, weather, market prices, and farming tips. What do you need?";
    }
    
    // 11. SESSION ENDING
    if (_containsAny(lowerQuery, ['बंद', 'close', 'stop', 'समाप्त', 'end', 'bye', 'goodbye'])) {
      return "Okay, ending our chat. Talk to me anytime.";
    }
    
    // DEFAULT - When intent is unclear
    return "Sorry, I don't have that information right now.";
  }
  
  /// Get error response for technical issues
  String _getErrorResponse() {
    return "Sorry, I don't have that information right now.";
  }
}
