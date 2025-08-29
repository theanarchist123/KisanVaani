import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class GoogleTranslationService {
  static const String _apiKey = 'AIzaSyDUBj-tIvUxCsai4qfCB4AbY7NwgC-SQlw';
  static const String _baseUrl = 'https://translation.googleapis.com/language/translate/v2';
  
  // Language mappings
  static const Map<String, String> _languageCodes = {
    'English': 'en',
    'Hindi': 'hi',
    'Tamil': 'ta',
    'Gujarati': 'gu',
  };
  
  static const Map<String, String> _cachePrefix = {
    'en': 'cache_en_',
    'hi': 'cache_hi_',
    'ta': 'cache_ta_',
    'gu': 'cache_gu_',
  };

  // Get language code from language name
  static String getLanguageCode(String languageName) {
    return _languageCodes[languageName] ?? 'en';
  }

  // Get language name from code
  static String getLanguageName(String languageCode) {
    return _languageCodes.entries
        .firstWhere((entry) => entry.value == languageCode, 
                   orElse: () => const MapEntry('English', 'en'))
        .key;
  }

  // Get all supported languages
  static List<String> getSupportedLanguages() {
    return _languageCodes.keys.toList();
  }

  // Check cache for translation
  static Future<String?> _getCachedTranslation(String text, String targetLanguage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_cachePrefix[targetLanguage]}${text.hashCode}';
      return prefs.getString(cacheKey);
    } catch (e) {
      debugPrint('Error getting cached translation: $e');
      return null;
    }
  }

  // Save translation to cache
  static Future<void> _cacheTranslation(String originalText, String translatedText, String targetLanguage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_cachePrefix[targetLanguage]}${originalText.hashCode}';
      await prefs.setString(cacheKey, translatedText);
    } catch (e) {
      debugPrint('Error caching translation: $e');
    }
  }

  // Translate text using Google Translate API
  static Future<String> translateText(String text, String targetLanguage) async {
    // Return original text if target is English or text is empty
    if (targetLanguage == 'en' || text.trim().isEmpty) {
      return text;
    }

    // Check cache first
    final cached = await _getCachedTranslation(text, targetLanguage);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
          'source': 'en', // Assume source is English
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['data']['translations'][0]['translatedText'] as String;
        
        // Cache the translation
        await _cacheTranslation(text, translatedText, targetLanguage);
        
        return translatedText;
      } else {
        debugPrint('Translation API error: ${response.statusCode} - ${response.body}');
        return text; // Return original text on error
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      return text; // Return original text on error
    }
  }

  // Translate multiple texts in batch
  static Future<List<String>> translateBatch(List<String> texts, String targetLanguage) async {
    if (targetLanguage == 'en') {
      return texts;
    }

    final List<String> results = [];
    for (String text in texts) {
      final translated = await translateText(text, targetLanguage);
      results.add(translated);
    }
    return results;
  }

  // Clear translation cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (String key in keys) {
        if (key.startsWith('cache_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Error clearing translation cache: $e');
    }
  }

  // Get cache size (number of cached translations)
  static Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      return keys.where((key) => key.startsWith('cache_')).length;
    } catch (e) {
      debugPrint('Error getting cache size: $e');
      return 0;
    }
  }
}
