import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/google_translation_service.dart';
import '../services/libre_translate_service.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _firstLaunchKey = 'first_launch_completed';
  
  String _currentLanguage = 'hi';
  bool _isFirstLaunch = true;
  final GoogleTranslationService _translationService = GoogleTranslationService();

  // Supported languages with their display names
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'gu': 'ગુજરાતી',
    'ta': 'தமிழ்',
  };

  // Supported locales for Flutter localization
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('hi', 'IN'),
    Locale('gu', 'IN'),
    Locale('ta', 'IN'),
  ];

  LanguageProvider() {
    _loadLanguagePreference();
  }

  String get currentLanguage => _currentLanguage;
  bool get isFirstLaunch => _isFirstLaunch;
  
  Locale get currentLocale {
    switch (_currentLanguage) {
      case 'hi':
        return const Locale('hi', 'IN');
      case 'gu':
        return const Locale('gu', 'IN');
      case 'ta':
        return const Locale('ta', 'IN');
      default:
        return const Locale('hi', 'IN');
    }
  }

  List<String> get supportedLanguages => languageNames.keys.toList();

  String getLanguageDisplayName(String languageCode) {
    return languageNames[languageCode] ?? 'Unknown';
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString(_languageKey) ?? 'hi';
      _isFirstLaunch = !(prefs.getBool(_firstLaunchKey) ?? false);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language preference: $e');
      _currentLanguage = 'en';
      _isFirstLaunch = true;
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage != languageCode && languageNames.containsKey(languageCode)) {
      final oldLanguage = _currentLanguage;
      _currentLanguage = languageCode;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
        
        // Clear old translation cache when language changes
        if (oldLanguage != languageCode) {
          await LibreTranslateService.clearOldCache();
        }
        
        // Notify all listeners to rebuild with new language
        notifyListeners();
        
        debugPrint('Language changed from $oldLanguage to $languageCode');
      } catch (e) {
        debugPrint('Error saving language preference: $e');
        // Revert on error
        _currentLanguage = oldLanguage;
      }
    }
  }

  Future<void> completeFirstLaunch() async {
    _isFirstLaunch = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstLaunchKey, true);
      notifyListeners();
    } catch (e) {
      debugPrint('Error completing first launch: $e');
    }
  }

  // Get translation service instance
  GoogleTranslationService get translationService => _translationService;

  /// Translate dynamic content using LibreTranslate
  Future<String> translateText(String text, {String? sourceLang, String? targetLang}) async {
    final source = sourceLang ?? 'en';
    final target = targetLang ?? _currentLanguage;
    
    return await LibreTranslateService.translateText(text, source, target);
  }

  /// Batch translate texts
  Future<List<String>> translateTexts(List<String> texts, {String? sourceLang, String? targetLang}) async {
    final source = sourceLang ?? 'en';
    final target = targetLang ?? _currentLanguage;
    
    return await LibreTranslateService.translateTexts(texts, source, target);
  }

  /// Get cache statistics
  Future<Map<String, int>> getCacheStats() async {
    return await LibreTranslateService.getCacheStats();
  }

  /// Clear translation cache
  Future<void> clearCache() async {
    await LibreTranslateService.clearOldCache();
  }
}
