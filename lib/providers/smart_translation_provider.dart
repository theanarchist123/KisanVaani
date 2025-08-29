import 'package:flutter/material.dart';
import '../services/google_translate_service.dart';

class SmartTranslationProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  bool _isTranslating = false;
  
  String get currentLanguage => _currentLanguage;
  bool get isTranslating => _isTranslating;
  
  // Language codes mapping
  static const Map<String, String> languageCodes = {
    'English': 'en',
    'Hindi': 'hi',
    'Gujarati': 'gu',
    'Tamil': 'ta',
    'Bengali': 'bn',
    'Telugu': 'te',
    'Marathi': 'mr',
    'Kannada': 'kn',
    'Malayalam': 'ml',
    'Punjabi': 'pa',
  };
  
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'Hindi', 
    'gu': 'Gujarati',
    'ta': 'Tamil',
    'bn': 'Bengali',
    'te': 'Telugu',
    'mr': 'Marathi',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'pa': 'Punjabi',
  };
  
  // Change language and trigger rebuild
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _isTranslating = true;
      notifyListeners();
      
      _currentLanguage = languageCode;
      
      _isTranslating = false;
      notifyListeners();
    }
  }
  
  // Smart translate method - automatically translates if not English
  Future<String> t(String text) async {
    if (_currentLanguage == 'en' || text.trim().isEmpty) {
      return text;
    }
    
    return await GoogleTranslateService.translate(text, _currentLanguage);
  }
  
  // Get language name
  String getLanguageName(String code) {
    return languageNames[code] ?? 'English';
  }
  
  // Get available languages
  List<MapEntry<String, String>> get availableLanguages {
    return languageCodes.entries.toList();
  }
}
