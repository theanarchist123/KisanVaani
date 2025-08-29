import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Service for dynamic text translation using LibreTranslate API
/// Includes offline caching for previously translated content
class LibreTranslateService {
  static const String _baseUrl = 'https://libretranslate.de/translate';
  static const String _cacheKeyPrefix = 'translation_cache_';
  static Database? _database;
  
  /// Language code mappings for LibreTranslate
  static const Map<String, String> _languageCodeMap = {
    'en': 'en',
    'hi': 'hi',
    'gu': 'gu',
    'ta': 'ta',
  };

  /// Initialize the local database for translation caching
  static Future<Database> _initDatabase() async {
    if (_database != null) return _database!;
    
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'translations.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE translations('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'source_text TEXT NOT NULL, '
          'source_lang TEXT NOT NULL, '
          'target_lang TEXT NOT NULL, '
          'translated_text TEXT NOT NULL, '
          'created_at INTEGER NOT NULL, '
          'UNIQUE(source_text, source_lang, target_lang)'
          ')',
        );
      },
    );
    
    return _database!;
  }

  /// Get cached translation from local database
  static Future<String?> _getCachedTranslation(
    String sourceText,
    String sourceLang,
    String targetLang,
  ) async {
    try {
      final db = await _initDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        'translations',
        where: 'source_text = ? AND source_lang = ? AND target_lang = ?',
        whereArgs: [sourceText, sourceLang, targetLang],
        limit: 1,
      );
      
      if (maps.isNotEmpty) {
        return maps.first['translated_text'] as String;
      }
    } catch (e) {
      print('Error getting cached translation: $e');
    }
    return null;
  }

  /// Cache translation in local database
  static Future<void> _cacheTranslation(
    String sourceText,
    String sourceLang,
    String targetLang,
    String translatedText,
  ) async {
    try {
      final db = await _initDatabase();
      await db.insert(
        'translations',
        {
          'source_text': sourceText,
          'source_lang': sourceLang,
          'target_lang': targetLang,
          'translated_text': translatedText,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error caching translation: $e');
    }
  }

  /// Translate text from source language to target language
  /// Returns cached version if available, otherwise calls API
  static Future<String> translateText(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    // Return original text if same language or text is empty
    if (sourceLang == targetLang || text.trim().isEmpty) {
      return text;
    }

    // Check cache first
    final cachedTranslation = await _getCachedTranslation(text, sourceLang, targetLang);
    if (cachedTranslation != null) {
      return cachedTranslation;
    }

    try {
      // Make API call to LibreTranslate
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'source': _languageCodeMap[sourceLang] ?? sourceLang,
          'target': _languageCodeMap[targetLang] ?? targetLang,
          'format': 'text',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['translatedText'] as String;
        
        // Cache the translation
        await _cacheTranslation(text, sourceLang, targetLang, translatedText);
        
        return translatedText;
      } else {
        print('Translation API error: ${response.statusCode} - ${response.body}');
        return text; // Return original text on API failure
      }
    } catch (e) {
      print('Translation error: $e');
      return text; // Return original text on error
    }
  }

  /// Batch translate multiple texts (for efficiency)
  static Future<List<String>> translateTexts(
    List<String> texts,
    String sourceLang,
    String targetLang,
  ) async {
    final results = <String>[];
    
    for (final text in texts) {
      final translation = await translateText(text, sourceLang, targetLang);
      results.add(translation);
    }
    
    return results;
  }

  /// Detect language of given text (basic implementation)
  static Future<String> detectLanguage(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.de/detect'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'q': text}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final detectedLang = data[0]['language'] as String;
        
        // Map back to our language codes
        for (final entry in _languageCodeMap.entries) {
          if (entry.value == detectedLang) {
            return entry.key;
          }
        }
        return detectedLang;
      }
    } catch (e) {
      print('Language detection error: $e');
    }
    
    return 'en'; // Default to English
  }

  /// Clear old cached translations (older than 30 days)
  static Future<void> clearOldCache() async {
    try {
      final db = await _initDatabase();
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
      
      await db.delete(
        'translations',
        where: 'created_at < ?',
        whereArgs: [thirtyDaysAgo],
      );
    } catch (e) {
      print('Error clearing old cache: $e');
    }
  }

  /// Get cache statistics
  static Future<Map<String, int>> getCacheStats() async {
    try {
      final db = await _initDatabase();
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM translations')) ?? 0;
      
      return {
        'total_translations': count,
        'database_version': 1,
      };
    } catch (e) {
      print('Error getting cache stats: $e');
      return {'total_translations': 0, 'database_version': 0};
    }
  }
}
