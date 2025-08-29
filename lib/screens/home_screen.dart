import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';
import '../utils/app_theme.dart';
import '../utils/layout_helpers.dart';
import '../generated/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Consumer<VoiceAssistantProvider>(
      builder: (context, voiceProvider, child) {
        return Container(
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
                      // Voice Assistant Main Interface
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
                            // Animated Microphone
                            GestureDetector(
                              onTap: () async {
                                if (voiceProvider.isListening) {
                                  await voiceProvider.stopListening();
                                } else {
                                  await voiceProvider.startListening();
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: voiceProvider.isListening 
                                    ? AppTheme.accentOrange 
                                    : AppTheme.primaryGreen,
                                  borderRadius: BorderRadius.circular(60),
                                  boxShadow: voiceProvider.isListening
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.accentOrange.withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ]
                                    : [],
                                ),
                                child: Icon(
                                  voiceProvider.isListening ? Icons.mic : Icons.mic_none,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Status Text
                            LayoutHelpers.safeText(
                              voiceProvider.isListening 
                                ? localizations.listening
                                : localizations.talkToMe,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Voice Input Display
                            if (voiceProvider.lastWords.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: LayoutHelpers.safeText(
                                  voiceProvider.lastWords,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Quick Voice Commands
                      LayoutHelpers.safeText(
                        localizations.youCanSay,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildVoiceCommandCard(
                        '💰',
                        localizations.addExpense,
                        localizations.addExpenseExample,
                        () => voiceProvider.speak('You can tell me about your expenses'),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildVoiceCommandCard(
                        '🌱',
                        localizations.checkCrops,
                        localizations.checkCropsExample,
                        () => voiceProvider.speak('You can ask about your crops'),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildVoiceCommandCard(
                        '🌧️',
                        localizations.weatherInfo,
                        localizations.weatherExample,
                        () => voiceProvider.speak('I can give you weather information'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoiceCommandCard(
    String emoji,
    String title,
    String example,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LayoutHelpers.responsiveRow(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LayoutHelpers.safeColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutHelpers.safeText(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textDark,
                      ),
                    ),
                    LayoutHelpers.safeText(
                      example,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
