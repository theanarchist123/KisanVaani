import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hybrid_translation_provider.dart';

/// Widget for static translations from JSON files
class TranslatedText extends StatelessWidget {
  final String translationKey;
  final String? fallback;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Map<String, String>? params;
  
  const TranslatedText(
    this.translationKey, {
    Key? key,
    this.fallback,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.params,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<HybridTranslationProvider>(
      builder: (context, provider, child) {
        final translation = provider.t(translationKey, params: params);
        return Text(
          translation == translationKey ? (fallback ?? translationKey) : translation,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// Widget for dynamic text translation
class DynamicTranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? fromLanguage;
  
  const DynamicTranslatedText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fromLanguage,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<HybridTranslationProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<String>(
          future: provider.translateText(text, fromLanguage: fromLanguage),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                text,
                style: style?.copyWith(color: Colors.grey) ?? 
                       TextStyle(color: Colors.grey[600]),
                textAlign: textAlign,
                maxLines: maxLines,
                overflow: overflow,
              );
            }
            
            return Text(
              snapshot.data ?? text,
              style: style,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow,
            );
          },
        );
      },
    );
  }
}

/// Utility function for getting static translations in code
String getTranslation(BuildContext context, String key, {Map<String, String>? params, String? fallback}) {
  final provider = Provider.of<HybridTranslationProvider>(context, listen: false);
  final translation = provider.t(key, params: params);
  return translation == key ? (fallback ?? key) : translation;
}

/// Utility function for dynamic translations in code
Future<String> translateDynamicText(BuildContext context, String text, {String? fromLanguage}) async {
  final provider = Provider.of<HybridTranslationProvider>(context, listen: false);
  return await provider.translateText(text, fromLanguage: fromLanguage);
}

/// Extension for easy translation access
extension TranslationExtension on BuildContext {
  HybridTranslationProvider? get translator {
    try {
      return Provider.of<HybridTranslationProvider>(this, listen: false);
    } catch (e) {
      return null;
    }
  }
  
  String tr(String key, {Map<String, String>? params, String? fallback}) {
    final provider = translator;
    if (provider == null) {
      return fallback ?? key;
    }
    final translation = provider.t(key, params: params);
    return translation == key ? (fallback ?? key) : translation;
  }
  
  Future<String> trDynamic(String text, {String? fromLanguage}) async {
    final provider = translator;
    if (provider == null) {
      return text;
    }
    return await provider.translateText(text, fromLanguage: fromLanguage);
  }
}
