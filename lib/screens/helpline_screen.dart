import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/sahaayak_theme.dart';
import '../services/haptic_service.dart';
import '../services/language_manager.dart';
import '../services/translations.dart';

class HelplineScreen extends StatelessWidget {
  const HelplineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    
    return Scaffold(
      backgroundColor: SahaayakTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: SahaayakTheme.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          Translations.get(langCode, 'bento_helpline'),
          style: const TextStyle(fontWeight: FontWeight.w800, color: SahaayakTheme.primaryDark),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildEmergencyGrid(langCode),
          const SizedBox(height: 48),
          const Text(
            'REGIONAL SUPPORT',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3, color: SahaayakTheme.textDim),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 24),
          _buildSupportContact('UP East Helpline', '1800-111-000', Icons.location_on_rounded),
          _buildSupportContact('Women Support', '181', Icons.woman_rounded),
          _buildSupportContact('Farmer Support', '1551', Icons.agriculture_rounded),
          const SizedBox(height: 40),
          _buildAiSupportBanner(langCode),
        ],
      ),
    );
  }

  Widget _buildEmergencyGrid(String lang) {
    final em = [
      {'label': 'Police', 'num': '100', 'icon': Icons.local_police_rounded, 'color': Colors.blue},
      {'label': 'Ambulance', 'num': '108', 'icon': Icons.medical_services_rounded, 'color': Colors.red},
    ];

    return Row(
      children: em.map((e) => Expanded(
        child: GestureDetector(
          onTap: () => HapticService.heavy(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(32),
            decoration: SahaayakTheme.premiumCard(radius: 40),
            child: Column(
              children: [
                Icon(e['icon'] as IconData, color: e['color'] as Color, size: 40),
                const SizedBox(height: 16),
                Text(e['label'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                Text(e['num'] as String, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28, color: SahaayakTheme.primary.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ),
      )).toList(),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSupportContact(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: SahaayakTheme.premiumCard(radius: 32),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: SahaayakTheme.primary.withValues(alpha: 0.05),
            child: Icon(icon, color: SahaayakTheme.primary, size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: SahaayakTheme.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => HapticService.medium(),
            icon: const Icon(Icons.call_rounded, color: SahaayakTheme.success),
            style: IconButton.styleFrom(backgroundColor: SahaayakTheme.success.withValues(alpha: 0.1)),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildAiSupportBanner(String lang) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: SahaayakTheme.bentoCard(radius: 40, color: SahaayakTheme.accentAI.withValues(alpha: 0.1)),
      child: const Column(
        children: [
          Icon(Icons.auto_awesome_rounded, color: SahaayakTheme.accentAI, size: 48),
          SizedBox(height: 16),
          Text('Voice SOS Mode', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          Text(
            'In emergency, shout "HELP HELP" to auto-alert locals.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: SahaayakTheme.textDim, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds);
  }
}
