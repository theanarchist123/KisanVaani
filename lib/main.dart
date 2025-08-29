import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'screens/language_startup_screen.dart';
import 'providers/farm_provider.dart';
import 'providers/voice_assistant_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/government_scheme_provider.dart';
import 'providers/hybrid_translation_provider.dart';
import 'providers/language_provider.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const KisanVaaniApp());
}

class KisanVaaniApp extends StatelessWidget {
  const KisanVaaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Language state (source of truth)
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        // Hybrid translator synced to LanguageProvider
        ChangeNotifierProxyProvider<LanguageProvider, HybridTranslationProvider>(
          create: (_) => HybridTranslationProvider(),
          update: (context, lang, hybrid) {
            final h = hybrid ?? HybridTranslationProvider();
            // Keep hybrid provider language in sync
            h.changeLanguage(lang.currentLanguage);
            return h;
          },
        ),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => VoiceAssistantProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => GovernmentSchemeProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Kisan Vaani',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            // Add localization delegates and supported locales for AppLocalizations
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // Bind locale to our current language from LanguageProvider
            locale: languageProvider.currentLocale,
            routes: {
              '/main': (context) => const MainScreen(),
              '/language-startup': (context) => const LanguageStartupScreen(),
            },
            home: const LanguageStartupScreen(),
          );
        },
      ),
    );
  }
}
