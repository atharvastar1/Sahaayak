import 'package:flutter/material.dart';
import '../theme/sahaayak_theme.dart';
import '../services/language_manager.dart';
import '../services/translations.dart';
import '../services/haptic_service.dart';
import '../services/ai_coordinator.dart';
import 'language_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    return Scaffold(
      backgroundColor: SahaayakTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            backgroundColor: SahaayakTheme.primaryDeep,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: SahaayakTheme.techGradient),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text('🇮🇳', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Translations.get(langCode, 'resident_of_bharat'), 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)
                      ),
                      Text(
                        Translations.get(langCode, 'uidai_verified').toUpperCase(), 
                        style: const TextStyle(color: SahaayakTheme.accentTeal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                      ),
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
                _buildMncSectionHeader(Translations.get(langCode, 'personal_details')),
                _buildMncSettingsItem(
                  context, 
                  Icons.language_rounded, 
                  Translations.get(langCode, 'interface_language'), 
                  Translations.get(langCode, 'hindi_english'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageSetupScreen())),
                ),
                _buildMncSettingsItem(
                  context, 
                  Icons.location_on_rounded, 
                  Translations.get(langCode, 'region'), 
                  Translations.get(langCode, 'uttar_pradesh'),
                  onTap: () => _showStubInfo(context, 'Region Selection'),
                ),
                const SizedBox(height: 32),
                _buildMncSectionHeader(Translations.get(langCode, 'accessibility')),
                _buildMncSettingsItem(
                  context, 
                  Icons.record_voice_over_rounded, 
                  Translations.get(langCode, 'voice_speed'), 
                  Translations.get(langCode, 'natural_1x'),
                  onTap: () => _showStubInfo(context, 'Voice Speed Settings'),
                ),
                _buildMncSettingsItem(
                  context, 
                  Icons.visibility_rounded, 
                  Translations.get(langCode, 'high_contrast_mode'), 
                  Translations.get(langCode, 'on'),
                  onTap: () => _showStubInfo(context, 'Accessibility Options'),
                ),
                const SizedBox(height: 32),
                _buildMncSectionHeader(Translations.get(langCode, 'app_info')),
                _buildMncSettingsItem(
                  context, 
                  Icons.security_rounded, 
                  Translations.get(langCode, 'privacy_policy'), 
                  Translations.get(langCode, 'standard_government_terms'),
                  onTap: () => _showStubInfo(context, 'Privacy Policy'),
                ),
                _buildMncSettingsItem(
                  context, 
                  Icons.info_outline_rounded, 
                  Translations.get(langCode, 'sahaayak_v1'), 
                  Translations.get(langCode, 'up_to_date'),
                  onTap: () => _showStubInfo(context, 'App Version Info'),
                ),
                const SizedBox(height: 32),
                _buildMncSectionHeader("Engineering / Simulation"),
                _buildOfflineModeToggle(context),
                const SizedBox(height: 48),
                _buildMncLogoutButton(context),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMncSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Text(
        title.toUpperCase(), 
        style: TextStyle(fontWeight: FontWeight.w900, color: SahaayakTheme.primaryDeep.withValues(alpha: 0.4), letterSpacing: 2, fontSize: 10)
      ),
    );
  }

  Widget _buildMncSettingsItem(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: SahaayakTheme.premiumCard(radius: 20),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: SahaayakTheme.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: SahaayakTheme.primary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: SahaayakTheme.primaryDark)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: SahaayakTheme.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: SahaayakTheme.primaryDark, size: 14),
        onTap: () {
          HapticService.light();
          if (onTap != null) onTap();
        },
      ),
    );
  }

  Widget _buildMncLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        HapticService.heavy();
        _showStubInfo(context, 'Logging Out...');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
        foregroundColor: Colors.redAccent,
        elevation: 0,
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.redAccent, width: 0.5)),
      ),
      child: const Text('SIGN OUT OF SAHAAYAK', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 14)),
    );
  }

  void _showStubInfo(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: SahaayakTheme.primaryDeep,
      ),
    );
  }

  Widget _buildOfflineModeToggle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: SahaayakTheme.premiumCard(radius: 20),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: SahaayakTheme.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.offline_bolt_rounded, color: SahaayakTheme.warning, size: 22),
        ),
        title: const Text('Offline Mode (Local Agent)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: SahaayakTheme.primaryDark)),
        subtitle: const Text('Bypass cloud servers. Force local inference.', style: TextStyle(fontSize: 13, color: SahaayakTheme.textSecondary)),
        value: AICoordinator.isFrontendOnly,
        activeThumbColor: SahaayakTheme.warning,
        onChanged: (val) {
          HapticService.medium();
          setState(() {
            AICoordinator.isFrontendOnly = val;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(val ? 'Local Processing Active (Offline)' : 'Cloud Intelligence Active (Online)'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: val ? SahaayakTheme.warning : SahaayakTheme.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        },
      ),
    );
  }
}
