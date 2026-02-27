import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/voice_service.dart';
import 'services/language_manager.dart';
import 'screens/splash_screen.dart';
import 'theme/sahaayak_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VoiceService.init();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  runApp(const SahaayakApp());
}

class SahaayakApp extends StatefulWidget {
  const SahaayakApp({super.key});

  @override
  State<SahaayakApp> createState() => _SahaayakAppState();
}

class _SahaayakAppState extends State<SahaayakApp> {
  String _currentLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return LanguageManager(
      currentLanguage: _currentLanguage,
      onLanguageChanged: (String newLang) {
        setState(() {
          _currentLanguage = newLang;
        });
      },
      child: MaterialApp(
        title: 'Sahaayak AI',
        debugShowCheckedModeBanner: false,
        theme: SahaayakTheme.premiumTheme,
        builder: (context, child) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: child,
            ),
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
