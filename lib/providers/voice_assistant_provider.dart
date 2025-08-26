import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistantProvider extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isListening = false;
  bool _isAvailable = false;
  bool _isSpeaking = false;
  String _lastWords = '';
  String _confidence = '';

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  bool get isSpeaking => _isSpeaking;
  String get lastWords => _lastWords;
  String get confidence => _confidence;

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
        onResult: (result) {
          _lastWords = result.recognizedWords;
          _confidence = result.hasConfidenceRating 
            ? (result.confidence * 100).toStringAsFixed(1)
            : '';
          notifyListeners();
        },
        localeId: 'hi-IN',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
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
      await _flutterTts.speak(text);
    }
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  // Process voice commands for farming
  String processVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    
    // Expense tracking commands
    if (lowerCommand.contains('expense') || lowerCommand.contains('rupees') || lowerCommand.contains('bought') || lowerCommand.contains('cost')) {
      return _processExpenseCommand(command);
    }
    
    // Crop health queries
    if (lowerCommand.contains('how are') || lowerCommand.contains('health') || lowerCommand.contains('condition')) {
      return _processCropHealthQuery(command);
    }
    
    // Weather queries
    if (lowerCommand.contains('weather') || lowerCommand.contains('rain') || lowerCommand.contains('temperature')) {
      return _processWeatherQuery(command);
    }
    
    // Irrigation commands
    if (lowerCommand.contains('water') || lowerCommand.contains('irrigation') || lowerCommand.contains('watering')) {
      return _processIrrigationCommand(command);
    }
    
    // Yield prediction queries
    if (lowerCommand.contains('yield') || lowerCommand.contains('production') || lowerCommand.contains('harvest') || lowerCommand.contains('predict')) {
      return _processYieldPredictionQuery(command);
    }
    
    return 'Sorry, I didn\'t understand. Please try again.';
  }

  String _processExpenseCommand(String command) {
    // Extract amount from voice command
    final RegExp amountRegex = RegExp(r'(\d+)\s*रुपए');
    final match = amountRegex.firstMatch(command);
    
    if (match != null) {
      final amount = match.group(1);
      String category = 'other';
      
      if (command.contains('medicine') || command.contains('pesticide')) category = 'pesticide';
      else if (command.contains('fertilizer') || command.contains('manure')) category = 'fertilizer';
      else if (command.contains('seeds') || command.contains('seed')) category = 'seeds';
      else if (command.contains('labor') || command.contains('worker')) category = 'labor';
      
      return 'Your $amount rupees expense for $category has been recorded.';
    }
    
    return 'Please tell the amount, like "bought medicine for 500 rupees".';
  }

  String _processCropHealthQuery(String command) {
    if (command.contains('tomato')) {
      return 'Your tomatoes are healthy and in flowering stage. Crop will be ready in 75 days.';
    } else if (command.contains('wheat')) {
      return 'Wheat crop needs attention. Water shortage is visible.';
    } else if (command.contains('onion')) {
      return 'Onion plants are growing well. Crop will be ready in 120 days.';
    }
    
    return 'All your crops are in good condition. Tomatoes are doing best.';
  }

  String _processWeatherQuery(String command) {
    return 'Today\'s weather is clear, temperature is 28°C. Light rain expected tomorrow.';
  }

  String _processIrrigationCommand(String command) {
    return 'Irrigation time for your farm is tomorrow morning at 6 AM. Water the tomatoes and wheat.';
  }

  String _processYieldPredictionQuery(String command) {
    final lowerCommand = command.toLowerCase();
    
    if (lowerCommand.contains('predict') || lowerCommand.contains('production')) {
      return 'I can help you predict crop yield using AI. Please go to the Yield Prediction section in the app to enter your crop details like rainfall, temperature, and soil type for accurate predictions.';
    } else if (lowerCommand.contains('yield') || lowerCommand.contains('harvest')) {
      return 'Based on current conditions, your crops are expected to have good yield this season. For detailed AI predictions, use the Yield Prediction feature in the app.';
    }
    
    return 'I can help predict your crop yield using machine learning. Please use the Yield Prediction tool in the app for detailed analysis.';
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}
