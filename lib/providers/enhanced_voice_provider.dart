import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/enhanced_ai_service.dart';

class EnhancedVoiceProvider with ChangeNotifier {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final EnhancedAIService _aiService = EnhancedAIService();
  
  // Voice session state
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  String _currentLanguage = 'en';
  String _recognizedText = '';
  String _lastResponse = '';
  String _statusMessage = '';
  bool _isRagBackendReady = false;
  String _responseSource = ''; // 'rag', 'gemini', 'demo', 'fallback'
  
  // Conversation history
  List<Map<String, String>> _conversationHistory = [];
  
  // Getters
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  bool get isSpeaking => _isSpeaking;
  bool get isActive => _isListening || _isProcessing || _isSpeaking;
  String get currentLanguage => _currentLanguage;
  String get recognizedText => _recognizedText;
  String get lastResponse => _lastResponse;
  String get statusMessage => _statusMessage;
  List<Map<String, String>> get conversationHistory => _conversationHistory;
  bool get isRagBackendReady => _isRagBackendReady;
  String get responseSource => _responseSource;
  
  EnhancedVoiceProvider() {
    _initializeTts();
    _checkRagBackendStatus();
  }
  
  /// Check RAG backend status periodically
  Future<void> _checkRagBackendStatus() async {
    try {
      _isRagBackendReady = await _aiService.isRagBackendReady();
      notifyListeners();
      print('🔍 RAG Backend Status: ${_isRagBackendReady ? "Ready" : "Not Available"}');
    } catch (e) {
      _isRagBackendReady = false;
      print('❌ RAG Backend Check Error: $e');
    }
  }
  
