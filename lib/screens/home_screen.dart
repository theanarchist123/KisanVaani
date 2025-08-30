import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_voice_provider.dart';
import '../utils/app_theme.dart';
import '../utils/layout_helpers.dart';
import '../generated/app_localizations.dart';
import '../widgets/voice_language_selector.dart';
import '../widgets/voice_conversation_history.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Consumer<EnhancedVoiceProvider>(
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
                      // Top Controls Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Language Selector
                          VoiceLanguageSelector(),
                          
                          // RAG Backend Status Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: voiceProvider.isRagBackendReady 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: voiceProvider.isRagBackendReady 
                                  ? Colors.green
                                  : Colors.orange,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  voiceProvider.isRagBackendReady 
                                    ? Icons.cloud_done 
                                    : Icons.cloud_off,
                                  size: 16,
                                  color: voiceProvider.isRagBackendReady 
                                    ? Colors.green
                                    : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  voiceProvider.isRagBackendReady ? 'RAG Ready' : 'Local Mode',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: voiceProvider.isRagBackendReady 
                                      ? Colors.green
                                      : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Session Control Button
                          if (voiceProvider.isActive)
                            ElevatedButton.icon(
                              onPressed: () {
                                voiceProvider.endVoiceSession();
                              },
                              icon: Icon(Icons.stop, size: 16),
                              label: Text('End Session'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Voice Assistant Main Interface
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: LayoutHelpers.safeColumn(
                            children: [
                              // Microphone Button
                              GestureDetector(
                                onTap: () async {
                                  if (voiceProvider.isListening) {
                                    voiceProvider.toggleListening();
                                  } else {
                                    await voiceProvider.startVoiceSession();
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
                                voiceProvider.statusMessage.isNotEmpty 
                                  ? voiceProvider.statusMessage
                                  : localizations.talkToMe,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Voice Input Display
                              if (voiceProvider.recognizedText.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: LayoutHelpers.safeText(
                                    voiceProvider.recognizedText,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppTheme.textDark,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              
                              // AI Response Display
                              if (voiceProvider.lastResponse.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.accentOrange.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _getResponseSourceIcon(voiceProvider.responseSource),
                                            color: AppTheme.accentOrange,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _getResponseSourceLabel(voiceProvider.responseSource),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.accentOrange,
                                            ),
                                          ),
                                          if (voiceProvider.responseSource == 'rag')
                                            Container(
                                              margin: const EdgeInsets.only(left: 8),
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Enhanced',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green[700],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LayoutHelpers.safeText(
                                        voiceProvider.lastResponse,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textDark,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Demo Queries Section
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: LayoutHelpers.safeColumn(
                            children: [
                              LayoutHelpers.safeText(
                                'Try These Agricultural Queries',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              _buildDemoQueryCard(
                                context,
                                voiceProvider,
                                '🌧️',
                                'Monsoon Status at Anand',
                                "What's the current monsoon status at Anand station, and how much rainfall has it received in the past week?",
                              ),
                              
                              const SizedBox(height: 12),
                              
                              _buildDemoQueryCard(
                                context,
                                voiceProvider,
                                '🌡️',
                                '5-Day Weather Forecast',
                                "What are the temperature and rainfall forecasts for the next 5 days in Anand?",
                              ),
                              
                              const SizedBox(height: 12),
                              
                              _buildDemoQueryCard(
                                context,
                                voiceProvider,
                                '🌽',
                                'Kharif Crop Water Needs',
                                "What crop-water needs do maize and other Kharif crops have in Anand's agro-meteorological conditions?",
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Conversation History
                      VoiceConversationHistory(),
                      
                      const SizedBox(height: 20),
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

  Widget _buildDemoQueryCard(
    BuildContext context,
    EnhancedVoiceProvider voiceProvider,
    String emoji,
    String title,
    String query,
  ) {
    return GestureDetector(
      onTap: () async {
        // Simulate user asking the question
        await _simulateVoiceQuery(voiceProvider, query);
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              width: 1,
            ),
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LayoutHelpers.safeColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutHelpers.safeText(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LayoutHelpers.safeText(
                      query,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _simulateVoiceQuery(EnhancedVoiceProvider voiceProvider, String query) async {
    await voiceProvider.simulateQuery(query);
  }

  IconData _getResponseSourceIcon(String source) {
    switch (source) {
      case 'rag':
        return Icons.cloud_done;
      case 'gemini':
        return Icons.auto_awesome;
      case 'demo':
        return Icons.school;
      case 'fallback':
        return Icons.help_outline;
      default:
        return Icons.agriculture;
    }
  }

  String _getResponseSourceLabel(String source) {
    switch (source) {
      case 'rag':
        return 'RAG Knowledge';
      case 'gemini':
        return 'AI Assistant';
      case 'demo':
        return 'Demo Response';
      case 'fallback':
        return 'Basic Assistant';
      default:
        return 'AI Assistant';
    }
  }
}
