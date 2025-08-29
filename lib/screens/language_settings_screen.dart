import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_theme.dart';
import '../utils/layout_helpers.dart';
import '../generated/app_localizations.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          localizations.language,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: LayoutHelpers.getScreenPadding(context),
                child: LayoutHelpers.safeColumn(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Language Selection Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: LayoutHelpers.safeColumn(
                        children: [
                          const Icon(
                            Icons.language,
                            size: 64,
                            color: AppTheme.primaryGreen,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          LayoutHelpers.safeText(
                            localizations.selectLanguage,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          LayoutHelpers.safeText(
                            'Choose your preferred language',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Language Options
                    ...LanguageProvider.supportedLocales.map((locale) {
                      final isSelected = languageProvider.currentLocale.languageCode == locale.languageCode;
                      final languageName = LanguageProvider.languageNames[locale.languageCode] ?? 'Unknown';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await languageProvider.changeLanguage(locale.languageCode);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Language changed to $languageName'),
                                    backgroundColor: AppTheme.primaryGreen,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected 
                                      ? AppTheme.primaryGreen 
                                      : Colors.white.withOpacity(0.3),
                                  width: isSelected ? 3 : 2,
                                ),
                                color: isSelected 
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.9),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ] : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: LayoutHelpers.responsiveRow(
                                children: [
                                  // Language Flag/Icon
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      gradient: isSelected 
                                          ? AppTheme.primaryGradient
                                          : LinearGradient(
                                              colors: [Colors.grey[400]!, Colors.grey[600]!],
                                            ),
                                    ),
                                    child: Center(
                                      child: LayoutHelpers.safeText(
                                        _getLanguageIcon(locale.languageCode),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 20),
                                  
                                  // Language Info
                                  Expanded(
                                    child: LayoutHelpers.safeColumn(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        LayoutHelpers.safeText(
                                          languageName,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected 
                                                ? AppTheme.primaryGreen 
                                                : AppTheme.textDark,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 4),
                                        
                                        LayoutHelpers.safeText(
                                          _getLanguageNativeName(locale.languageCode),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Selection Indicator
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected 
                                          ? AppTheme.primaryGreen 
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected 
                                            ? AppTheme.primaryGreen 
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _getLanguageIcon(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'EN';
      case 'hi':
        return 'हि';
      case 'ta':
        return 'த';
      case 'gu':
        return 'ગુ';
      default:
        return '??';
    }
  }
  
  String _getLanguageNativeName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English Language';
      case 'hi':
        return 'हिन्दी भाषा';
      case 'ta':
        return 'தமிழ் மொழி';
      case 'gu':
        return 'ગુજરાતી ભાષા';
      default:
        return 'Unknown Language';
    }
  }
}
