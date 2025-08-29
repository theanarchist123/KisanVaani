import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_theme.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final bool isFirstLaunch;
  
  const LanguageSelectionScreen({
    super.key,
    this.isFirstLaunch = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                if (!isFirstLaunch) ...[
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo/Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          size: 60,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Welcome Text
                      const Text(
                        'KisanVaani',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        isFirstLaunch 
                          ? 'Choose your preferred language'
                          : 'Select Language / भाषा चुनें',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Language Options
                      Consumer<LanguageProvider>(
                        builder: (context, languageProvider, child) {
                          return Column(
                            children: languageProvider.supportedLanguages.map((language) {
                              final isSelected = languageProvider.currentLanguage == language;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildLanguageOption(
                                  context,
                                  language,
                                  languageProvider.getLanguageDisplayName(language),
                                  isSelected,
                                  () => _selectLanguage(context, languageProvider, language),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                if (isFirstLaunch) ...[
                  const SizedBox(height: 32),
                  Consumer<LanguageProvider>(
                    builder: (context, languageProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _continueToApp(context, languageProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageCode,
    String languageName,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : Colors.white70,
                  width: 2,
                ),
                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
              ),
              child: isSelected
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.primaryGreen : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectLanguage(BuildContext context, LanguageProvider languageProvider, String language) {
    languageProvider.changeLanguage(language);
    
    if (!isFirstLaunch) {
      // Show confirmation and go back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to ${languageProvider.getLanguageDisplayName(language)}'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _continueToApp(BuildContext context, LanguageProvider languageProvider) {
    languageProvider.completeFirstLaunch();
    // Navigate to main app - you'll need to replace this with your main screen route
    Navigator.pushReplacementNamed(context, '/main');
  }
}
