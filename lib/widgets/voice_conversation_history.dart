import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_voice_provider.dart';
import '../utils/app_theme.dart';

class VoiceConversationHistory extends StatelessWidget {
  const VoiceConversationHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedVoiceProvider>(
      builder: (context, voiceProvider, child) {
        if (voiceProvider.conversationHistory.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Conversation History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _showClearDialog(context, voiceProvider);
                      },
                      icon: Icon(
                        Icons.clear_all,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Conversation List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: voiceProvider.conversationHistory.length,
                  reverse: true, // Show latest messages at bottom
                  itemBuilder: (context, index) {
                    final reversedIndex = voiceProvider.conversationHistory.length - 1 - index;
                    final message = voiceProvider.conversationHistory[reversedIndex];
                    final isUser = message['role'] == 'user';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isUser ? AppTheme.accentOrange : AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isUser ? Icons.person : Icons.agriculture,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Message Bubble
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser 
                                  ? AppTheme.accentOrange.withOpacity(0.1)
                                  : AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isUser 
                                    ? AppTheme.accentOrange.withOpacity(0.3)
                                    : AppTheme.primaryGreen.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isUser ? 'You' : 'AI Assistant',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isUser ? AppTheme.accentOrange : AppTheme.primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message['message'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textDark,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, EnhancedVoiceProvider voiceProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Conversation'),
          content: const Text('Are you sure you want to clear the conversation history?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                voiceProvider.clearConversationHistory();
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
