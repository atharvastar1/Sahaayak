import 'package:flutter/material.dart';
import '../theme/sahaayak_theme.dart';
import '../services/language_manager.dart';
import '../services/translations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: SahaayakTheme.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: SahaayakTheme.appleGradient),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Center(child: Text('🇮🇳', style: TextStyle(fontSize: 40))),
                      ),
                      const SizedBox(height: 12),
                      Text(Translations.get(langCode, 'resident_of_bharat'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                      Text(Translations.get(langCode, 'uidai_verified'), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionHeader(Translations.get(langCode, 'personal_details')),
                _buildItem(context, Icons.language_rounded, Translations.get(langCode, 'interface_language'), Translations.get(langCode, 'hindi_english')),
                _buildItem(context, Icons.location_on_rounded, Translations.get(langCode, 'region'), Translations.get(langCode, 'uttar_pradesh')),
                const SizedBox(height: 32),
                _buildSectionHeader(Translations.get(langCode, 'accessibility')),
                _buildItem(context, Icons.record_voice_over_rounded, Translations.get(langCode, 'voice_speed'), Translations.get(langCode, 'natural_1x')),
                _buildItem(context, Icons.visibility_rounded, Translations.get(langCode, 'high_contrast_mode'), Translations.get(langCode, 'on')),
                const SizedBox(height: 32),
                _buildSectionHeader(Translations.get(langCode, 'app_info')),
                _buildItem(context, Icons.security_rounded, Translations.get(langCode, 'privacy_policy'), Translations.get(langCode, 'standard_government_terms')),
                _buildItem(context, Icons.info_outline_rounded, Translations.get(langCode, 'sahaayak_v1'), Translations.get(langCode, 'up_to_date')),
                const SizedBox(height: 48),
                Center(
                  child: Image.asset('assets/logo.png', height: 40, opacity: const AlwaysStoppedAnimation(0.2)),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: SahaayakTheme.textSecondary.withValues(alpha: 0.4), letterSpacing: 2, fontSize: 11)),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: SahaayakTheme.glassDecoration(radius: 20),
      child: ListTile(
        leading: Icon(icon, color: SahaayakTheme.primaryBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right_rounded, color: SahaayakTheme.offlineGrey, size: 20),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening $title...')));
        },
      ),
    );
  }
}
