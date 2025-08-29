import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/enhanced_rag_service.dart';
import '../services/vapi_service.dart';
import '../models/farm_models.dart';
import 'dart:async';

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
    print('Checking Enhanced RAG backend health...');
    // First try
    _ragBackendHealthy = await EnhancedRagService.isEnhancedServerRunning();
    
    // If failed on first try, attempt with a short delay
    if (!_ragBackendHealthy) {
      print('First health check failed, retrying in 500ms...');
      await Future.delayed(const Duration(milliseconds: 500));
      _ragBackendHealthy = await EnhancedRagService.isEnhancedServerRunning();
      
      // If still failed, try one more time with longer delay
      if (!_ragBackendHealthy) {
        print('Second health check failed, retrying in 1s...');
        await Future.delayed(const Duration(seconds: 1));
        _ragBackendHealthy = await EnhancedRagService.isEnhancedServerRunning();
      }
    }
    
    print('Enhanced RAG Backend Health: $_ragBackendHealthy');
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
      
      // Enhanced RAG with farmer context
      final enhancedResponse = await EnhancedRagService.queryWithContext(
        question: userInput,
        userContext: {
          'interaction_type': 'voice',
          'timestamp': DateTime.now().toIso8601String(),
        },
        conversationId: 'voice_${DateTime.now().millisecondsSinceEpoch}',
        maxChunks: 3, // Reduced for voice responses
        similarityThreshold: 0.6, // Lower threshold for voice
      );

      stopwatch.stop();
      _processingTime = '${stopwatch.elapsedMilliseconds}ms';

      if (enhancedResponse != null) {
        // Format response for voice
        _lastResponse = _formatResponseForVoice(enhancedResponse.answer);
        
        // Add urgency indicators
        if (enhancedResponse.urgency == 'urgent') {
          _lastResponse = "तुरंत ध्यान दें - $_lastResponse";
        } else if (enhancedResponse.urgency == 'high') {
          _lastResponse = "महत्वपूर्ण - $_lastResponse";
        }
        
        await speak(_lastResponse);
        
        print('🤖 Enhanced RAG Response: $_lastResponse');
        print('⏱️ Processing Time: $_processingTime');
        print('📊 Confidence: ${enhancedResponse.confidence}');
        print('🔥 Urgency: ${enhancedResponse.urgency}');
        print('📚 Sources: ${enhancedResponse.chunks.length} chunks');
      } else {
        print('Enhanced RAG query failed');
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

  /// Format response for voice output
  String _formatResponseForVoice(String text) {
    // Remove markdown formatting
    String voiceText = text.replaceAll(RegExp(r'\*\*|__|\*|_'), '');
    voiceText = voiceText.replaceAll(RegExp(r'#{1,6}\s'), '');
    
    // Replace bullet points with spoken format
    voiceText = voiceText.replaceAll('•', 'पहले,');
    voiceText = voiceText.replaceAll('-', '');
    
    // Replace technical terms with Hindi equivalents for better understanding
    voiceText = voiceText.replaceAll('fertilizer', 'खाद');
    voiceText = voiceText.replaceAll('pesticide', 'कीटनाशक');
    voiceText = voiceText.replaceAll('irrigation', 'सिंचाई');
    voiceText = voiceText.replaceAll('crop', 'फसल');
    
    // Limit length for voice (max ~100 words for clarity)
    List<String> words = voiceText.split(' ');
    if (words.length > 100) {
      voiceText = words.take(100).join(' ') + '... और जानकारी के लिए कृपया दोबारा पूछें।';
    }
    
    return voiceText.trim();
  }

  /// Fallback response when RAG is unavailable
  Future<void> _respondWithFallback(String userInput) async {
    _lastResponse = _processLocalVoiceCommand(userInput);
    await speak(_lastResponse);
  }

  /// Enhanced local voice command processing (fallback)
  String _processLocalVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    
    // Hindi/English greetings
    if (lowerCommand.contains('नमस्ते') || lowerCommand.contains('hello') || 
        lowerCommand.contains('hi') || lowerCommand.contains('namaste')) {
      return 'नमस्ते! मैं किसान वाणी हूं, आपका खेती सहायक। मैं आपकी कैसे मदद कर सकता हूं?';
    }
    
    // Farming topics
    if (lowerCommand.contains('खाद') || lowerCommand.contains('fertilizer')) {
      return 'खाद के लिए पहले मिट्टी की जांच कराएं। फसल के अनुसार यूरिया, डीएपी और पोटाश का संतुलित उपयोग करें।';
    }
    
    if (lowerCommand.contains('पानी') || lowerCommand.contains('सिंचाई') || 
        lowerCommand.contains('irrigation') || lowerCommand.contains('water')) {
      return 'सिंचाई के लिए ड्रिप या स्प्रिंकलर सिस्टम का उपयोग करें। सुबह या शाम के समय पानी दें जब सूरज कम हो।';
    }
    
    if (lowerCommand.contains('बीमारी') || lowerCommand.contains('disease') || 
        lowerCommand.contains('रोग')) {
      return 'फसल में बीमारी दिखे तो तुरंत प्रभावित भाग को हटाएं। जैविक दवाओं का प्राथमिकता दें और विशेषज्ञ से सलाह लें।';
    }
    
    if (lowerCommand.contains('कीट') || lowerCommand.contains('pest') || 
        lowerCommand.contains('insects')) {
      return 'कीट नियंत्रण के लिए नीम का तेल या जैविक कीटनाशक का उपयोग करें। नियमित निगरानी रखें।';
    }
    
    if (lowerCommand.contains('मौसम') || lowerCommand.contains('weather')) {
      return 'मौसम की जानकारी ऐप में देखें। बारिश से पहले फसल की सुरक्षा का इंतजाम करें।';
    }
    
    if (lowerCommand.contains('बाजार') || lowerCommand.contains('price') || 
        lowerCommand.contains('market')) {
      return 'बाजार भाव के लिए ई-नाम पोर्टल देखें या स्थानीय मंडी से संपर्क करें। सही समय पर बेचने से अच्छा दाम मिलता है।';
    }
    
    if (lowerCommand.contains('बीज') || lowerCommand.contains('seed')) {
      return 'अच्छी गुणवत्ता के बीज ही खरीदें। प्रमाणित बीजों का उपयोग करें और बुआई से पहले बीज उपचार जरूर करें।';
    }
    
    // Default response
    return 'मैं आपकी खेती से जुड़ी समस्याओं में मदद कर सकता हूं। कृपया अपना सवाल स्पष्ट रूप से पूछें।';
  }

  /// Initiate VAPI phone call for farmers
  Future<bool> initiateVoiceCall(String phoneNumber, {Map<String, dynamic>? farmerContext}) async {
    try {
      if (!_vapiConnected) {
        print('VAPI not connected, attempting to connect...');
        await _initializeVapi();
        if (!_vapiConnected) {
          print('Failed to connect to VAPI');
          return false;
        }
      }

      final response = await EnhancedRagService.initiateVoiceCall(
        phoneNumber: phoneNumber,
        farmerContext: farmerContext ?? {
          'app': 'kisaan_vaani',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response) {
        print('✅ Voice call initiated successfully to $phoneNumber');
      } else {
        print('❌ Failed to initiate voice call to $phoneNumber');
      }

      return response;
    } catch (e) {
      print('❌ Error initiating voice call: $e');
      return false;
    }
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
