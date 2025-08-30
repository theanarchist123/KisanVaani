import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vapi_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/voice_chat_widget.dart';

class VapiVoiceAssistantPage extends StatefulWidget {
  const VapiVoiceAssistantPage({super.key});

  @override
  State<VapiVoiceAssistantPage> createState() => _VapiVoiceAssistantPageState();
}

class _VapiVoiceAssistantPageState extends State<VapiVoiceAssistantPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 Voice Assistant'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          Consumer<VapiProvider>(
            builder: (context, vapiProvider, child) {
              return Row(
                children: [
                  // Session status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: vapiProvider.isSessionActive 
                          ? Colors.red.shade100 
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          vapiProvider.isSessionActive 
                              ? Icons.mic 
                              : Icons.mic_off,
                          size: 16,
                          color: vapiProvider.isSessionActive 
                              ? Colors.red.shade700 
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vapiProvider.isSessionActive ? 'LIVE' : 'OFF',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: vapiProvider.isSessionActive 
                                ? Colors.red.shade700 
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                _buildHeaderSection(),
                
                // Voice Chat Widget
                const VoiceChatWidget(),
                
                // Quick Actions
                _buildQuickActionsSection(),
                
                // Tips Section
                _buildTipsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.record_voice_over,
            size: 60,
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          const Text(
            'AI Voice Assistant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return Text(
                _getWelcomeMessage(languageProvider.currentLanguage),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Consumer<VapiProvider>(
      builder: (context, vapiProvider, child) {
        if (!vapiProvider.isSessionActive) {
          return Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                const Text(
                  '🎯 Quick Test Phrases',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _getQuickPhrases().map((phrase) {
                    return _buildQuickPhraseChip(phrase, vapiProvider);
                  }).toList(),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildQuickPhraseChip(String phrase, VapiProvider vapiProvider) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return GestureDetector(
          onTap: () async {
            if (!vapiProvider.isSessionActive) {
              await vapiProvider.startVoiceSession(languageProvider.currentLanguage);
              // Wait a moment for session to establish
              await Future.delayed(const Duration(seconds: 1));
            }
            await vapiProvider.sendTextQuery(phrase);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Text(
              phrase,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange),
              SizedBox(width: 10),
              Text(
                '💡 Voice Assistant Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ..._getTips().map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(child: Text(tip)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _getWelcomeMessage(String language) {
    switch (language) {
      case 'hi':
        return 'आपके कृषि सवालों के लिए बोलें! मैं हिंदी में आपकी मदद करूंगा।';
      case 'gu':
        return 'તમારા ખેતીના પ્રશ્નો માટે બોલો! હું ગુજરાતીમાં તમારી મદદ કરીશ।';
      case 'ta':
        return 'உங்கள் விவசாய கேள்விகளுக்கு பேசுங்கள்! நான் தமிழில் உங்களுக்கு உதவுவேன்।';
      default:
        return 'Speak your farming questions! I\'ll help you in real-time.';
    }
  }

  List<String> _getQuickPhrases() {
    return [
      'How is the weather today?',
      'What crops should I plant?',
      'Tell me about government schemes',
      'Market prices for wheat',
      'Pest control tips',
    ];
  }

  List<String> _getTips() {
    return [
      'Speak clearly and wait for the AI to respond',
      'You can change language anytime during conversation',
      'Ask about weather, crops, schemes, or market prices',
      'The AI responds with both voice and text',
      'Use the close button to end the session',
    ];
  }
}
