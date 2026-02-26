import '../services/language_manager.dart';
import '../services/translations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../theme/sahaayak_theme.dart';
import 'guided_coach_screen.dart';
import '../services/voice_service.dart';
class DashboardScreen extends StatelessWidget {
  final VoidCallback onProfileTap;
  const DashboardScreen({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayakTheme.background, // iOS 26 light space
      body: Stack(
        children: [
          // Background abstract gradients for that iOS glass morphing feel
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SahaayakTheme.primaryBlue.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SahaayakTheme.primaryGreen.withValues(alpha: 0.1),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
          _buildCupertinoAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildIntelligenceHeader(context),
                   const SizedBox(height: 24),
                   _buildPrimaryDashboardCard(context),
                   const SizedBox(height: 32),
                   _buildSectionTitle(Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'sahaayak_intelligence') ?? 'Sahaayak Intelligence'),
                   const SizedBox(height: 16),
                   _buildIntelligenceGrid(context),
                   const SizedBox(height: 32),
                   _buildSectionTitle(Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'on_device_privacy') ?? 'On-Device Privacy'),
                   const SizedBox(height: 16),
                   _buildPrivacyCard(context),
                   const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
        ],
      ),
    );
  }

  Widget _buildCupertinoAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent, // Letting background bleed through
      elevation: 0,
      pinned: true,
      actions: [
        IconButton(
          onPressed: () => VoiceService.speak('Welcome to your Today view. Here you can see your scheme matches and digital wallet.', 'en'),
          icon: const Icon(Icons.volume_up_rounded, color: SahaayakTheme.primaryBlue),
        ),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12, width: 0.5),
            ),
            child: const Icon(Icons.person_outline_rounded, size: 18, color: SahaayakTheme.textMain),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          'For Bharat',
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildIntelligenceHeader(BuildContext context) {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('WEDNESDAY, 25 FEB', style: TextStyle(color: SahaayakTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(Translations.get(langCode, 'greeting'), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24)),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryDashboardCard(BuildContext context) {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: SahaayakTheme.glassDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: SahaayakTheme.primaryBlue, size: 22),
                  const SizedBox(width: 8),
                  Text(Translations.get(langCode, 'active_recommendation'), style: const TextStyle(color: SahaayakTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                ],
              ),
              const SizedBox(height: 16),
              Text(Translations.get(langCode, 'ration_update'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20, height: 1.25)),
              const SizedBox(height: 20),
              Text(Translations.get(langCode, 'ration_desc'), style: const TextStyle(color: SahaayakTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GuidedCoachScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SahaayakTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(Translations.get(langCode, 'review_apply'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.98, 0.98));
  }


  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: SahaayakTheme.textMain));
  }

  Widget _buildIntelligenceGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildIntelliCard(context, Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'smart_vault'), Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'verified'), Icons.verified_user_rounded, Colors.indigo),
        _buildIntelliCard(context, Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'voice_insights'), Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'region_detected'), Icons.graphic_eq_rounded, Colors.pink),
        _buildIntelliCard(context, Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'scheme_match'), Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'available'), Icons.auto_awesome_rounded, Colors.orange),
        _buildIntelliCard(context, Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'local_support'), Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'up_east'), Icons.location_on_rounded, Colors.teal),
      ],
    );
  }

  Widget _buildIntelliCard(BuildContext context, String title, String status, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title tapped'))),
      child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: SahaayakTheme.glassDecoration(radius: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(status, style: const TextStyle(color: SahaayakTheme.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ),
    ),
  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
}

  Widget _buildPrivacyCard(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Privacy settings opened'))),
      child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.security_rounded, color: SahaayakTheme.primaryGreen, size: 40),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'privacy_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(Translations.get(LanguageManager.of(context)?.currentLanguage ?? 'en', 'privacy_desc'), 
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
