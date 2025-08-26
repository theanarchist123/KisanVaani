import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'providers/farm_provider.dart';
import 'providers/voice_assistant_provider.dart';
import 'providers/weather_provider.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const KisanVaaniApp());
}

class KisanVaaniApp extends StatelessWidget {
  const KisanVaaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => VoiceAssistantProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: MaterialApp(
        title: 'Kisan Vaani',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
      ),
    );
  }
}
