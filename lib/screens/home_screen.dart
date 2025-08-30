import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const elevenLabsAgentUrl = 'https://elevenlabs.io/app/conversational-ai/agents/agent_5001k3w6cqvkfm9aj78qqtr51e2e';
  
  // Voice Assistant Components
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String _wordsSpoken = "";
  String _lastResponse = "";
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _initTts() async {
    await _flutterTts.setLanguage("hi-IN"); // Hindi
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _startListening() async {
    if (!_isListening && _speechEnabled) {
      setState(() {
        _isListening = true;
        _wordsSpoken = "";
      });
      
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: "hi_IN", // Hindi locale
      );
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    
    if (_wordsSpoken.isNotEmpty) {
      _processVoiceInput(_wordsSpoken);
    }
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
    });
  }

  Future<void> _processVoiceInput(String input) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate AI processing (replace with actual ElevenLabs API call)
      String response = await _callElevenLabsAPI(input);
      
      setState(() {
        _lastResponse = response;
        _isProcessing = false;
      });
      
      // Speak the response
      await _flutterTts.speak(response);
      
    } catch (e) {
      setState(() {
        _lastResponse = "क्षमा करें, कुछ त्रुटि हुई है। कृपया पुनः प्रयास करें।";
        _isProcessing = false;
      });
      await _flutterTts.speak("क्षमा करें, कुछ त्रुटि हुई है।");
    }
  }

  Future<String> _callElevenLabsAPI(String input) async {
    // This is a placeholder - you'll need to implement actual ElevenLabs API integration
    // For now, return farming-related responses based on input
    
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    
    if (input.toLowerCase().contains('मौसम') || input.toLowerCase().contains('weather')) {
      return "आज का मौसम फसल के लिए अच्छा है। तापमान 25 डिग्री है और हल्की बारिश की संभावना है।";
    } else if (input.toLowerCase().contains('फसल') || input.toLowerCase().contains('crop')) {
      return "इस मौसम में गेहूं और चना की बुआई के लिए सबसे अच्छा समय है। मिट्टी की नमी की जांच कर लें।";
    } else if (input.toLowerCase().contains('बीज') || input.toLowerCase().contains('seed')) {
      return "उच्च गुणवत्ता वाले बीज चुनें और बुआई से पहले बीज उपचार जरूर करें।";
    } else {
      return "मैं आपकी खेती से जुड़ी समस्याओं में मदद कर सकता हूं। मौसम, फसल, या बीज के बारे में पूछें।";
    }
  }

  Future<void> _launchElevenLabs() async {
    final Uri url = Uri.parse(elevenLabsAgentUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $elevenLabsAgentUrl');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'किसान वाणी',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Voice Assistant Avatar with Animation
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isListening ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.green[400]!,
                            Colors.green[700]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: _isListening ? 10 : 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.smart_toy,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'AI आवाज सहायक',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                _isListening 
                    ? 'सुन रहा हूं... बोलिए'
                    : _isProcessing
                        ? 'सोच रहा हूं...'
                        : 'आपका AI खेती सहायक तैयार है',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _isListening ? Colors.orange : Colors.grey,
                  fontWeight: _isListening ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Voice Input Display
              if (_wordsSpoken.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'आपने कहा:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _wordsSpoken,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // AI Response Display
              if (_lastResponse.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI सहायक का जवाब:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lastResponse,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Voice Control Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _speechEnabled
                      ? (_isListening ? _stopListening : _startListening)
                      : null,
                  icon: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isListening ? 'रुकिए' : 'बोलना शुरू करें',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.red[600] : Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Fallback: Open in Browser Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _launchElevenLabs,
                  icon: const Icon(Icons.launch, color: Colors.green),
                  label: const Text(
                    'ब्राउज़र में खोलें',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green[700]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 24,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'मौसम, फसल, बीज, या खेती से जुड़े सवाल पूछें। यह AI सहायक हिंदी में जवाब देगा।',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
