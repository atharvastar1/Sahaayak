import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dashboard_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import '../theme/sahaayak_theme.dart';
import '../services/voice_service.dart';
import '../services/language_manager.dart';
import '../services/translations.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  List<Widget> _buildPages() {
    return [
      DashboardScreen(onProfileTap: () => setState(() => _currentIndex = 4)),
      const HomeScreen(),
      const SchemesScreen(),
      const VaultScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayakTheme.background,
      extendBody: true, // Allows body to flow under the floating glass nav
      body: IndexedStack(
        index: _currentIndex,
        children: _buildPages(),
      ),
      floatingActionButton: _currentIndex != 1 ? Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: FloatingActionButton.extended(
          onPressed: () => VoiceService.speak(Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'how_can_i_help'), LanguageManager.of(context)?.currentLanguage ?? 'en'),
          backgroundColor: SahaayakTheme.primaryBlue,
          elevation: 12, // More depth
          icon: const Icon(Icons.record_voice_over_rounded, color: Colors.white),
          label: Text(Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'voice_help'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ).animate().scale(delay: const Duration(milliseconds: 500)),
      ) : null,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.compass_calibration_rounded, Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'tab_today')),
                  _buildNavItem(1, Icons.mic_rounded, Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'tab_voice')),
                  _buildNavItem(2, Icons.square_rounded, Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'tab_library')),
                  _buildNavItem(3, Icons.wallet_rounded, Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'tab_wallet')),
                  _buildNavItem(4, Icons.account_circle_rounded, Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'tab_profile')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCirc,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? SahaayakTheme.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? SahaayakTheme.primaryBlue : SahaayakTheme.textSecondary.withValues(alpha: 0.7),
              size: isSelected ? 26 : 24,
            ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: SahaayakTheme.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),
            ],
          ],
        ),
      ),
    );
  }
}

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Scaffold(
      backgroundColor: SahaayakTheme.surface,
       appBar: AppBar(
        title: Text(Translations.get(langCode, 'tab_library'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: SahaayakTheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.square_rounded, size: 64, color: SahaayakTheme.textSecondary.withValues(alpha: 0.2)),
             const SizedBox(height: 16),
             Text(Translations.get(langCode, 'no_saved_schemes'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
             const SizedBox(height: 8),
             Text(Translations.get(langCode, 'voice_recommendations'), 
              style: const TextStyle(color: SahaayakTheme.textSecondary, fontSize: 13)),
             const SizedBox(height: 24),
             ElevatedButton(
               onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checking for new schemes...'))),
               child: Text(Translations.get(langCode, 'refresh')),
             ),
          ],
        ),
      ),
    );
  }
}

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Scaffold(
      backgroundColor: SahaayakTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: SahaayakTheme.surface,
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(Translations.get(langCode, 'tab_wallet'), style: Theme.of(context).textTheme.headlineMedium),
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildSecurityHeader(langCode),
                   const SizedBox(height: 32),
                   _buildVaultCard(context, Translations.get(langCode, 'aadhaar_card'), Translations.get(langCode, 'identity_verified'), Icons.badge_rounded, Colors.blue),
                   _buildVaultCard(context, Translations.get(langCode, 'ration_card'), Translations.get(langCode, 'family_id'), Icons.list_alt_rounded, Colors.orange),
                   _buildVaultCard(context, Translations.get(langCode, 'voter_id'), Translations.get(langCode, 'election_ready'), Icons.how_to_reg_rounded, Colors.pink),
                   const SizedBox(height: 48),
                   _buildAddDocumentButton(context, langCode),
                   const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityHeader(String langCode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SahaayakTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_rounded, color: SahaayakTheme.primaryGreen, size: 16),
          const SizedBox(width: 8),
          Text(Translations.get(langCode, 'end_to_end_encrypted'), style: const TextStyle(color: SahaayakTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildVaultCard(BuildContext context, String name, String desc, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Viewing $name details...'))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: SahaayakTheme.appleCard(radius: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                 const SizedBox(height: 2),
                 Text(desc, style: const TextStyle(color: SahaayakTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: SahaayakTheme.offlineGrey),
        ],
      ),
      ),
    );
  }

  Widget _buildAddDocumentButton(BuildContext context, String langCode) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening document scanner...'))),
      child: Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle_rounded, color: SahaayakTheme.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(Translations.get(langCode, 'add_new_document'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: SahaayakTheme.primaryBlue)),
          ],
        ),
      ),
    ),
  );
}
}
