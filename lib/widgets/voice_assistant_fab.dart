import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';
import '../utils/app_theme.dart';

class VoiceAssistantFAB extends StatefulWidget {
  const VoiceAssistantFAB({super.key});

  @override
  State<VoiceAssistantFAB> createState() => _VoiceAssistantFABState();
}

class _VoiceAssistantFABState extends State<VoiceAssistantFAB>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceAssistantProvider>(
      builder: (context, voiceProvider, child) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background overlay when expanded
            if (_isExpanded)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleExpansion,
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),

            // Expanded action buttons
            if (_isExpanded) ...[
              Positioned(
                bottom: 140,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildSecondaryFAB(
                    Icons.camera_alt,
                    'फोटो जांच',
                    () {
                      _toggleExpansion();
                      _showCameraDiagnosis(context);
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 200,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildSecondaryFAB(
                    Icons.account_balance_wallet,
                    'खर्च जोड़ें',
                    () {
                      _toggleExpansion();
                      _showVoiceExpense(context, voiceProvider);
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 260,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildSecondaryFAB(
                    Icons.cloud,
                    'मौसम',
                    () {
                      _toggleExpansion();
                      voiceProvider.speak('आज का मौसम साफ है, तापमान 28 डिग्री है।');
                    },
                  ),
                ),
              ),
            ],

            // Main Voice Assistant FAB
            Container(
              margin: const EdgeInsets.only(bottom: 80),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse animation for listening state
                  if (voiceProvider.isListening)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.accentOrange.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        );
                      },
                    ),

                  // Main FAB
                  GestureDetector(
                    onTap: () async {
                      if (voiceProvider.isListening) {
                        await voiceProvider.stopListening();
                        if (voiceProvider.lastWords.isNotEmpty) {
                          final response = voiceProvider.processVoiceCommand(voiceProvider.lastWords);
                          await voiceProvider.speak(response);
                        }
                      } else {
                        await voiceProvider.startListening();
                      }
                    },
                    onLongPress: _toggleExpansion,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: voiceProvider.isListening
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.accentOrange,
                                  AppTheme.accentOrange.withBlue(100),
                                ],
                              )
                            : AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: voiceProvider.isListening 
                              ? AppTheme.accentOrange.withOpacity(0.4)
                              : AppTheme.primaryGreen.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        voiceProvider.isListening 
                          ? Icons.mic 
                          : _isExpanded 
                            ? Icons.close 
                            : Icons.mic_none,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Voice input display
            if (voiceProvider.isListening && voiceProvider.lastWords.isNotEmpty)
              Positioned(
                bottom: 170,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'आपने कहा:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        voiceProvider.lastWords,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSecondaryFAB(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCameraDiagnosis(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('कैमरा जांच फीचर जल्द ही आएगा!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _showVoiceExpense(BuildContext context, VoiceAssistantProvider voiceProvider) {
    voiceProvider.speak('अपना खर्च बताएं, जैसे कि 500 रुपए दवाई खरीदी');
    voiceProvider.startListening();
  }
}
