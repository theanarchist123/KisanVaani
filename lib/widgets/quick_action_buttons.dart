import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';
import '../utils/app_theme.dart';
import '../screens/yield_prediction_screen.dart';
import '../screens/plant_disease_library_page.dart';

class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row of action buttons
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                '📷',
                'फोटो जांच',
                'फसल रोगों की जानकारी देखें',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlantDiseaseLibraryPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                '💰',
                'खर्च जोड़ें',
                'आवाज़ के साथ खर्च रिकॉर्ड करें',
                () => _showExpenseDialog(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row of action buttons
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                '🌧️',
                'मौसम चेतावनी',
                'आज और कल के मौसम की जांच करें',
                () => _showWeatherDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                '🤖',
                'उपज पूर्वानुमान',
                'AI-संचालित फसल उपज पूर्वानुमान',
                () => _showYieldPrediction(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpenseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<VoiceAssistantProvider>(
        builder: (context, voiceProvider, child) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Add Expense',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Voice Input Section
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (voiceProvider.isListening) {
                                    await voiceProvider.stopListening();
                                  } else {
                                    await voiceProvider.startListening();
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: voiceProvider.isListening 
                                      ? AppTheme.accentOrange 
                                      : Colors.white,
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: voiceProvider.isListening
                                      ? [
                                          BoxShadow(
                                            color: AppTheme.accentOrange.withOpacity(0.3),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ]
                                      : [],
                                  ),
                                  child: Icon(
                                    voiceProvider.isListening ? Icons.mic : Icons.mic_none,
                                    size: 40,
                                    color: voiceProvider.isListening 
                                      ? Colors.white 
                                      : AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                voiceProvider.isListening 
                                  ? 'Listening...' 
                                  : 'Tell expense by voice',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Example: "Bought medicine for 500 rupees"',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Voice Input Display
                        if (voiceProvider.lastWords.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    fontSize: 16,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 20),
                        
                        // Quick Expense Categories
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'या श्रेणी चुनें:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildExpenseChip('🌱 बीज', 'seeds'),
                            _buildExpenseChip('🧪 खाद', 'fertilizer'),
                            _buildExpenseChip('🐛 दवाई', 'pesticide'),
                            _buildExpenseChip('👨‍🌾 मजदूरी', 'labor'),
                            _buildExpenseChip('🚜 उपकरण', 'equipment'),
                            _buildExpenseChip('💧 सिंचाई', 'irrigation'),
                          ],
                        ),
                        
                        const Spacer(),
                        
                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: voiceProvider.lastWords.isNotEmpty 
                              ? () {
                                  // Process and save expense
                                  final response = voiceProvider.processVoiceCommand(voiceProvider.lastWords);
                                  voiceProvider.speak(response);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response),
                                      backgroundColor: AppTheme.primaryGreen,
                                    ),
                                  );
                                }
                              : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'खर्च सेव करें\n(Save Expense)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showWeatherDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'मौसम अलर्ट\n(Weather Alert)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Current Weather
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            '☀️',
                            style: TextStyle(fontSize: 48),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '28°C',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'धूप मौसम\n(Sunny Weather)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'नमी: 65% • हवा: 12 km/h',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Weather Advice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: AppTheme.accentOrange,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'मौसम अच्छा है। खेती के काम के लिए सही समय।\n(Weather is good. Perfect time for farm work.)',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Upcoming Alerts
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'आगामी अलर्ट',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildWeatherAlert('कल बारिश की संभावना', '🌧️'),
                    _buildWeatherAlert('परसों तेज़ धूप', '🌡️'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseChip(String label, String type) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () {
        // Handle expense category selection
      },
      backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
      side: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.3)),
    );
  }

  Widget _buildWeatherAlert(String message, String emoji) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showYieldPrediction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const YieldPredictionScreen(),
      ),
    );
  }
}
