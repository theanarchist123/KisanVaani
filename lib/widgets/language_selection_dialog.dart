import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_theme.dart';
import '../utils/layout_helpers.dart';
import '../generated/app_localizations.dart';

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});
  
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
  final localizations = AppLocalizations.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: LayoutHelpers.safeColumn(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Row(
                children: [
                  const Icon(
                    Icons.language,
                    color: AppTheme.primaryGreen,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LayoutHelpers.safeText(
                      localizations.selectLanguage,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Language Options
              ...LanguageProvider.supportedLocales.map((locale) {
                final isSelected = languageProvider.currentLocale.languageCode == locale.languageCode;
                final languageName = LanguageProvider.languageNames[locale.languageCode] ?? 'Unknown';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        languageProvider.changeLanguage(locale.languageCode);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? AppTheme.primaryGreen 
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          color: isSelected 
                              ? AppTheme.primaryGreen.withOpacity(0.1)
                              : Colors.grey[50],
                        ),
                        child: LayoutHelpers.responsiveRow(
                          children: [
                            // Language Flag or Icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isSelected 
                                    ? AppTheme.primaryGreen 
                                    : Colors.grey[400],
                              ),
                              child: Center(
                                child: LayoutHelpers.safeText(
                                  _getLanguageIcon(locale.languageCode),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Language Name
                            Expanded(
                              child: LayoutHelpers.safeText(
                                languageName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected 
                                      ? AppTheme.primaryGreen 
                                      : AppTheme.textDark,
                                ),
                              ),
                            ),
                            
                            // Selection Indicator
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryGreen,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: LayoutHelpers.safeText(
                    localizations.cancel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
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
        return 'UN';
    }
  }
}

// Helper function to show language selection dialog
void showLanguageSelectionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const LanguageSelectionDialog(),
  );
}
