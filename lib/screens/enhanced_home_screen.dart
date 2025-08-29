import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_voice_assistant_provider.dart';
import '../utils/app_theme.dart';

class EnhancedHomeScreen extends StatelessWidget {
  const EnhancedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedVoiceAssistantProvider>(
      builder: (context, voiceProvider, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header with status
                  _buildHeader(voiceProvider),
                  
                  const SizedBox(height: 20),
                  
                  // Main Voice Interface
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildVoiceInterface(context, voiceProvider),
                          
                          const SizedBox(height: 30),
                          
                          // Conversation History
                          if (voiceProvider.lastWords.isNotEmpty || voiceProvider.lastResponse.isNotEmpty)
                            _buildConversationHistory(voiceProvider),
                          
                          const SizedBox(height: 30),
                          
                          // Quick Commands
                          _buildQuickCommands(voiceProvider),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(EnhancedVoiceAssistantProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            provider.currentMode == VoiceAssistantMode.vapi 
              ? Icons.cloud 
              : Icons.smart_toy,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kisaan Vaani AI Assistant',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  provider.currentMode == VoiceAssistantMode.vapi 
                    ? 'Speech-to-Speech Mode' 
                    : 'RAG Backend Mode',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusIndicator(provider),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(EnhancedVoiceAssistantProvider provider) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (provider.isProcessing) {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
      statusText = 'Processing';
    } else if (provider.currentMode == VoiceAssistantMode.vapi) {
      statusColor = provider.vapiConnected ? Colors.green : Colors.red;
      statusIcon = provider.vapiConnected ? Icons.cloud_done : Icons.cloud_off;
      statusText = provider.vapiConnected ? 'Connected' : 'Offline';
    } else {
      statusColor = provider.ragBackendHealthy ? Colors.green : Colors.red;
      statusIcon = provider.ragBackendHealthy ? Icons.check_circle : Icons.error;
      statusText = provider.ragBackendHealthy ? 'Online' : 'Offline';
    }

    return Column(
      children: [
        Icon(statusIcon, color: statusColor, size: 20),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 10,
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceInterface(BuildContext context, EnhancedVoiceAssistantProvider provider) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Microphone Button
          GestureDetector(
            onTap: () async {
              if (provider.isListening) {
                await provider.stopListening();
              } else if (provider.isSpeaking) {
                await provider.stopSpeaking();
              } else {
                await provider.startListening();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getMicrophoneColor(provider),
                boxShadow: provider.isListening
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        spreadRadius: 10,
                        blurRadius: 20,
                      ),
                    ]
                  : provider.isProcessing
                    ? [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          spreadRadius: 8,
                          blurRadius: 16,
                        ),
                      ]
                    : [],
              ),
              child: _getMicrophoneIcon(provider),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Status Text
          Text(
            _getStatusText(provider),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Processing Time
          if (provider.processingTime.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Response time: ${provider.processingTime}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          
          // Mode Switch Button
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeChip(
                'Local RAG', 
                VoiceAssistantMode.local, 
                provider,
                Icons.phone_android,
              ),
              const SizedBox(width: 12),
              _buildModeChip(
                'Vapi Cloud', 
                VoiceAssistantMode.vapi, 
                provider,
                Icons.cloud,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(
    String label, 
    VoiceAssistantMode mode, 
    EnhancedVoiceAssistantProvider provider,
    IconData icon,
  ) {
    final isSelected = provider.currentMode == mode;
    
    return GestureDetector(
      onTap: () => provider.switchMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMicrophoneColor(EnhancedVoiceAssistantProvider provider) {
    if (provider.isProcessing) return Colors.orange;
    if (provider.isListening) return Colors.red;
    if (provider.isSpeaking) return Colors.blue;
    return Colors.green;
  }

  Widget _getMicrophoneIcon(EnhancedVoiceAssistantProvider provider) {
    if (provider.isProcessing) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 4,
        ),
      );
    }
    
    IconData iconData;
    if (provider.isListening) {
      iconData = Icons.mic;
    } else if (provider.isSpeaking) {
      iconData = Icons.volume_up;
    } else {
      iconData = provider.currentMode == VoiceAssistantMode.vapi 
        ? Icons.assistant 
        : Icons.mic_none;
    }
    
    return Icon(
      iconData,
      size: 50,
      color: Colors.white,
    );
  }

  String _getStatusText(EnhancedVoiceAssistantProvider provider) {
    if (provider.isProcessing) return 'Processing your question...';
    if (provider.isListening) return 'Listening...';
    if (provider.isSpeaking) return 'Speaking...';
    
    if (provider.currentMode == VoiceAssistantMode.vapi) {
      return provider.vapiConnected 
        ? 'Tap to start voice conversation'
        : 'Vapi service unavailable';
    } else {
      return provider.ragBackendHealthy 
        ? 'Ask me anything about farming'
        : 'RAG backend offline - using fallback';
    }
  }

  Widget _buildConversationHistory(EnhancedVoiceAssistantProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Conversation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // User input
          if (provider.lastWords.isNotEmpty) ...[
            _buildMessageBubble(
              message: provider.lastWords,
              isUser: true,
              confidence: provider.confidence,
            ),
            const SizedBox(height: 12),
          ],
          
          // AI response
          if (provider.lastResponse.isNotEmpty)
            _buildMessageBubble(
              message: provider.lastResponse,
              isUser: false,
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isUser,
    String? confidence,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade100 : Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person : Icons.smart_toy,
                  size: 16,
                  color: isUser ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  isUser ? 'You' : 'Kisaan Vaani',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isUser ? Colors.blue.shade700 : Colors.green.shade700,
                  ),
                ),
                if (confidence != null && confidence.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$confidence%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCommands(EnhancedVoiceAssistantProvider provider) {
    final commands = [
      {
        'title': 'Crop Health',
        'subtitle': 'Ask about your crops',
        'icon': Icons.eco,
        'command': 'How are my crops doing?',
      },
      {
        'title': 'Weather Info',
        'subtitle': 'Get weather updates',
        'icon': Icons.wb_sunny,
        'command': 'What is the weather like today?',
      },
      {
        'title': 'Yield Prediction',
        'subtitle': 'Predict crop yields',
        'icon': Icons.analytics,
        'command': 'Can you predict my crop yield?',
      },
      {
        'title': 'Farming Tips',
        'subtitle': 'Get farming advice',
        'icon': Icons.tips_and_updates,
        'command': 'Give me farming tips for this season',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Quick Commands',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: commands.length,
            itemBuilder: (context, index) {
              final command = commands[index];
              return _buildCommandCard(
                title: command['title'] as String,
                subtitle: command['subtitle'] as String,
                icon: command['icon'] as IconData,
                onTap: () async {
                  // Simulate voice command by calling the RAG service directly
                  final commandText = command['command'] as String;
                  
                  if (provider.currentMode == VoiceAssistantMode.local) {
                    // Manually trigger RAG processing
                    provider.processVoiceInput(commandText);
                  } else {
                    provider.speak('Processing: $commandText');
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommandCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.green),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
