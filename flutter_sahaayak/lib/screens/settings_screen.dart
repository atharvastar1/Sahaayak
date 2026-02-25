import 'package:flutter/material.dart';
import '../theme/sahaayak_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          _buildItem(context, Icons.language_rounded, 'Language', 'English'),
          _buildItem(context, Icons.speed_rounded, 'Voice Speed', 'Normal'),
          _buildItem(context, Icons.notifications_none_rounded, 'Notifications', 'On'),
          _buildItem(context, Icons.info_outline_rounded, 'About Sahaayak', 'v1.0.0'),
          const SizedBox(height: 64),
          Center(
            child: Column(
              children: [
                Image.asset('assets/logo.png', height: 40),
                const SizedBox(height: 16),
                const Text(
                  'Built for Bharat with ❤️',
                  style: TextStyle(fontWeight: FontWeight.w900, color: SahaayakTheme.primaryBlue, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: SahaayakTheme.accentPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        onTap: () {},
      ),
    );
  }
}
