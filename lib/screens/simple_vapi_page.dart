import 'package:flutter/material.dart';

class SimpleVapiPage extends StatefulWidget {
  const SimpleVapiPage({super.key});

  @override
  State<SimpleVapiPage> createState() => _SimpleVapiPageState();
}

class _SimpleVapiPageState extends State<SimpleVapiPage> {
  bool _isSessionActive = false;
  bool _isConnecting = false;
  String _currentLanguage = 'en';
  String _lastResponse = '';

  final Map<String, String> _languages = {
    'en': 'English',
    'hi': 'हिंदी',
    'gu': 'ગુજરાતી',
    'ta': 'தமிழ்',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 Vapi Voice Assistant'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _isSessionActive ? Colors.red.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isSessionActive ? Icons.mic : Icons.mic_off,
                  size: 16,
                  color: _isSessionActive ? Colors.red.shade700 : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _isSessionActive ? 'LIVE' : 'OFF',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isSessionActive ? Colors.red.shade700 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Language Selector
              _buildLanguageSelector(),
              
              // Voice Controls
              _buildVoiceControls(),
              
              // Status
              _buildStatus(),
              
              // Response Area
              Expanded(child: _buildResponseArea()),
              
              // Implementation Note
              _buildImplementationNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.record_voice_over, size: 60, color: Colors.green),
          const SizedBox(height: 10),
          const Text(
            'Vapi Voice Assistant',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 10),
          Text(
            'Real-time multilingual voice Q&A for farmers',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.language, color: Colors.blue),
              SizedBox(width: 10),
              Text('Select Language', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            children: _languages.entries.map((entry) {
              final isSelected = _currentLanguage == entry.key;
              return ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentLanguage = entry.key;
                    });
                    if (_isSessionActive) {
                      _showLanguageChangeDialog();
                    }
                  }
                },
                selectedColor: Colors.blue.shade200,
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceControls() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Start/Active Indicator
          GestureDetector(
            onTap: _toggleSession,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isSessionActive
                      ? [Colors.red.shade400, Colors.red.shade600]
                      : _isConnecting
                          ? [Colors.orange.shade400, Colors.orange.shade600]
                          : [Colors.green.shade400, Colors.green.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isSessionActive ? Colors.red : Colors.green).withOpacity(0.3),
                    spreadRadius: _isSessionActive ? 8 : 3,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                _isSessionActive
                    ? Icons.mic
                    : _isConnecting
                        ? Icons.hourglass_empty
                        : Icons.mic_none,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          
          // Close Button
          if (_isSessionActive)
            GestureDetector(
              onTap: _stopSession,
              child: Container(
                width: 60,
                height: 60,
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
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _isSessionActive ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _isSessionActive ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isSessionActive ? Icons.radio_button_checked : Icons.radio_button_off,
            color: _isSessionActive ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 10),
          Text(
            _isSessionActive
                ? '🎤 Session Active - Speak in ${_languages[_currentLanguage]}'
                : _isConnecting
                    ? 'Connecting to Vapi...'
                    : 'Tap microphone to start voice session',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isSessionActive ? Colors.green.shade700 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseArea() {
    return Container(
      margin: const EdgeInsets.all(20),
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
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: Colors.grey),
                SizedBox(width: 10),
                Text('AI Response', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _lastResponse.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            'Start a voice session to see AI responses here',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _lastResponse,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImplementationNote() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Colors.amber),
              SizedBox(width: 10),
              Text('Implementation Status', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          const Text('✅ UI/UX Ready'),
          const Text('✅ Language Selection'),
          const Text('✅ Session Management'),
          const Text('🔄 Vapi WebSocket Integration (In Progress)'),
          const Text('🔄 Real-time Audio Streaming (In Progress)'),
          const SizedBox(height: 10),
          Text(
            'Vapi API Key: a373381e-28be-492a-9733-0ac0ac7d939d',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _toggleSession() {
    if (_isSessionActive) return;
    
    setState(() {
      _isConnecting = true;
    });
    
    // Simulate connection delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isConnecting = false;
        _isSessionActive = true;
        _lastResponse = 'Voice session started! You can now speak in ${_languages[_currentLanguage]}.';
      });
      
      _showSessionStartedDialog();
    });
  }

  void _stopSession() {
    setState(() {
      _isSessionActive = false;
      _lastResponse = 'Voice session ended. Tap microphone to start again.';
    });
  }

  void _showSessionStartedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎤 Session Started'),
        content: Text(
          'Voice session is now active in ${_languages[_currentLanguage]}!\n\n'
          'Features:\n'
          '• Real-time speech recognition\n'
          '• AI-powered responses\n'
          '• Multilingual support\n'
          '• Agricultural expertise\n\n'
          'Try asking about crops, weather, or farming tips!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Start Speaking!'),
          ),
        ],
      ),
    );
  }

  void _showLanguageChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language Changed'),
        content: Text(
          'Voice recognition and responses will now be in ${_languages[_currentLanguage]}.\n\n'
          'Continue speaking in your selected language.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
