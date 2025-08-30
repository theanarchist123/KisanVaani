import 'package:flutter/material.dart';
import '../services/vapi_service.dart';

class VapiProvider extends ChangeNotifier {
  final VapiService _vapiService = VapiService();
  
  bool _isSessionActive = false;
  bool _isConnecting = false;
  String _currentTranscription = '';
  String _currentResponse = '';
  String _errorMessage = '';
  List<ConversationMessage> _conversationHistory = [];
  
  // Getters
  bool get isSessionActive => _isSessionActive;
  bool get isConnecting => _isConnecting;
  String get currentTranscription => _currentTranscription;
  String get currentResponse => _currentResponse;
  String get errorMessage => _errorMessage;
  List<ConversationMessage> get conversationHistory => _conversationHistory;
  VapiService get vapiService => _vapiService;
  
  VapiProvider() {
    _initializeStreams();
  }
  
  /// Initialize stream listeners
  void _initializeStreams() {
    // Listen to transcription updates
    _vapiService.transcriptionStream.listen((transcription) {
      _currentTranscription = transcription;
      notifyListeners();
    });
    
    // Listen to AI response updates
    _vapiService.responseStream.listen((response) {
      _currentResponse = response;
      
      // Add to conversation history
      if (response.isNotEmpty) {
        _addToConversation(response, isUser: false);
      }
      
      notifyListeners();
    });
    
    // Listen to session state changes
    _vapiService.sessionStateStream.listen((isActive) {
      _isSessionActive = isActive;
      _isConnecting = false;
      
      if (!isActive) {
        _currentTranscription = '';
        _currentResponse = '';
      }
      
      notifyListeners();
    });
    
    // Listen to errors
    _vapiService.errorStream.listen((error) {
      _errorMessage = error;
      _isConnecting = false;
      notifyListeners();
    });
  }
  
  /// Start a new Vapi voice session
  Future<void> startVoiceSession(String language) async {
    try {
      _isConnecting = true;
      _errorMessage = '';
      notifyListeners();
      
      await _vapiService.initialize(language: language);
      await _vapiService.startSession(language: language);
      
      // Add session start message to history
      _addToConversation('Voice session started. Ask me anything about farming!', isUser: false);
      
    } catch (e) {
      _errorMessage = 'Failed to start voice session: ${e.toString()}';
      _isConnecting = false;
      notifyListeners();
    }
  }
  
  /// End the current voice session
  Future<void> endVoiceSession() async {
    try {
      await _vapiService.endSession();
      
      // Add session end message to history
      _addToConversation('Voice session ended. Tap the mic to start again!', isUser: false);
      
    } catch (e) {
      _errorMessage = 'Error ending session: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Send a text query (for testing)
  Future<void> sendTextQuery(String query) async {
    try {
      if (query.trim().isEmpty) return;
      
      // Add user message to history
      _addToConversation(query, isUser: true);
      
      await _vapiService.sendTextQuery(query);
      
    } catch (e) {
      _errorMessage = 'Failed to send query: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Change language during active session
  Future<void> changeLanguage(String newLanguage) async {
    try {
      await _vapiService.changeLanguage(newLanguage);
      
      // Add language change message to history
      _addToConversation('Language changed. You can now speak in your preferred language.', isUser: false);
      
    } catch (e) {
      _errorMessage = 'Failed to change language: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Add message to conversation history
  void _addToConversation(String message, {required bool isUser}) {
    final conversationMessage = ConversationMessage(
      text: message,
      isUser: isUser,
      timestamp: DateTime.now(),
    );
    
    _conversationHistory.add(conversationMessage);
    
    // Keep only last 50 messages to prevent memory issues
    if (_conversationHistory.length > 50) {
      _conversationHistory.removeAt(0);
    }
    
    notifyListeners();
  }
  
  /// Clear conversation history
  void clearConversationHistory() {
    _conversationHistory.clear();
    notifyListeners();
  }
  
  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
  
  @override
  void dispose() {
    _vapiService.dispose();
    super.dispose();
  }
}

/// Conversation message model
class ConversationMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  ConversationMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