  /// Initialize text-to-speech
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(_getLanguageCode(_currentLanguage));
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(0.8);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _updateStatus('आपका सवाल पूछें / Ask your question');
      notifyListeners();
    });
  }
  
  /// Start voice session
  Future<void> startVoiceSession() async {
    try {
      print('Starting enhanced voice session...');
      
      // Request permissions
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        _updateStatus('Microphone permission required');
        return;
      }
      
      // Initialize speech recognition
      bool available = await _speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          _handleError('Speech recognition error');
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          if (status == 'done' && _recognizedText.isNotEmpty) {
            _processVoiceInput();
          }
        },
      );
      
      if (!available) {
        _updateStatus('Speech recognition not available');
        return;
      }
      
      // Start listening
      _startListening();
      
    } catch (e) {
      print('Voice session error: $e');
      _handleError('Failed to start voice session');
    }
  }
  
  /// Start listening for voice input
  void _startListening() {
    if (_isProcessing || _isSpeaking) return;
    
    _isListening = true;
    _recognizedText = '';
    _updateStatus(_getListeningMessage());
    notifyListeners();
    
    _speechToText.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        notifyListeners();
        
        if (result.finalResult && _recognizedText.isNotEmpty) {
          _stopListening();
        }
      },
      listenFor: Duration(seconds: 10),
      pauseFor: Duration(seconds: 3),
      partialResults: true,
      localeId: _getLanguageCode(_currentLanguage),
    );
  }
  
  /// Stop listening
  void _stopListening() {
    if (!_isListening) return;
    
    _isListening = false;
    _speechToText.stop();
    notifyListeners();
    
    if (_recognizedText.isNotEmpty) {
      _processVoiceInput();
    }
  }
  
  /// Process voice input with enhanced AI
  Future<void> _processVoiceInput() async {
    if (_recognizedText.isEmpty) return;
    
    try {
      _isProcessing = true;
      _updateStatus(_getProcessingMessage());
      notifyListeners();
      
      // Add user message to conversation
      _conversationHistory.add({
        'role': 'user',
        'message': _recognizedText,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      print('Processing voice input: $_recognizedText');
      
      // Check RAG backend status before processing
      await _checkRagBackendStatus();
      
      // Get AI response
      final response = await _aiService.processAgricultureQuery(_recognizedText, _currentLanguage);
      
      // Determine response source for UI indication
      if (response.contains('📚 Response based on')) {
        _responseSource = 'rag';
      } else if (_isDemoQuery(_recognizedText)) {
        _responseSource = 'demo';
      } else if (_isRagBackendReady) {
        _responseSource = 'gemini';
      } else {
        _responseSource = 'fallback';
      }
      
      _lastResponse = response;
      
      // Add AI response to conversation
      _conversationHistory.add({
        'role': 'assistant',
        'message': response,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _isProcessing = false;
      notifyListeners();
      
      // Speak the response
      await _speakResponse(response);
      
    } catch (e) {
      print('Processing error: $e');
      _isProcessing = false;
      _handleError('Failed to process your question');
    }
  }
  
  /// Speak AI response
  Future<void> _speakResponse(String text) async {
    try {
      _isSpeaking = true;
      _updateStatus(_getSpeakingMessage());
      notifyListeners();
      
      await _flutterTts.setLanguage(_getLanguageCode(_currentLanguage));
      await _flutterTts.speak(text);
      
    } catch (e) {
      print('TTS error: $e');
      _isSpeaking = false;
      _updateStatus('आपका सवाल पूछें / Ask your question');
      notifyListeners();
    }
  }
  
  /// Change language
  Future<void> changeLanguage(String language) async {
    _currentLanguage = language;
    await _flutterTts.setLanguage(_getLanguageCode(language));
    _updateStatus(_getReadyMessage());
    notifyListeners();
  }
  
  /// End voice session
  void endVoiceSession() {
    _speechToText.stop();
    _flutterTts.stop();
    
    _isListening = false;
    _isProcessing = false;
    _isSpeaking = false;
    _recognizedText = '';
    
    _updateStatus('Voice session ended');
    notifyListeners();
  }
  
  /// Toggle listening state
  void toggleListening() {
    if (_isListening) {
      _stopListening();
    } else if (!_isProcessing && !_isSpeaking) {
      _startListening();
    }
  }
  
  /// Handle errors
  void _handleError(String error) {
    _isListening = false;
    _isProcessing = false;
    _isSpeaking = false;
    _updateStatus(error);
    notifyListeners();
  }
  
  /// Update status message
  void _updateStatus(String message) {
    _statusMessage = message;
  }
  
  /// Get language code for TTS/STT
  String _getLanguageCode(String language) {
    switch (language) {
      case 'hi':
        return 'hi-IN';
      case 'gu':
        return 'gu-IN';
      case 'ta':
        return 'ta-IN';
      case 'en':
      default:
        return 'en-IN';
    }
  }
  
  /// Get localized status messages
  String _getListeningMessage() {
    switch (_currentLanguage) {
      case 'hi':
        return 'सुन रहा हूँ... अपना सवाल पूछें';
      case 'gu':
        return 'સાંભળી રહ્યો છું... તમારો પ્રશ્ન પૂછો';
      case 'ta':
        return 'கேட்டுக்கொண்டிருக்கிறேன்... உங்கள் கேள்வியைக் கேளுங்கள்';
      default:
        return 'Listening... Ask your question';
    }
  }
  
  String _getProcessingMessage() {
    switch (_currentLanguage) {
      case 'hi':
        return 'सोच रहा हूँ... कृपया प्रतीक्षा करें';
      case 'gu':
        return 'વિચારી રહ્યો છું... કૃપા કરીને રાહ જુઓ';
      case 'ta':
        return 'யோசித்துக்கொண்டிருக்கிறேன்... தயவுசெய்து காத்திருங்கள்';
      default:
        return 'Processing... Please wait';
    }
  }
  
  String _getSpeakingMessage() {
    switch (_currentLanguage) {
      case 'hi':
        return 'जवाब दे रहा हूँ...';
      case 'gu':
        return 'જવાબ આપી રહ્યો છું...';
      case 'ta':
        return 'பதில் சொல்கிறேன்...';
      default:
        return 'Speaking response...';
    }
  }
  
  String _getReadyMessage() {
    switch (_currentLanguage) {
      case 'hi':
        return 'आपका सवाल पूछें';
      case 'gu':
        return 'તમારો પ્રશ્ન પૂછો';
      case 'ta':
        return 'உங்கள் கேள்வியைக் கேளுங்கள்';
      default:
        return 'Ask your question';
    }
  }
  
  /// Simulate a voice query (for demo purposes)
  Future<void> simulateQuery(String query) async {
    try {
      _recognizedText = query;
      _updateStatus('Processing your question...');
      notifyListeners();
      
      // Add user message to conversation
      _conversationHistory.add({
        'role': 'user',
        'message': query,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      print('Processing demo query: $query');
      
      // Check RAG backend status
      await _checkRagBackendStatus();
      
      // Get AI response
      final response = await _aiService.processAgricultureQuery(query, _currentLanguage);
      
      // Determine response source
      if (response.contains('📚 Response based on')) {
        _responseSource = 'rag';
      } else if (_isDemoQuery(query)) {
        _responseSource = 'demo';
      } else if (_isRagBackendReady) {
        _responseSource = 'gemini';
      } else {
        _responseSource = 'fallback';
      }
      
      _lastResponse = response;
      
      // Add AI response to conversation
      _conversationHistory.add({
        'role': 'assistant',
        'message': response,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _updateStatus('Response ready');
      notifyListeners();
      
      // Speak the response
      await _speakResponse(response);
      
    } catch (e) {
      print('Demo query error: $e');
      _updateStatus('Failed to process question');
      notifyListeners();
    }
  }
  
  /// Check if this is one of our demo queries
  bool _isDemoQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return lowerQuery.contains('anand') && 
           (lowerQuery.contains('monsoon') || 
            lowerQuery.contains('forecast') || 
            lowerQuery.contains('maize') || 
            lowerQuery.contains('water'));
  }

  /// Clear conversation history
  void clearConversationHistory() {
    _conversationHistory.clear();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }
}
