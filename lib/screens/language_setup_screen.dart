import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/sahaayak_theme.dart';
import '../services/language_manager.dart';
import '../services/voice_service.dart';
import 'shell_screen.dart';
import 'widgets.dart';

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
    {'name': 'English', 'code': 'en', 'label': 'English', 'icon': 'AN', 'sub': 'International'},
    {'name': 'हिंदी', 'code': 'hi', 'label': 'Hindi', 'icon': 'अ', 'sub': 'Bharat'},
    {'name': 'मराठी', 'code': 'mr', 'label': 'Marathi', 'icon': 'म', 'sub': 'Bharat'},
    {'name': 'తెలుగు', 'code': 'te', 'label': 'Telugu', 'icon': 'తె', 'sub': 'Bharat'},
    {'name': 'தமிழ்', 'code': 'ta', 'label': 'Tamil', 'icon': 'த', 'sub': 'Bharat'},
    {'name': 'ગુજરાતી', 'code': 'gu', 'label': 'Gujarati', 'icon': 'ગુ', 'sub': 'Bharat'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayakTheme.background,
      body: Stack(
        children: [
          // Subtle accent background
          _buildSubtleAccents(),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 60, 32, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AnimatedLogo(size: 80, isAnimated: true),
                        const SizedBox(height: 32),
                        const Text(
                          'Sahaayak BharatBot',
                          style: TextStyle(
                            fontWeight: FontWeight.w800, 
                            fontSize: 48, 
                            letterSpacing: -2.5, 
                            color: SahaayakTheme.primaryDark,
                            height: 1.0,
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                        const SizedBox(height: 12),
                        Text(
                          'Choose your preferred language to begin your journey.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: SahaayakTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(delay: 500.ms),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final lang = _languages[index];
                        final isSelected = _selectedLang == lang['code'];
                        return _buildModernLangCard(lang, isSelected);
                      },
                      childCount: _languages.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
          
          // Fixed Bottom Action
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildActionBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtleAccents() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SahaayakTheme.primary.withValues(alpha: 0.03),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernLangCard(Map<String, dynamic> lang, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedLang = lang['code']);
        VoiceService.speak(lang['name'], lang['code']);
      },
      child: AnimatedContainer(
        duration: 400.ms,
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.all(24),
        decoration: isSelected 
          ? BoxDecoration(
              color: SahaayakTheme.primaryDark,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            )
          : SahaayakTheme.premiumCard(radius: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang['icon'], 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : SahaayakTheme.primary,
              ),
            ),
            const Spacer(),
            Text(
              lang['name'],
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: isSelected ? Colors.white : SahaayakTheme.primaryDark,
              ),
            ),
            Text(
              lang['sub'],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isSelected ? Colors.white.withValues(alpha: 0.5) : SahaayakTheme.textSecondary,
              ),
            ),
          ],
        ),
      ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
    );
  }

  Widget _buildActionBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SahaayakTheme.background.withValues(alpha: 0.0),
            SahaayakTheme.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.4],
        ),
      ),
      child: ElevatedButton(
        onPressed: _selectedLang == null ? null : () {
          final languageManager = LanguageManager.of(context);
          if (languageManager != null) {
             languageManager.onLanguageChanged(_selectedLang!);
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ShellScreen()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: SahaayakTheme.primaryDark,
          minimumSize: const Size(double.infinity, 72),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: const Text(
          'CONTINUE', 
          style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.w800),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }
}

