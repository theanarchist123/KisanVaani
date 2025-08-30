import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_voice_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_theme.dart';

class VoiceLanguageSelector extends StatelessWidget {
  const VoiceLanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<EnhancedVoiceProvider, LanguageProvider>(
      builder: (context, voiceProvider, languageProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryGreen, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                color: AppTheme.primaryGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: voiceProvider.currentLanguage,
                underline: Container(),
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: voiceProvider.isActive ? null : (String? newLanguage) {
                  if (newLanguage != null) {
                    voiceProvider.changeLanguage(newLanguage);
                    languageProvider.changeLanguage(newLanguage);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: 'hi',
                    child: Text('हिंदी'),
                  ),
                  DropdownMenuItem(
                    value: 'gu',
                    child: Text('ગુજરાતી'),
                  ),
                  DropdownMenuItem(
                    value: 'ta',
                    child: Text('தமிழ்'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
