import 'package:flutter/widgets.dart';
import '../services/i18n_service.dart';

/// Helper widgets for easy i18n usage throughout the app
class I18nText extends StatelessWidget {
  final String translationKey;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final Map<String, dynamic>? args;

  const I18nText(
    this.translationKey, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.args,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      I18nService.t(context, translationKey, args: args),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

/// Widget for dynamic content translation with loading state
class DynamicTranslationText extends StatelessWidget {
  final String text;
  final String? sourceLang;
  final String? targetLang;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const DynamicTranslationText(
    this.text, {
    super.key,
    this.sourceLang,
    this.targetLang,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return I18nService.buildTranslatedText(
      context,
      text,
      sourceLang: sourceLang,
      targetLang: targetLang,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

/// Helper extension for easy translation access
extension BuildContextI18n on BuildContext {
  /// Quick access to translation function
  String t(String translationKey, {Map<String, dynamic>? args}) {
    return I18nService.t(this, translationKey, args: args);
  }

  /// Translate dynamic text
  Future<String> translateText(String text, {String? sourceLang, String? targetLang}) {
    return I18nService.translateText(this, text, sourceLang: sourceLang, targetLang: targetLang);
  }

  /// Get current language
  String get currentLanguage => I18nService.getCurrentLanguage(this);

  /// Format currency
  String formatCurrency(double amount) => I18nService.formatCurrency(this, amount);

  /// Format date
  String formatDate(DateTime date) => I18nService.formatDate(this, date);
}

/// Helper function for quick access to translation
String t(BuildContext context, String translationKey, {Map<String, dynamic>? args}) {
  return I18nService.t(context, translationKey, args: args);
}
