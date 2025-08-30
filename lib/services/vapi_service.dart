import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

class VapiService {
  static const String _apiKey = 'a373381e-28be-492a-9733-0ac0ac7d939d';
  static const String _baseUrl = 'wss://api.vapi.ai';
  
  WebSocketChannel? _channel;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Stream controllers for real-time updates
  final StreamController<String> _transcriptionController = StreamController<String>.broadcast();
  final StreamController<String> _responseController = StreamController<String>.broadcast();
  final StreamController<bool> _sessionStateController = StreamController<bool>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  
  // Getters for streams
  Stream<String> get transcriptionStream => _transcriptionController.stream;
  Stream<String> get responseStream => _responseController.stream;
  Stream<bool> get sessionStateStream => _sessionStateController.stream;
  Stream<String> get errorStream => _errorController.stream;
  
  bool _isSessionActive = false;
  String _currentLanguage = 'en';
  
  bool get isSessionActive => _isSessionActive;
  
  /// Initialize Vapi service with language preference
  Future<void> initialize({required String language}) async {
    _currentLanguage = language;
    
    // Request microphone permission
    await _requestMicrophonePermission();
  }
  
  /// Request microphone permission
  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    
    if (status != PermissionStatus.granted) {
      _errorController.add('Microphone permission is required for voice chat');
      return false;
    }
    
