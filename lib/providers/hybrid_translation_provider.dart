import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/google_translate_service.dart';

class HybridTranslationProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  String _currentLanguage = 'en';
  Map<String, dynamic> _staticTranslations = {};
  bool _isTranslating = false;
  
  // Cache for dynamic translations
  final Map<String, Map<String, String>> _dynamicCache = {};
  
  // Supported languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'हिंदी',
    'gu': 'ગુજરાતી',
    'ta': 'தமிழ்',
  };
  
  String get currentLanguage => _currentLanguage;
  bool get isTranslating => _isTranslating;
  Map<String, String> get availableLanguages => supportedLanguages;
  
  HybridTranslationProvider() {
    _loadLanguagePreference();
  }
  
  /// Load saved language preference and static translations
  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString(_languageKey) ?? 'en';
      await _loadStaticTranslations();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language preference: $e');
    }
  }
  
  /// Load static translations from JSON files
  Future<void> _loadStaticTranslations() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/locales/$_currentLanguage/translation.json'
      );
      _staticTranslations = json.decode(jsonString);
    } catch (e) {
      debugPrint('Error loading static translations: $e');
      // Fallback to English if translation file not found
      if (_currentLanguage != 'en') {
        try {
          final String fallbackString = await rootBundle.loadString(
            'assets/locales/en/translation.json'
          );
          _staticTranslations = json.decode(fallbackString);
        } catch (fallbackError) {
          debugPrint('Error loading fallback translations: $fallbackError');
        }
      }
    }
  }
  
  /// Change language and reload everything
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage != languageCode && supportedLanguages.containsKey(languageCode)) {
      _isTranslating = true;
      notifyListeners();
      
      _currentLanguage = languageCode;
      
      // Save preference
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
      } catch (e) {
        debugPrint('Error saving language preference: $e');
      }
      
      // Reload static translations
      await _loadStaticTranslations();
      
      _isTranslating = false;
      notifyListeners();
    }
  }
  
  /// Get static translation by key
  String t(String key, {Map<String, String>? params}) {
    // Return key if translations not loaded yet
    if (_staticTranslations.isEmpty) {
      return key;
    }
    
    String translation = _staticTranslations[key]?.toString() ?? key;
    
    // Replace parameters if provided
    if (params != null) {
      params.forEach((paramKey, value) {
        translation = translation.replaceAll('{$paramKey}', value);
      });
    }
    
    return translation;
  }
  
  /// Translate dynamic content using Google Translate API
  Future<String> translateText(String text, {String? fromLanguage}) async {
    // Return as-is if current language is English or text is empty
    if (_currentLanguage == 'en' || text.trim().isEmpty) {
      return text;
    }
    
    final from = fromLanguage ?? 'en';
    final cacheKey = '${from}_${_currentLanguage}_$text';
    
    // Check cache first
    if (_dynamicCache[_currentLanguage]?.containsKey(cacheKey) == true) {
      return _dynamicCache[_currentLanguage]![cacheKey]!;
    }
    
    try {
      // Use Google Translate API
      final translated = await GoogleTranslateService.translate(text, _currentLanguage);
      
      // Cache the result
      _dynamicCache[_currentLanguage] ??= {};
      _dynamicCache[_currentLanguage]![cacheKey] = translated;
      
      return translated;
    } catch (e) {
      debugPrint('Translation error: $e');
      return text; // Return original text on error
    }
  }
  
  /// Batch translate multiple texts
  Future<List<String>> translateTexts(List<String> texts, {String? fromLanguage}) async {
    if (_currentLanguage == 'en') {
      return texts;
    }
    
    final List<String> results = [];
    for (String text in texts) {
      final translated = await translateText(text, fromLanguage: fromLanguage);
      results.add(translated);
    }
    return results;
  }
  
  /// Clear dynamic translation cache
  void clearCache() {
    _dynamicCache.clear();
    notifyListeners();
  }
  
  /// Get cache stats for debugging
  Map<String, int> getCacheStats() {
    return _dynamicCache.map((lang, cache) => MapEntry(lang, cache.length));
  }
}
