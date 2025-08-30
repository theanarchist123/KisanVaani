import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vapi_provider.dart';
import '../providers/language_provider.dart';

class VoiceChatWidget extends StatefulWidget {
  const VoiceChatWidget({super.key});

  @override
  State<VoiceChatWidget> createState() => _VoiceChatWidgetState();
}

class _VoiceChatWidgetState extends State<VoiceChatWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VapiProvider, LanguageProvider>(
      builder: (context, vapiProvider, languageProvider, child) {
        return Column(
          children: [
            // Voice Control Section
            _buildVoiceControlSection(vapiProvider, languageProvider),
            
            // Current Status
            _buildStatusSection(vapiProvider),
            
            // Conversation Display
            _buildConversationSection(vapiProvider),
            
            // Text Input (for testing)
            if (vapiProvider.isSessionActive) 
              _buildTextInputSection(vapiProvider),
          ],
        );
      },
    );
  }

  Widget _buildVoiceControlSection(VapiProvider vapiProvider, LanguageProvider languageProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Language Selector
          _buildLanguageSelector(vapiProvider, languageProvider),
          
          // Main Mic Button
          _buildMicButton(vapiProvider, languageProvider),
          
          // Close Button
          if (vapiProvider.isSessionActive)
            _buildCloseButton(vapiProvider),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(VapiProvider vapiProvider, LanguageProvider languageProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: languageProvider.currentLanguage,
          icon: const Icon(Icons.language, color: Colors.green),
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          onChanged: (String? newLanguage) async {
            if (newLanguage != null) {
              await languageProvider.changeLanguage(newLanguage);
              
              // If session is active, update Vapi language
              if (vapiProvider.isSessionActive) {
                await vapiProvider.changeLanguage(newLanguage);
              }
            }
          },
          items: LanguageProvider.languageNames.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMicButton(VapiProvider vapiProvider, LanguageProvider languageProvider) {
    return GestureDetector(
      onTap: () async {
        if (vapiProvider.isConnecting) return;
        
        if (vapiProvider.isSessionActive) {
          // Session is active, show status
          _showSessionActiveDialog();
        } else {
          // Start new session
          await vapiProvider.startVoiceSession(languageProvider.currentLanguage);
        }
      },
      child: AnimatedBuilder(
        animation: vapiProvider.isSessionActive ? _waveController : _pulseController,
        builder: (context, child) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: vapiProvider.isSessionActive
                    ? [Colors.red.shade400, Colors.red.shade600]
                    : vapiProvider.isConnecting
                        ? [Colors.orange.shade400, Colors.orange.shade600]
                        : [Colors.green.shade400, Colors.green.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (vapiProvider.isSessionActive ? Colors.red : Colors.green)
                      .withOpacity(0.3),
                  spreadRadius: vapiProvider.isSessionActive
                      ? 5 + (_waveController.value * 10)
                      : 3 + (_pulseController.value * 5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              vapiProvider.isSessionActive
                  ? Icons.mic
                  : vapiProvider.isConnecting
                      ? Icons.hourglass_empty
                      : Icons.mic_none,
              color: Colors.white,
              size: 32,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCloseButton(VapiProvider vapiProvider) {
    return GestureDetector(
      onTap: () async {
        await vapiProvider.endVoiceSession();
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.shade500,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildStatusSection(VapiProvider vapiProvider) {
    if (!vapiProvider.isSessionActive && !vapiProvider.isConnecting) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          if (vapiProvider.isConnecting)
            const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('Connecting to voice assistant...'),
              ],
            ),
          
          if (vapiProvider.isSessionActive) ...[
            const Row(
              children: [
                Icon(Icons.record_voice_over, color: Colors.green),
                SizedBox(width: 10),
                Text('🎤 Listening... Speak now!', 
                     style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            
            if (vapiProvider.currentTranscription.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('You said:', 
                         style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(vapiProvider.currentTranscription),
                  ],
                ),
              ),
            ],
          ],
          
          if (vapiProvider.errorMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(vapiProvider.errorMessage)),
                  IconButton(
                    onPressed: () => vapiProvider.clearError(),
                    icon: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConversationSection(VapiProvider vapiProvider) {
    if (vapiProvider.conversationHistory.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Column(
          children: [
            Icon(Icons.chat_bubble_outline, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'Tap the microphone to start your voice conversation!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat, color: Colors.green),
                const SizedBox(width: 10),
                const Text('Conversation', 
                     style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => vapiProvider.clearConversationHistory(),
                  icon: const Icon(Icons.clear_all, size: 20),
                  tooltip: 'Clear conversation',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: vapiProvider.conversationHistory.length,
              itemBuilder: (context, index) {
                final message = vapiProvider.conversationHistory[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ConversationMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: 
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.green,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.blue.shade800 : Colors.black87,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 10),
            const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextInputSection(VapiProvider vapiProvider) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type a message for testing...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
              onSubmitted: (text) => _sendTextMessage(vapiProvider),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.small(
            onPressed: () => _sendTextMessage(vapiProvider),
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _sendTextMessage(VapiProvider vapiProvider) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      vapiProvider.sendTextQuery(text);
      _textController.clear();
    }
  }

  void _showSessionActiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Session Active'),
        content: const Text(
          'Your voice session is currently active. Speak now or tap the close button to end the session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
