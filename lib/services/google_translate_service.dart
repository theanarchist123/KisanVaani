import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GoogleTranslateService {
  static const String _apiKey = 'AIzaSyDUBj-tIvUxCsai4qfCB4AbY7NwgC-SQlw';
  static const String _baseUrl = 'https://translation.googleapis.com/language/translate/v2';
  
  static Database? _database;
  static final Map<String, String> _memoryCache = {};
  
    // Initialize the database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  static Future<Database> _initDatabase() async {
    return await openDatabase(
      'translations.db',
      version: 2,  // Increment version to trigger migration
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE translations(id INTEGER PRIMARY KEY, source_text TEXT, source_lang TEXT, target_lang TEXT, translated_text TEXT, created_at INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Check if column exists before adding it
          var tableInfo = await db.rawQuery("PRAGMA table_info(translations)");
          bool hasSourceLang = tableInfo.any((column) => column['name'] == 'source_lang');
          
          if (!hasSourceLang) {
            await db.execute('ALTER TABLE translations ADD COLUMN source_lang TEXT');
          }
        }
      },
    );
  }
  
  // Main translation method - automatically translates any text
  static Future<String> translate(String text, String targetLanguage) async {
    if (text.trim().isEmpty) return text;
    
    // Check memory cache first
    final cacheKey = '${text}_$targetLanguage';
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }
    
    // Check database cache
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations',
      where: 'source_text = ? AND target_lang = ?',
      whereArgs: [text, targetLanguage],
    );
    
    if (maps.isNotEmpty) {
      final translated = maps.first['translated_text'] as String;
      _memoryCache[cacheKey] = translated;
      return translated;
    }
    
    try {
      // If not cached, call Google Translate API using GET with query parameters
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'key': _apiKey,
          'q': text,
          'target': targetLanguage,
          'format': 'text',
        },
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['data']['translations'][0]['translatedText'] as String;
        
        // Cache the translation
        await _cacheTranslation(text, targetLanguage, translatedText);
        _memoryCache[cacheKey] = translatedText;
        
        return translatedText;
      } else {
        debugPrint('Translation API error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        debugPrint('Request URL: $uri');
        return text; // Return original text if API fails
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      return text; // Return original text if translation fails
    }
  }
  
  // Cache translation in database
  static Future<void> _cacheTranslation(String sourceText, String targetLang, String translatedText) async {
    final db = await database;
    await db.insert(
      'translations',
      {
        'source_text': sourceText,
        'source_lang': 'en', // Default to English as source language
        'target_lang': targetLang,
        'translated_text': translatedText,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Batch translate multiple texts at once
  static Future<List<String>> translateBatch(List<String> texts, String targetLanguage) async {
    if (texts.isEmpty) return [];
    
    // Check cache for all texts first
    List<String> results = [];
    List<String> uncachedTexts = [];
    List<int> uncachedIndices = [];
    
    for (int i = 0; i < texts.length; i++) {
      final text = texts[i];
      final cacheKey = '${text}_$targetLanguage';
      
      if (_memoryCache.containsKey(cacheKey)) {
        results.add(_memoryCache[cacheKey]!);
      } else {
        // Check database
        final db = await database;
        final List<Map<String, dynamic>> maps = await db.query(
          'translations',
          where: 'source_text = ? AND target_lang = ?',
          whereArgs: [text, targetLanguage],
        );
        
        if (maps.isNotEmpty) {
          final translated = maps.first['translated_text'] as String;
          _memoryCache[cacheKey] = translated;
          results.add(translated);
        } else {
          results.add(''); // Placeholder
          uncachedTexts.add(text);
          uncachedIndices.add(i);
        }
      }
    }
    
    // Translate uncached texts
    if (uncachedTexts.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'q': uncachedTexts,
            'target': targetLanguage,
            'format': 'text',
          }),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final translations = data['data']['translations'] as List;
          
          for (int i = 0; i < translations.length; i++) {
            final translatedText = translations[i]['translatedText'] as String;
            final originalIndex = uncachedIndices[i];
            results[originalIndex] = translatedText;
            
            // Cache the translation
            await _cacheTranslation(uncachedTexts[i], targetLanguage, translatedText);
            _memoryCache['${uncachedTexts[i]}_$targetLanguage'] = translatedText;
          }
        }
      } catch (e) {
        debugPrint('Batch translation error: $e');
        // Fill remaining with original texts
        for (int i = 0; i < uncachedIndices.length; i++) {
          final originalIndex = uncachedIndices[i];
          results[originalIndex] = uncachedTexts[i];
        }
      }
    }
    
    return results;
  }
  
  // Clear old cache entries (older than 30 days)
  static Future<void> clearOldCache() async {
    final db = await database;
    final cutoffTime = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    await db.delete(
      'translations',
      where: 'created_at < ?',
      whereArgs: [cutoffTime],
    );
  }
  
  // Clear all cache
  static Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('translations');
    _memoryCache.clear();
  }
}
