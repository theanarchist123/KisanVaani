import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hybrid_translation_provider.dart';
import '../utils/app_theme.dart';
import '../utils/layout_helpers.dart';
import '../screens/main_screen.dart';

class LanguageStartupScreen extends StatelessWidget {
  const LanguageStartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: LayoutHelpers.getScreenPadding(context),
                child: LayoutHelpers.safeColumn(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo and Title
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          // App Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.agriculture,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // App Title
                          LayoutHelpers.safeText(
                            'Kisan Vaani',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          LayoutHelpers.safeText(
                            'AI-powered Voice Assistant for Farmers',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Language Selection Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: LayoutHelpers.safeColumn(
                        children: [
                          Icon(
                            Icons.language,
                            size: 48,
                            color: AppTheme.primaryGreen,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          LayoutHelpers.safeText(
                            'Choose Your Language',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          LayoutHelpers.safeText(
                            'अपनी भाषा चुनें | உங்கள் மொழியைத் தேர்ந்தெடுக்கவும் | તમારી ભાષા પસંદ કરો',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Language Options
                    ...HybridTranslationProvider.supportedLanguages.entries.map((entry) {
                      final languageCode = entry.key;
                      final languageName = entry.value;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              final translationProvider = Provider.of<HybridTranslationProvider>(context, listen: false);
                              await translationProvider.changeLanguage(languageCode);
                              
                              if (context.mounted) {
                                // Navigate to main screen after language selection
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const MainScreen(),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
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
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: AppTheme.primaryGradient,
                                    ),
                                    child: Center(
                                      child: LayoutHelpers.safeText(
                                        _getLanguageIcon(languageCode),
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
                                    child: LayoutHelpers.safeColumn(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        LayoutHelpers.safeText(
                                          languageName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 4),
                                        
                                        LayoutHelpers.safeText(
                                          _getLanguageNativeName(languageCode),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Arrow Icon
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppTheme.primaryGreen,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 40),
                    
                    // Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: LayoutHelpers.safeText(
                        'You can change the language anytime from settings',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
