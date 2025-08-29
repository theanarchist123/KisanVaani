import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../generated/app_localizations.dart';
import '../providers/language_provider.dart';
import 'libre_translate_service.dart';

/// Enhanced Translation Service with comprehensive i18n support
/// Handles both static translations (from .arb files) and dynamic translations (from APIs)
class I18nService {
  /// Get localized string from .arb files using generated AppLocalizations
  static String t(BuildContext context, String key, {Map<String, dynamic>? args}) {
    final localizations = AppLocalizations.of(context);
    
    // Use reflection or a switch statement to get the correct translation
    // This is a simplified version - in a real app you might use code generation
    switch (key) {
      case 'appTitle': return localizations.appTitle;
      case 'hello': return localizations.hello;
      case 'welcome': return localizations.welcome;
      case 'language': return localizations.language;
      case 'selectLanguage': return localizations.selectLanguage;
      case 'english': return localizations.english;
      case 'hindi': return localizations.hindi;
      case 'tamil': return localizations.tamil;
      case 'gujarati': return localizations.gujarati;
      case 'home': return localizations.home;
      case 'farmFeatures': return localizations.farmFeatures;
      case 'govtSchemes': return localizations.govtSchemes;
      case 'settings': return localizations.settings;
      case 'profile': return localizations.profile;
      case 'expenses': return localizations.expenses;
      case 'crops': return localizations.crops;
      case 'weather': return localizations.weather;
      case 'analytics': return localizations.analytics;
      case 'addExpense': return localizations.addExpense;
      case 'checkCrops': return localizations.checkCrops;
      case 'weatherInfo': return localizations.weatherInfo;
      case 'listening': return localizations.listening;
      case 'talkToMe': return localizations.talkToMe;
      case 'youCanSay': return localizations.youCanSay;
      case 'addExpenseExample': return localizations.addExpenseExample;
      case 'checkCropsExample': return localizations.checkCropsExample;
      case 'weatherExample': return localizations.weatherExample;
      case 'farmAnalytics': return localizations.farmAnalytics;
      case 'totalExpenses': return localizations.totalExpenses;
      case 'totalIncome': return localizations.totalIncome;
      case 'profitLoss': return localizations.profitLoss;
      case 'cropHealth': return localizations.cropHealth;
      case 'expenseAnalysis': return localizations.expenseAnalysis;
      case 'cropHealthOverview': return localizations.cropHealthOverview;
      case 'healthy': return localizations.healthy;
      case 'needsAttention': return localizations.needsAttention;
      case 'critical': return localizations.critical;
      case 'seeds': return localizations.seeds;
      case 'fertilizer': return localizations.fertilizer;
      case 'pesticide': return localizations.pesticide;
      case 'labor': return localizations.labor;
      case 'equipment': return localizations.equipment;
      case 'irrigation': return localizations.irrigation;
      case 'myCrops': return localizations.myCrops;
      case 'addCrop': return localizations.addCrop;
      case 'cropName': return localizations.cropName;
      case 'plantingDate': return localizations.plantingDate;
      case 'expectedHarvest': return localizations.expectedHarvest;
      case 'harvestDate': return localizations.harvestDate;
      case 'area': return localizations.area;
      case 'status': return localizations.status;
      case 'save': return localizations.save;
      case 'cancel': return localizations.cancel;
      case 'edit': return localizations.edit;
      case 'delete': return localizations.delete;
      case 'confirm': return localizations.confirm;
      case 'error': return localizations.error;
      case 'success': return localizations.success;
      case 'loading': return localizations.loading;
      case 'retry': return localizations.retry;
      case 'noData': return localizations.noData;
      case 'search': return localizations.search;
      case 'filter': return localizations.filter;
      case 'sort': return localizations.sort;
      case 'next': return localizations.next;
      case 'previous': return localizations.previous;
      case 'finish': return localizations.finish;
      case 'skip': return localizations.skip;
      case 'getStarted': return localizations.getStarted;
      case 'continue': return localizations.continueText;
      case 'back': return localizations.back;
      case 'close': return localizations.close;
      case 'done': return localizations.done;
      case 'apply': return localizations.apply;
      case 'reset': return localizations.reset;
      case 'clear': return localizations.clear;
      case 'selectAll': return localizations.selectAll;
      case 'deselectAll': return localizations.deselectAll;
      case 'shareApp': return localizations.shareApp;
      case 'details': return localizations.details;
      case 'daysLeft': return localizations.daysLeft;
      case 'acres': return localizations.acres;
      
      // Add more keys as needed
      default:
        // If key not found in predefined list, return the key itself
        return key;
    }
  }

  /// Translate dynamic content (API responses, user-generated content, etc.)
  /// Uses LibreTranslate API with caching for offline support
  static Future<String> translateText(
    BuildContext context,
    String text, {
    String? sourceLang,
    String? targetLang,
  }) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    final source = sourceLang ?? 'en'; // Default source language
    final target = targetLang ?? languageProvider.currentLanguage;
    
    return await LibreTranslateService.translateText(text, source, target);
  }

  /// Translate multiple texts in batch
  static Future<List<String>> translateTexts(
    BuildContext context,
    List<String> texts, {
    String? sourceLang,
    String? targetLang,
  }) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    final source = sourceLang ?? 'en';
    final target = targetLang ?? languageProvider.currentLanguage;
    
    return await LibreTranslateService.translateTexts(texts, source, target);
  }

  /// Widget builder for dynamic translations with loading state
  static Widget buildTranslatedText(
    BuildContext context,
    String text, {
    String? sourceLang,
    String? targetLang,
    TextStyle? style,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
  }) {
    return FutureBuilder<String>(
      future: translateText(context, text, sourceLang: sourceLang, targetLang: targetLang),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            text, // Show original text while loading
            style: style?.copyWith(color: style.color?.withOpacity(0.7)),
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
          );
        }
        
        return Text(
          snapshot.data ?? text,
          style: style,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        );
      },
    );
  }

  /// Detect language of given text
  static Future<String> detectLanguage(String text) async {
    return await LibreTranslateService.detectLanguage(text);
  }

  /// Get current language code
  static String getCurrentLanguage(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return languageProvider.currentLanguage;
  }

  /// Get supported languages
  static List<String> getSupportedLanguages() {
    return LanguageProvider.languageNames.keys.toList();
  }

  /// Get language display name
  static String getLanguageDisplayName(String languageCode) {
    return LanguageProvider.languageNames[languageCode] ?? languageCode;
  }

  /// Format currency according to current locale
  static String formatCurrency(BuildContext context, double amount) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    switch (languageProvider.currentLanguage) {
      case 'hi':
      case 'gu':
      case 'ta':
        return '₹${amount.toStringAsFixed(2)}';
      default:
        return '₹${amount.toStringAsFixed(2)}';
    }
  }

  /// Format date according to current locale
  static String formatDate(BuildContext context, DateTime date) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    switch (languageProvider.currentLanguage) {
      case 'hi':
        return '${date.day}/${date.month}/${date.year}';
      case 'gu':
        return '${date.day}/${date.month}/${date.year}';
      case 'ta':
        return '${date.day}/${date.month}/${date.year}';
      default:
        return '${date.month}/${date.day}/${date.year}';
    }
  }

  /// Clear translation cache
  static Future<void> clearCache() async {
    await LibreTranslateService.clearOldCache();
  }

  /// Get cache statistics
  static Future<Map<String, int>> getCacheStats() async {
    return await LibreTranslateService.getCacheStats();
  }
}
