import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/government_scheme_provider.dart';
import '../utils/app_theme.dart';

class VoiceInputWidget extends StatefulWidget {
  const VoiceInputWidget({super.key});

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Consumer<GovernmentSchemeProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildHeader(),
              _buildVoiceVisualizer(provider),
              _buildVoiceInput(provider),
              _buildSuggestions(provider),
              _buildActionButtons(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Voice Assistant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceVisualizer(GovernmentSchemeProvider provider) {
    if (provider.isListening) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
    }

    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: provider.isListening ? _scaleAnimation.value : 1.0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: provider.isListening 
                      ? AppTheme.primaryGreen
                      : Colors.grey[300],
                  boxShadow: provider.isListening
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  provider.isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVoiceInput(GovernmentSchemeProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.keyboard_voice,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Voice Input',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 60),
            child: Text(
              provider.voiceInput.isEmpty 
                  ? provider.isListening 
                      ? 'Listening...' 
                      : 'Tap the microphone to start speaking'
                  : provider.voiceInput,
              style: TextStyle(
                fontSize: 14,
                color: provider.voiceInput.isEmpty ? Colors.grey[600] : Colors.black87,
                fontStyle: provider.voiceInput.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(GovernmentSchemeProvider provider) {
    if (provider.lastParsedIntent.isEmpty) {
      return _buildInitialSuggestions();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Parsed Intent',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Intent: ${provider.lastParsedIntent}',
            style: const TextStyle(fontSize: 14),
          ),
          if (provider.extractedDetails.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Extracted Details:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            ...provider.extractedDetails.entries.map(
              (entry) => Text(
                '• ${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialSuggestions() {
    final suggestions = [
      'Apply for PM-KISAN scheme',
      'Check my application status',
      'Show fertilizer subsidy details',
      'Find Kisan Credit Card information',
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Try saying:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...suggestions.map(
            (suggestion) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _useSuggestion(suggestion),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(GovernmentSchemeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: provider.isListening 
                  ? () => provider.stopVoiceInput()
                  : () => provider.startVoiceInput(),
              icon: Icon(
                provider.isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
              ),
              label: Text(
                provider.isListening ? 'Stop Listening' : 'Start Listening',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.isListening 
                    ? Colors.red[600] 
                    : AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (provider.voiceInput.isNotEmpty) ...[
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _clearInput,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(
                Icons.clear,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _useSuggestion(String suggestion) {
    final provider = context.read<GovernmentSchemeProvider>();
    // Simulate voice input with the suggestion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing: $suggestion'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearInput() {
    // Clear the voice input
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input cleared'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
