import 'dart:convert';
import 'package:http/http.dart' as http;

c    
    // 4. GOVERNMENT SCHEMES - Simple scheme info
    if (_containsAny(lowerQuery, ['योजना', 'scheme', 'सब्सिडी', 'subsidy', 'सरकार', 'government', 'पीएम', 'pm', 'किसान', 'kisan'])) {
      return "मुख्य योजनाएं: PM-KISAN (₹6000/साल), फसल बीमा, KCC कार्ड। ऐप में Government Schemes देखें।";
    }
    
    // 5. MARKET PRICES - Current market rates
    if (_containsAny(lowerQuery, ['मंडी', 'market', 'भाव', 'price', 'दाम', 'rate', 'कीमत', 'बेचना', 'sell'])) {
      return "आज के मंडी भाव: गेहूं ₹2200/क्विंटल, धान ₹1850/क्विंटल। Market Trends में अपडेट देखें।";
    }
    
    // 6. FARMING ADVICE - Quick tips
    if (_containsAny(lowerQuery, ['खेती', 'farming', 'कैसे', 'how', 'तरीका', 'method', 'सलाह', 'advice', 'टिप्स', 'tips'])) {
      return "सफल खेती के लिए: सही समय पर बुआई, गुणवत्ता वाले बीज, नियमित सिंचाई। Crop Guide देखें।";
    }
    
    // 7. PEST/DISEASE - Quick solutions
    if (_containsAny(lowerQuery, ['कीट', 'pest', 'रोग', 'disease', 'बीमारी', 'कीड़े', 'insects', 'दवाई', 'spray'])) {
      return "कीट-रोग के लिए: नीम का तेल स्प्रे करें, नियमित निरीक्षण करें। गंभीर समस्या में विशेषज्ञ से संपर्क करें।";
    }
    
    // 8. IRRIGATION - Water management
    if (_containsAny(lowerQuery, ['पानी', 'water', 'सिंचाई', 'irrigation', 'कब', 'when', 'कितना', 'how much'])) {
      return "सिंचाई: सुबह या शाम को करें, मिट्टी की नमी चेक करें। ड्रिप सिंचाई बेहतर है।";
    }
    
    // 9. GREETINGS - Simple responses
    if (_containsAny(lowerQuery, ['हैलो', 'hello', 'नमस्कार', 'नमस्ते', 'hi', 'कैसे हो', 'how are you'])) {
      return "नमस्कार किसान भाई! मैं आपकी खेती में मदद के लिए यहां हूं। कोई सवाल पूछें।";
    }
    
    // 10. HELP QUERIES
    if (_containsAny(lowerQuery, ['मदद', 'help', 'सहायता', 'कैसे काम करता', 'how does it work'])) {
      return "मैं आपकी मदद कर सकता हूं: खर्च जोड़ना, फसल की जानकारी, मौसम, मंडी भाव। बस पूछें!";
    }
    
    // DEFAULT RESPONSE - When information is not available
    return "माफ़ करें, मेरे पास यह जानकारी अभी उपलब्ध नहीं है।";
  }
  
  /// Get error response following farmer-friendly guidelines
  String _getErrorResponse() {
    return "माफ़ करें, मैं आपका सवाल समझ नहीं पाया। कृपया दोबारा पूछें।";
  }
  
  /// Handle session ending
  String getSessionEndResponse() {
    return "ठीक है, बातचीत समाप्त कर रहा हूं। कभी भी मुझसे बात कर सकते हैं।";
  }antService {
  
  /// Helper method to check if query contains any of the keywords
  bool _containsAny(String query, List<String> keywords) {
    return keywords.any((keyword) => query.contains(keyword.toLowerCase()));
  }
  
  /// Process user query and generate agricultural advice
  /// Uses farmer-friendly AI assistant behavior with short, accurate responses
  Future<String> processQuery(String userQuery) async {
    try {
      print('AI Assistant: Processing farmer query: $userQuery');
      
      final response = await _generateFarmerResponse(userQuery);
      print('AI Assistant: Generated response: ${response.substring(0, response.length > 100 ? 100 : response.length)}...');
      
      return response;
    } catch (e) {
      print('AI Assistant: Error processing query: $e');
      return _getErrorResponse();
    }
  }
  
  /// Generate farmer-friendly response based on user query
  /// Following ElevenLabs AI assistant behavior guidelines
  Future<String> _generateFarmerResponse(String query) async {
    final lowerQuery = query.toLowerCase();
    
    print('AI Farmer Assistant: Analyzing query: "$lowerQuery"');
    
    // 1. ADD EXPENSE QUERIES - Extract category and amount
    if (_containsAny(lowerQuery, ['खरीदा', 'bought', 'खर्च', 'expense', 'पैसे', 'money', 'रुपए', 'rupees', '₹']) && 
        _containsAny(lowerQuery, ['बीज', 'seed', 'दवाई', 'medicine', 'खाद', 'fertilizer', 'पेट्रोल', 'petrol', 'diesel'])) {
      
      // Extract amount if mentioned
      final amountMatch = RegExp(r'(\d+)').firstMatch(lowerQuery);
      final amount = amountMatch?.group(1) ?? '0';
      
      String category = 'अन्य';
      if (_containsAny(lowerQuery, ['बीज', 'seed'])) category = 'बीज';
      else if (_containsAny(lowerQuery, ['दवाई', 'medicine', 'दवा'])) category = 'दवाई';
      else if (_containsAny(lowerQuery, ['खाद', 'fertilizer', 'उर्वरक'])) category = 'खाद';
      else if (_containsAny(lowerQuery, ['पेट्रोल', 'petrol', 'diesel', 'डीजल'])) category = 'ईंधन';
      
      return "समझ गया। मैंने खर्च जोड़ दिया: $category – ₹$amount।";
    }
    
    // 2. CROP STATUS QUERIES - Check specific crops
    if (_containsAny(lowerQuery, ['फसल', 'crop', 'टमाटर', 'tomato', 'धान', 'rice', 'गेहूं', 'wheat', 'प्याज', 'onion', 'कैसी', 'how', 'कैसे', 'growing'])) {
      
      String cropName = 'फसल';
      if (_containsAny(lowerQuery, ['टमाटर', 'tomato'])) cropName = 'टमाटर';
      else if (_containsAny(lowerQuery, ['धान', 'rice'])) cropName = 'धान';
      else if (_containsAny(lowerQuery, ['गेहूं', 'wheat'])) cropName = 'गेहूं';
      else if (_containsAny(lowerQuery, ['प्याज', 'onion'])) cropName = 'प्याज';
      
      return "आपकी $cropName अच्छी बढ़ रही है। अनुमानित फसल 2 सप्ताह में तैयार होगी।";
    }
    
    // 3. WEATHER QUERIES - Current weather info
    if (_containsAny(lowerQuery, ['मौसम', 'weather', 'आज', 'today', 'बारिश', 'rain', 'धूप', 'sun', 'तापमान', 'temperature'])) {
      return "आज का मौसम 32°C है, धूप है, बारिश की संभावना नहीं है।";
    }
      return '''
आज का मौसम:
• दिन का तापमान: 28-32°C
• रात का तापमान: 22-25°C  
• हवा की गति: 10-15 किमी/घंटा
• बारिश की संभावना: 30%
• आर्द्रता: 65-70%

सुझाव: फसल में पानी की जरूरत हो तो शाम को सिंचाई करें। आज धूप तेज रहेगी।

मौसम की अपडेट के लिए Weather सेक्शन देखें। 🌤️
''';
    }
    
    // Enhanced keyword matching for crops
    if (_containsAny(lowerQuery, ['फसल', 'crop', 'खेती', 'farming', 'उगाना', 'grow', 'बोना', 'plant', 'काटना', 'harvest', 'धान', 'गेहूं', 'मक्का', 'सब्जी', 'vegetable'])) {
      return '''
फसल की संपूर्ण जानकारी:

🌱 बुआई:
• सही समय और मौसम का चुनाव करें
• गुणवत्ता वाले बीज का उपयोग करें
• मिट्टी की तैयारी अच्छी तरह करें

🌿 देखभाल:
• नियमित सिंचाई करें
• खरपतवार हटाते रहें
• जैविक खाद का प्रयोग करें

💰 फायदा:
• सही समय पर फसल काटें
• मंडी के भाव चेक करें

किसान वाणी में Crop Guide देखें! 🌾
''';
    }
    
    // Enhanced keyword matching for government schemes  
    if (_containsAny(lowerQuery, ['योजना', 'scheme', 'सब्सिडी', 'subsidy', 'सरकार', 'government', 'पीएम', 'pm', 'किसान', 'kisan', 'बीमा', 'insurance', 'क्रेडिट', 'credit', 'लोन', 'loan'])) {
      return '''
🏛️ मुख्य सरकारी योजनाएं:

💰 PM-KISAN:
• सालाना ₹6000 की सहायता
• तीन किस्तों में मिलता है

🛡️ फसल बीमा:
• प्राकृतिक आपदा से सुरक्षा
• कम प्रीमियम में बीमा

📋 अन्य योजनाएं:
• मृदा स्वास्थ्य कार्ड
• KCC किसान क्रेडिट कार्ड
• सोलर पंप सब्सिडी

आवेदन करने के लिए Government Schemes सेक्शन देखें! 📱
''';
    }
    
    // Enhanced keyword matching for seeds
    if (_containsAny(lowerQuery, ['बीज', 'seed', 'किस्म', 'variety', 'उन्नत', 'hybrid', 'हाइब्रिड', 'देसी', 'local'])) {
      return '''
बीज और किस्मों की जानकारी:
• उन्नत किस्मों का चुनाव करें
• बीज उपचार जरूरी है
• प्रमाणित बीज ही खरीदें
• स्थानीय कृषि केंद्र से सलाह लें

बेहतर उत्पादन के लिए गुणवत्ता वाले बीज चुनें।
''';
    }
    
    // Enhanced keyword matching for pest/disease
    if (_containsAny(lowerQuery, ['कीट', 'pest', 'रोग', 'disease', 'बीमारी', 'infection', 'कीटनाशक', 'pesticide', 'दवाई', 'medicine', 'स्प्रे', 'spray'])) {
      return '''
कीट-रोग प्रबंधन:
• नियमित खेत का निरीक्षण करें
• जैविक कीटनाशक का उपयोग करें
• फसल चक्र अपनाएं
• साफ-सफाई रखें

समस्या गंभीर होने पर कृषि विशेषज्ञ से संपर्क करें।
''';
    }
    
    // Enhanced keyword matching for market/selling
    if (_containsAny(lowerQuery, ['मार्केट', 'market', 'बेचना', 'sell', 'मंडी', 'भाव', 'price', 'rate', 'दाम', 'cost', 'कीमत', 'selling'])) {
      return '''
बाजार की जानकारी:
• मंडी भाव चेक करें
• e-NAM पोर्टल का उपयोग करें
• उचित समय पर बेचें
• गुणवत्ता बनाए रखें

ऐप में Market Trends देखें।
''';
    }
    
    // Enhanced keyword matching for irrigation
    if (_containsAny(lowerQuery, ['पानी', 'water', 'सिंचाई', 'irrigation', 'छिड़काव', 'sprinkler', 'ड्रिप', 'drip', 'नहर', 'canal', 'कुआं', 'well', 'बोरवेल', 'borewell'])) {
      return '''
सिंचाई प्रबंधन:
• ड्रिप सिंचाई अपनाएं
• पानी की बचत करें
• मिट्टी की नमी चेक करें
• सही समय पर सिंचाई करें

जल संरक्षण किसान की जिम्मेदारी है।
''';
    }
    
    // Enhanced keyword matching for soil/fertilizer
    if (_containsAny(lowerQuery, ['मिट्टी', 'soil', 'खाद', 'fertilizer', 'उर्वरक', 'compost', 'कंपोस्ट', 'गोबर', 'manure', 'यूरिया', 'urea', 'डीएपी', 'dap'])) {
      return '''
मिट्टी की देखभाल:
• मृदा परीक्षण कराएं
• जैविक खाद का उपयोग करें
• मिट्टी में पोषक तत्व बनाए रखें
• भूमि की उर्वरता बढ़ाएं

स्वस्थ मिट्टी = अच्छी फसल
''';
    }
    
    // Handle greeting and introduction queries
    if (_containsAny(lowerQuery, ['हैलो', 'hello', 'नमस्कार', 'नमस्ते', 'namaste', 'hi', 'hey', 'कैसे हो', 'how are you', 'क्या हाल', 'कौन हो', 'who are you'])) {
      return '''
नमस्कार किसान भाई! 🙏

मैं किसान वाणी का AI सहायक हूं। मैं आपकी खेती में मदद करने के लिए यहां हूं।

आप मुझसे पूछ सकते हैं:
• "आज मौसम कैसा है?"
• "धान की फसल कैसे उगाएं?"
• "कौन सी सरकारी योजनाएं हैं?"
• "मंडी में आज के भाव क्या हैं?"

मैं हिंदी और अंग्रेजी दोनों भाषाओं में आपके सवालों का जवाब दे सकता हूं! 🌾
''';
    }
    
    // Handle help queries
    if (_containsAny(lowerQuery, ['मदद', 'help', 'सहायता', 'assistance', 'कैसे', 'how', 'क्या करें', 'what to do', 'गाइड', 'guide'])) {
      return '''
🆘 किसान वाणी मदद केंद्र:

📱 ऐप के मुख्य सेक्शन:
• Home - मुख्य डैशबोर्ड
• Weather - मौसम की जानकारी
• Crops - फसल गाइड
• Government Schemes - सरकारी योजनाएं
• Market - बाजार के भाव

🎤 मुझसे सवाल पूछने के तरीके:
• माइक दबाकर बोलें
• या टेक्स्ट में लिखें

कोई भी खेती से जुड़ा सवाल पूछें, मैं जवाब दूंगा! 💚
''';
    }
    
    // Handle general farming questions
    if (_containsAny(lowerQuery, ['खेती', 'farming', 'कृषि', 'agriculture', 'किसान', 'farmer', 'जमीन', 'land', 'खेत', 'field'])) {
      return '''
🌾 सामान्य कृषि जानकारी:

✅ सफल खेती के मूल सिद्धांत:
• सही समय पर बुआई
• गुणवत्ता वाले बीज का चुनाव
• उचित सिंचाई व्यवस्था
• संतुलित उर्वरक का प्रयोग
• कीट-रोग से बचाव

📊 आधुनिक तकनीक:
• ड्रिप सिंचाई
• जैविक खेती
• मशीनीकरण
• मृदा परीक्षण

अधिक जानकारी के लिए Crop Guide देखें! 🚜
''';
    }

    // Default intelligent response for unmatched queries
    return '''
🤔 मैं आपके सवाल को समझने की कोशिश कर रहा हूं...

आपने पूछा: "$query"

💡 शायद आप इनमें से कुछ जानना चाहते हैं:

🌤️ मौसम: "आज मौसम कैसा है?"
🌱 फसल: "धान कैसे उगाएं?"
🏛️ योजनाएं: "सरकारी योजनाओं के बारे में बताएं"
💰 मंडी: "आज के भाव क्या हैं?"
🐛 कीट-रोग: "फसल में कीड़े लगे हैं"
💧 सिंचाई: "पानी कब देना चाहिए?"

कृपया और स्पष्ट सवाल पूछें, मैं आपकी बेहतर मदद कर सकूंगा! 🙏
''';
  }
  
  /// Get default response for errors
  String _getDefaultResponse() {
    return '''
😔 क्षमा करें, कुछ तकनीकी समस्या हुई है।

🔄 कृपया दोबारा कोशिश करें या फिर:
• ऐप के अलग सेक्शन देखें
• माइक बटन दबाकर दोबारा पूछें
• टेक्स्ट में सवाल लिखें

किसान वाणी टीम आपकी सेवा में है! �
''';
  }
}
