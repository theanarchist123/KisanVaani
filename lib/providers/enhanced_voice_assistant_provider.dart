import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/rag_service.dart';
import '../services/vapi_service.dart';

enum VoiceAssistantMode {
  local,    // Local speech-to-text + RAG backend
  vapi,     // Full Vapi integration with speech-to-speech
}

class EnhancedVoiceAssistantProvider extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final VapiService _vapiService = VapiService();
  
  bool _isListening = false;
  bool _isAvailable = false;
  bool _isSpeaking = false;
  bool _isProcessing = false;
  bool _ragBackendHealthy = false;
  bool _vapiConnected = false;
  
  String _lastWords = '';
  String _lastResponse = '';
  String _confidence = '';
  String _processingTime = '';
  
  VoiceAssistantMode _currentMode = VoiceAssistantMode.local;

  // Getters
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  bool get isSpeaking => _isSpeaking;
  bool get isProcessing => _isProcessing;
  bool get ragBackendHealthy => _ragBackendHealthy;
  bool get vapiConnected => _vapiConnected;
  String get lastWords => _lastWords;
  String get lastResponse => _lastResponse;
  String get confidence => _confidence;
  String get processingTime => _processingTime;
  VoiceAssistantMode get currentMode => _currentMode;

  EnhancedVoiceAssistantProvider() {
    _initializeServices();
  }

  /// Initialize all voice services
  Future<void> _initializeServices() async {
    await _initializeSpeech();
    await _initializeTts();
    await _checkRAGBackendHealth();
    await _initializeVapi();
  }

  /// Initialize speech-to-text
  Future<void> _initializeSpeech() async {
    _isAvailable = await _speechToText.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          notifyListeners();
        }
      },
      onError: (error) {
        print('Speech error: $error');
        _isListening = false;
        notifyListeners();
      },
    );
    notifyListeners();
  }

  /// Initialize text-to-speech
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('en-US'); // Changed to English for RAG
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  /// Check RAG backend health with retry mechanism
  Future<void> _checkRAGBackendHealth() async {
    print('Checking RAG backend health...');
    // First try
    _ragBackendHealthy = await RAGService.isHealthy();
    
    // If failed on first try, attempt with a short delay
    if (!_ragBackendHealthy) {
      print('First health check failed, retrying in 500ms...');
      await Future.delayed(const Duration(milliseconds: 500));
      _ragBackendHealthy = await RAGService.isHealthy();
      
      // If still failed, try one more time with longer delay
      if (!_ragBackendHealthy) {
        print('Second health check failed, retrying in 1s...');
        await Future.delayed(const Duration(seconds: 1));
        _ragBackendHealthy = await RAGService.isHealthy();
      }
    }
    
    print('RAG Backend Health: $_ragBackendHealthy');
    notifyListeners();
  }

  /// Initialize Vapi service
  Future<void> _initializeVapi() async {
    _vapiService.onConnectionChanged = (connected) {
      _vapiConnected = connected;
      notifyListeners();
    };

    _vapiService.onTranscriptReceived = (transcript) {
      _lastWords = transcript;
      notifyListeners();
    };

    _vapiService.onMessageReceived = (message) {
      print('Vapi message: $message');
    };

    // Try to connect to Vapi
    _vapiConnected = await _vapiService.connect();
    notifyListeners();
  }

  /// Switch between voice assistant modes
  Future<void> switchMode(VoiceAssistantMode mode) async {
    if (_currentMode == mode) return;

    await stopListening();
    await stopSpeaking();

    _currentMode = mode;
    
    if (mode == VoiceAssistantMode.vapi && !_vapiConnected) {
      await _initializeVapi();
    }
    
    notifyListeners();
  }

  /// Start listening based on current mode
  Future<void> startListening() async {
    if (_currentMode == VoiceAssistantMode.vapi && _vapiConnected) {
      await _startVapiConversation();
    } else {
      await _startLocalListening();
    }
  }

  /// Start local speech-to-text listening
  Future<void> _startLocalListening() async {
    if (!_isAvailable) {
      await _initializeSpeech();
    }

    if (_isAvailable && !_isListening) {
      _isListening = true;
      _lastWords = '';
      notifyListeners();

      await _speechToText.listen(
        onResult: (result) async {
          _lastWords = result.recognizedWords;
          _confidence = result.hasConfidenceRating 
            ? (result.confidence * 100).toStringAsFixed(1)
            : '';
          notifyListeners();

          // Process with RAG when speech is finalized
          if (result.finalResult && _lastWords.isNotEmpty) {
            await _processWithRAG(_lastWords);
          }
        },
        localeId: 'en-US', // Changed to English for better RAG processing
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  /// Start Vapi conversation
  Future<void> _startVapiConversation() async {
    if (_vapiConnected) {
      try {
        await _vapiService.startConversation(
          assistantId: 'farming_assistant', // You'll need to create this in Vapi
          metadata: {
            'user_type': 'farmer',
            'app': 'kisaan_vaani',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        _isListening = true;
        notifyListeners();
      } catch (e) {
        print('Error starting Vapi conversation: $e');
        // Fallback to local processing
        await _startLocalListening();
      }
    } else {
      // Fallback to local processing if Vapi isn't connected
      print('Vapi not connected, using local speech-to-text');
      await _startLocalListening();
    }
  }

  /// Process voice input (public method for manual triggers)
  Future<void> processVoiceInput(String userInput) async {
    await _processWithRAG(userInput);
  }

  /// Process user input with RAG backend
  Future<void> _processWithRAG(String userInput) async {
    if (!_ragBackendHealthy) {
      print('RAG backend offline, checking health...');
      await _checkRAGBackendHealth();
      if (!_ragBackendHealthy) {
        print('RAG backend still offline, using fallback mode');
        await _respondWithFallback(userInput);
        return;
      }
    }

    _isProcessing = true;
    notifyListeners();

    try {
      print('Processing query with RAG: "$userInput"');
      final stopwatch = Stopwatch()..start();
      
      final ragResponse = await RAGService.queryRAG(
        question: userInput,
        maxChunks: 5,
        similarityThreshold: 0.7,
      );

      stopwatch.stop();
      _processingTime = '${stopwatch.elapsedMilliseconds}ms';

      if (ragResponse != null && ragResponse.success) {
        _lastResponse = ragResponse.answer;
        await speak(_lastResponse);
        
        print('🤖 RAG Response: $_lastResponse');
        print('⏱️ Processing Time: $_processingTime');
        print('📚 Sources: ${ragResponse.chunks.length} chunks');
      } else {
        print('RAG query failed or returned unsuccessful response');
        await _respondWithFallback(userInput);
      }
    } catch (e) {
      print('Error processing with RAG: $e');
      await _respondWithFallback(userInput);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Fallback response when RAG is unavailable
  Future<void> _respondWithFallback(String userInput) async {
    _lastResponse = _processLocalVoiceCommand(userInput);
    await speak(_lastResponse);
  }

  /// Local voice command processing (fallback)
  String _processLocalVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    
    if (lowerCommand.contains('hello') || lowerCommand.contains('hi')) {
      return 'Hello! I am Kisaan Vaani, your farming assistant. How can I help you today?';
    }
    
    if (lowerCommand.contains('crop') || lowerCommand.contains('farming')) {
      return 'I can help you with crop management, farming techniques, and agricultural advice. What specific information do you need?';
    }
    
    if (lowerCommand.contains('weather')) {
      return 'For weather information, I recommend checking the weather section in the app. I can help with farming decisions based on weather conditions.';
    }
    
    if (lowerCommand.contains('yield') || lowerCommand.contains('prediction')) {
      return 'I can help predict crop yields using AI. Please use the Yield Prediction feature in the app for detailed analysis.';
    }
    
    if (lowerCommand.contains('help')) {
      return 'I can assist with farming questions, crop management, agricultural techniques, and more. Try asking about specific crops or farming challenges.';
    }
    
    return 'I understand you said: $command. I can help with farming questions, crop management, and agricultural advice. Could you please rephrase your question?';
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_currentMode == VoiceAssistantMode.vapi && _vapiConnected) {
      _vapiService.stopConversation();
    } else if (_isListening) {
      await _speechToText.stop();
    }
    
    _isListening = false;
    notifyListeners();
  }

  /// Speak text using TTS
  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    if (_vapiConnected) {
      _vapiService.stopConversation();
    }
  }

  /// Get system status
  Map<String, dynamic> getSystemStatus() {
    return {
      'speech_available': _isAvailable,
      'rag_backend_healthy': _ragBackendHealthy,
      'vapi_connected': _vapiConnected,
      'current_mode': _currentMode.toString(),
      'is_listening': _isListening,
      'is_speaking': _isSpeaking,
      'is_processing': _isProcessing,
    };
  }

  /// Refresh all services
  Future<void> refreshServices() async {
    await _checkRAGBackendHealth();
    if (!_vapiConnected) {
      await _initializeVapi();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    _vapiService.disconnect();
    super.dispose();
  }
}
