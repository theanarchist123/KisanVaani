import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../providers/hybrid_translation_provider.dart';
import '../providers/voice_assistant_provider.dart';
import '../utils/translation_utils.dart';
import 'home_screen.dart';
import 'farm_features_screen.dart';
import 'knowledge_screen.dart';
import 'community_screen.dart';
import 'government_schemes_screen.dart';
import 'profile_screen.dart';
import 'simple_vapi_page.dart';
import '../widgets/voice_assistant_fab.dart';
import '../utils/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Start with Farm Features as primary focus

  final List<Widget> _screens = [
    const HomeScreen(),
    const FarmFeaturesScreen(),
    const KnowledgeScreen(),
    const GovernmentSchemesScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  String _getScreenTitleKey(int index) {
    switch (index) {
      case 0:
        return 'home';
      case 1:
        return 'farm_features';
      case 2:
        return 'knowledge';
      case 3:
        return 'government_schemes';
      case 4:
        return 'community';
      case 5:
        return 'profile';
      default:
        return 'app_name';
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize sample farm data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmProvider>().initializeSampleFarm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: TranslatedText(
          _getScreenTitleKey(_currentIndex),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Consumer<HybridTranslationProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.language, size: 28),
                onSelected: (String languageCode) {
                  provider.changeLanguage(languageCode);
                },
                itemBuilder: (BuildContext context) {
                  return HybridTranslationProvider.supportedLanguages.entries.map((entry) {
                    return PopupMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          if (provider.currentLanguage == entry.key)
                            const Icon(
                              Icons.check,
                              color: AppTheme.primaryGreen,
                              size: 18,
                            ),
                          if (provider.currentLanguage == entry.key)
                            const SizedBox(width: 8),
                          Text(entry.value),
                        ],
                      ),
                    );
                  }).toList();
                },
              );
            },
          ),
          // Vapi Voice Assistant Button
          IconButton(
            icon: const Icon(Icons.mic, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SimpleVapiPage(),
              ),
            ),
            tooltip: 'Voice Assistant (Vapi)',
          ),
          // AI Voice Test Button
          IconButton(
            icon: const Icon(Icons.psychology_outlined, size: 28),
            onPressed: () => _testAIVoice(context),
            tooltip: 'Test AI Voice Assistant',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () => _showNotifications(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: const VoiceAssistantFAB(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.shifting,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 10,
          unselectedFontSize: 8,
          iconSize: 20,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: _getTranslatedLabel(context, 'home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.agriculture_outlined),
              activeIcon: const Icon(Icons.agriculture),
              label: _getTranslatedLabel(context, 'farm_features'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              activeIcon: const Icon(Icons.menu_book),
              label: _getTranslatedLabel(context, 'knowledge'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_outlined),
              activeIcon: const Icon(Icons.account_balance),
              label: _getTranslatedLabel(context, 'government_schemes'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_outline),
              activeIcon: const Icon(Icons.people),
              label: _getTranslatedLabel(context, 'community'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: _getTranslatedLabel(context, 'profile'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
              padding: EdgeInsets.all(16),
              child: TranslatedText(
                'notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildNotificationTile(
                    '🌧️',
                    _getTranslatedLabel(context, 'weather_alert'),
                    'Rain expected tomorrow. Protect your crops.',
                    '2 hours ago',
                  ),
                  _buildNotificationTile(
                    '🌾',
                    _getTranslatedLabel(context, 'crop_update'),
                    'Your tomatoes are ready to flower. Apply NPK fertilizer.',
                    '5 hours ago',
                  ),
                  _buildNotificationTile(
                    '💰',
                    _getTranslatedLabel(context, 'market_prices'),
                    'Tomato prices increased to ₹25 per kg.',
                    '1 day ago',
                  ),
                  _buildNotificationTile(
                    '🚨',
                    _getTranslatedLabel(context, 'warning'),
                    'Water shortage detected in wheat crops.',
                    '2 days ago',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    String emoji,
    String title,
    String subtitle,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                DynamicTranslatedText(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                DynamicTranslatedText(
                  time,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Safe helper method to get translated labels for BottomNavigationBar
  String _getTranslatedLabel(BuildContext context, String key) {
    try {
      return context.tr(key);
    } catch (e) {
      // Fallback to key if translation fails
      return key;
    }
  }

  /// Test method for AI Voice Assistant
  void _testAIVoice(BuildContext context) async {
    final voiceProvider = context.read<VoiceAssistantProvider>();
    
    // Show test options dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Voice Assistant Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose a test query:'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                voiceProvider.processTextQuery('आज का मौसम कैसा है?');
              },
              child: const Text('Weather Query'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                voiceProvider.processTextQuery('खेती के लिए कौन सी योजना है?');
              },
              child: const Text('Scheme Query'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                voiceProvider.processTextQuery('धान की खेती कैसे करें?');
              },
              child: const Text('Farming Query'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
