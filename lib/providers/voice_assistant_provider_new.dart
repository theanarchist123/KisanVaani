import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/elevenlabs_service.dart';
import '../services/ai_assistant_service.dart';

class VoiceAssistantProvider extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final ElevenLabsService _elevenLabsService = ElevenLabsService();
  final AIAssistantService _aiAssistantService = AIAssistantService();
  
  bool _isListening = false;
  bool _isAvailable = false;
  bool _isSpeaking = false;
  bool _isProcessing = false;
  String _lastWords = '';
  String _confidence = '';
  String _lastResponse = '';

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  bool get isSpeaking => _isSpeaking;
  bool get isProcessing => _isProcessing;
  String get lastWords => _lastWords;
  String get confidence => _confidence;
  String get lastResponse => _lastResponse;

  VoiceAssistantProvider() {
    _initializeSpeech();
    _initializeTts();
  }

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

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('hi-IN');
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

  Future<void> startListening() async {
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
          
          // Process the query when listening is complete
          if (result.finalResult && _lastWords.isNotEmpty) {
            await _processVoiceQuery(_lastWords);
          }
        },
        localeId: 'hi-IN',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  /// Process voice query using AI assistant and respond with ElevenLabs
  Future<void> _processVoiceQuery(String query) async {
    try {
      _isProcessing = true;
      notifyListeners();
      
      print('Processing voice query: $query');
      
      // Get AI response
      final response = await _aiAssistantService.processQuery(query);
      _lastResponse = response;
      notifyListeners();
      
      // Speak response using ElevenLabs
      _isSpeaking = true;
      notifyListeners();
      
      final success = await _elevenLabsService.speakText(response);
      
      if (!success) {
        // Fallback to Flutter TTS if ElevenLabs fails
        print('ElevenLabs failed, using Flutter TTS as fallback');
        await _flutterTts.speak(response);
      }
      
    } catch (e) {
      print('Error processing voice query: $e');
      _lastResponse = 'माफ करें, कुछ समस्या हुई है। कृपया दोबारा कोशिश करें।';
      await _flutterTts.speak(_lastResponse);
    } finally {
      _isProcessing = false;
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      _isListening = false;
      await _speechToText.stop();
      notifyListeners();
    }
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      try {
        _isSpeaking = true;
        notifyListeners();
        
        // Try ElevenLabs first
        final success = await _elevenLabsService.speakText(text);
        
        if (!success) {
          // Fallback to Flutter TTS
          await _flutterTts.speak(text);
        }
      } catch (e) {
        print('Error in speak method: $e');
        await _flutterTts.speak(text);
      } finally {
        _isSpeaking = false;
        notifyListeners();
      }
    }
  }

  /// Process text query manually (for typed input)
  Future<void> processTextQuery(String query) async {
    if (query.trim().isEmpty) return;
    
    _lastWords = query;
    notifyListeners();
    
    await _processVoiceQuery(query);
  }

  /// Stop current speech
  Future<void> stopSpeaking() async {
    try {
      await _elevenLabsService.stopSpeaking();
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      print('Error stopping speech: $e');
    }
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    _elevenLabsService.dispose();
    super.dispose();
  }
}