    return true;
  }
  
  /// Start a new Vapi session with real-time voice Q&A
  Future<void> startSession({required String language}) async {
    try {
      _currentLanguage = language;
      
      // Check microphone permission
      if (!await _requestMicrophonePermission()) {
        return;
      }
      
      // Connect to Vapi WebSocket
      await _connectToVapi();
      
      _isSessionActive = true;
      _sessionStateController.add(true);
      
      print('Vapi session started successfully in $language');
      
    } catch (e) {
      print('Error starting Vapi session: $e');
      _errorController.add('Failed to start voice session: ${e.toString()}');
    }
  }
  
  /// Connect to Vapi WebSocket API
  Future<void> _connectToVapi() async {
    try {
      final uri = Uri.parse('$_baseUrl/ws');
      
      _channel = WebSocketChannel.connect(uri);
      
      // Send authentication and configuration
      final initMessage = {
        'type': 'session_start',
        'api_key': _apiKey,
        'config': {
          'language': _getVapiLanguageCode(_currentLanguage),
          'model': 'gpt-4',
          'voice_settings': {
            'provider': 'elevenlabs',
            'voice_id': _getVoiceIdForLanguage(_currentLanguage),
            'stability': 0.5,
            'similarity_boost': 0.75,
          },
          'transcription_settings': {
            'provider': 'deepgram',
            'language': _getVapiLanguageCode(_currentLanguage),
            'model': 'nova-2',
          },
          'system_prompt': _getSystemPromptForLanguage(_currentLanguage),
        }
      };
      
      _channel!.sink.add(jsonEncode(initMessage));
      
      // Listen to incoming messages
      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketClosed,
      );
      
    } catch (e) {
      throw Exception('Failed to connect to Vapi: $e');
    }
  }
  
  /// Handle incoming WebSocket messages
  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      final messageType = data['type'];
      
      switch (messageType) {
        case 'session_started':
          print('Vapi session established');
          break;
          
        case 'transcription':
          final text = data['text'] ?? '';
          _transcriptionController.add(text);
          print('Transcription: $text');
          break;
          
        case 'ai_response':
          final response = data['text'] ?? '';
          _responseController.add(response);
          print('AI Response: $response');
          break;
          
        case 'audio_response':
          _handleAudioResponse(data);
          break;
          
        case 'error':
          final error = data['message'] ?? 'Unknown error';
          _errorController.add(error);
          break;
          
        case 'session_ended':
          _handleSessionEnded();
          break;
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }
  
  /// Handle audio response from Vapi
  void _handleAudioResponse(Map<String, dynamic> data) async {
    try {
      final audioUrl = data['audio_url'];
      if (audioUrl != null) {
        // Play the audio response
        await _audioPlayer.play(UrlSource(audioUrl));
      }
    } catch (e) {
      print('Error playing audio response: $e');
    }
  }
  
  /// Handle WebSocket errors
  void _handleWebSocketError(error) {
    print('Vapi WebSocket error: $error');
    _errorController.add('Connection error: ${error.toString()}');
    _resetSession();
  }
  
  /// Handle WebSocket connection closed
  void _handleWebSocketClosed() {
    print('Vapi WebSocket connection closed');
    _resetSession();
  }
  
  /// Handle session ended
  void _handleSessionEnded() {
    print('Vapi session ended');
    _resetSession();
  }
  
  /// Send text query to Vapi (for testing or manual input)
  Future<void> sendTextQuery(String query) async {
    if (!_isSessionActive || _channel == null) {
      _errorController.add('No active session. Please start a session first.');
      return;
    }
    
    try {
      final message = {
        'type': 'text_input',
        'text': query,
      };
      
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      print('Error sending text query: $e');
      _errorController.add('Failed to send message: ${e.toString()}');
    }
  }
  
  /// Change language during active session
  Future<void> changeLanguage(String newLanguage) async {
    if (!_isSessionActive || _channel == null) {
      _currentLanguage = newLanguage;
      return;
    }
    
    try {
      _currentLanguage = newLanguage;
      
      final message = {
        'type': 'update_config',
        'config': {
          'language': _getVapiLanguageCode(newLanguage),
          'voice_settings': {
            'voice_id': _getVoiceIdForLanguage(newLanguage),
          },
          'transcription_settings': {
            'language': _getVapiLanguageCode(newLanguage),
          },
          'system_prompt': _getSystemPromptForLanguage(newLanguage),
        }
      };
      
      _channel!.sink.add(jsonEncode(message));
      print('Language changed to $newLanguage');
      
    } catch (e) {
      print('Error changing language: $e');
      _errorController.add('Failed to change language: ${e.toString()}');
    }
  }
  
  /// End the current session
  Future<void> endSession() async {
    if (!_isSessionActive) return;
    
    try {
      if (_channel != null) {
        final message = {'type': 'session_end'};
        _channel!.sink.add(jsonEncode(message));
        
        // Close the WebSocket connection
        await _channel!.sink.close();
      }
      
      // Stop any playing audio
      await _audioPlayer.stop();
      
      _resetSession();
      
      print('Vapi session ended successfully');
      
    } catch (e) {
      print('Error ending session: $e');
      _resetSession();
    }
  }
  
  /// Reset session state
  void _resetSession() {
    _isSessionActive = false;
    _channel = null;
    _sessionStateController.add(false);
  }
  
  /// Get Vapi language code from app language
  String _getVapiLanguageCode(String appLanguage) {
    switch (appLanguage) {
      case 'hi':
        return 'hi-IN';
      case 'gu':
        return 'gu-IN';
      case 'ta':
        return 'ta-IN';
      default:
        return 'en-US';
    }
  }
  
  /// Get appropriate voice ID for language
  String _getVoiceIdForLanguage(String language) {
    switch (language) {
      case 'hi':
        return 'pNInz6obpgDQGcFmaJgB'; // Hindi voice
      case 'gu':
        return 'EXAVITQu4vr4xnSDxMaL'; // Gujarati voice
      case 'ta':
        return 'flq6f7yk4E4fJM5XTYuZ'; // Tamil voice
      default:
        return '21m00Tcm4TlvDq8ikWAM'; // English voice
    }
  }
  
  /// Get system prompt for language
  String _getSystemPromptForLanguage(String language) {
    switch (language) {
      case 'hi':
        return '''
आप एक किसान सलाहकार AI असिस्टेंट हैं। किसानों को खेती, फसल, मौसम, सरकारी योजनाओं के बारे में सरल हिंदी में जवाब दें।
- हमेशा व्यावहारिक और सटीक जानकारी दें
- 2-3 वाक्यों में जवाब दें
- किसान-मित्र भाषा का प्रयोग करें
''';
      case 'gu':
        return '''
તમે એક ખેડૂત સલાહકાર AI સહાયક છો। ખેડૂતોને ખેતી, પાક, હવામાન, સરકારી યોજનાઓ વિશે સરળ ગુજરાતીમાં જવાબ આપો।
- હંમેશા વ્યાવહારિક અને સચોટ માહિતી આપો
- 2-3 વાક્યોમાં જવાબ આપો
- ખેડૂત-મિત્ર ભાષાનો ઉપયોગ કરો
''';
      case 'ta':
        return '''
நீங்கள் ஒரு விவசாய ஆலோசகர் AI உதவியாளர். விவசாயிகளுக்கு விவசாயம், பயிர், வானிலை, அரசு திட்டங்கள் பற்றி எளிய தமிழில் பதில் அளிக்கவும்.
- எப்போதும் நடைமுறை மற்றும் துல்லியமான தகவல்களை வழங்கவும்
- 2-3 வாக்கியங்களில் பதில் அளிக்கவும்
- விவசாயி-நட்பு மொழியைப் பயன்படுத்தவும்
''';
      default:
        return '''
You are a farmer advisory AI assistant. Help farmers with agriculture, crops, weather, and government schemes in simple English.
- Always provide practical and accurate information
- Keep responses to 2-3 sentences
- Use farmer-friendly language
''';
    }
  }
  
  /// Dispose resources
  void dispose() {
    endSession();
    _transcriptionController.close();
    _responseController.close();
    _sessionStateController.close();
    _errorController.close();
    _audioPlayer.dispose();
  }
}
