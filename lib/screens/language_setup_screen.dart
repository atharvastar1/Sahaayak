import '../services/language_manager.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/sahaayak_theme.dart';
import '../services/voice_service.dart';
import 'shell_screen.dart';

class LanguageSetupScreen extends StatefulWidget {
  const LanguageSetupScreen({super.key});

  @override
  State<LanguageSetupScreen> createState() => _LanguageSetupScreenState();
}

class _LanguageSetupScreenState extends State<LanguageSetupScreen> {
  String? _selectedLang;

  @override
  void initState() {
    super.initState();
    _startVoiceGreeting();
  }

  void _startVoiceGreeting() {
    Future.delayed(const Duration(milliseconds: 500), () => VoiceService.speak('Please choose your language.', 'en'));
    Future.delayed(const Duration(milliseconds: 2500), () => VoiceService.speak('अपनी भाषा चुनें।', 'hi'));
  }

  final List<Map<String, dynamic>> _languages = [
    {'name': 'English', 'code': 'en', 'label': 'English', 'icon': '🌍', 'sub': 'Global'},
    {'name': 'हिंदी', 'code': 'hi', 'label': 'Hindi', 'icon': '🇮🇳', 'sub': 'North India'},
    {'name': 'বাংলা', 'code': 'bn', 'label': 'Bengali', 'icon': '🇧🇩', 'sub': 'East India'},
    {'name': 'తెలుగు', 'code': 'te', 'label': 'Telugu', 'icon': '🛕', 'sub': 'South India'},
    {'name': 'मराठी', 'code': 'mr', 'label': 'Marathi', 'icon': '🚩', 'sub': 'West India'},
    {'name': 'தமிழ்', 'code': 'ta', 'label': 'Tamil', 'icon': '🏛️', 'sub': 'South India'},
    {'name': 'اردو', 'code': 'ur', 'label': 'Urdu', 'icon': '🕌', 'sub': 'Nationwide'},
    {'name': 'ગુજરાતી', 'code': 'gu', 'label': 'Gujarati', 'icon': '🦁', 'sub': 'West India'},
    {'name': 'ಕನ್ನಡ', 'code': 'kn', 'label': 'Kannada', 'icon': '🐘', 'sub': 'South India'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Language',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SahaayakTheme.primaryBlue, letterSpacing: 1),
                    ).animate().fadeIn(),
                    const SizedBox(height: 8),
                    const Text(
                      'अपनी भाषा चुनें',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34, letterSpacing: -1),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 100)).slideX(begin: -0.1),
                    const SizedBox(height: 12),
                    const Text(
                      'Sahaayak will talk to you in this language.',
                      style: TextStyle(color: SahaayakTheme.textSecondary, fontSize: 17),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedLang == lang['code'];
                    return _buildLanguageCard(lang, isSelected);
                  },
                  childCount: _languages.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: ElevatedButton(
            onPressed: _selectedLang == null ? null : () {
              final languageManager = LanguageManager.of(context);
              if (languageManager != null) {
                 languageManager.onLanguageChanged(_selectedLang!);
              }
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ShellScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SahaayakTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              disabledBackgroundColor: SahaayakTheme.offlineGrey.withValues(alpha: 0.2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(Map<String, dynamic> lang, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedLang = lang['code']);
        VoiceService.speak(lang['name'], lang['code']);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? SahaayakTheme.primaryBlue : SahaayakTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? SahaayakTheme.primaryBlue : Colors.black.withValues(alpha: 0.05),
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: SahaayakTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang['icon'], style: const TextStyle(fontSize: 20)),
            const Spacer(),
            Text(
              lang['name'],
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: isSelected ? Colors.white : SahaayakTheme.textMain,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              lang['sub'],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white.withValues(alpha: 0.8) : SahaayakTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.03, 1.03)),
    );
  }
}
