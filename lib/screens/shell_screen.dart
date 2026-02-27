import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/language_manager.dart';
import '../services/translations.dart';
import '../services/voice_service.dart';
import '../theme/sahaayak_theme.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const DashboardScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final langCode = LanguageManager.of(context)?.currentLanguage ?? 'en';
    
    return Scaffold(
      backgroundColor: SahaayakTheme.background,
      extendBody: true, // Allows content to show behind the floating dock
      body: Stack(
        children: [
          _pages[_selectedIndex],
          _buildFloatingInteractiveAid(langCode),
        ],
      ),
      bottomNavigationBar: _buildEliteDock(langCode),
    );
  }

  Widget _buildFloatingInteractiveAid(String langCode) {
    if (_selectedIndex == 0) return const SizedBox.shrink();
    
    return Positioned(
      bottom: 140,
      right: 32,
      child: GestureDetector(
        onTap: () {
          VoiceService.speak(Translations.get(langCode, 'voice_help_prompt'), langCode);
        },
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: SahaayakTheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: SahaayakTheme.primary.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 40),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
       .scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
       .shimmer(duration: 3.seconds),
    );
  }

  Widget _buildEliteDock(String langCode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 0, 28, 48),
      height: 80,
      clipBehavior: Clip.antiAlias,
      decoration: SahaayakTheme.glassmorphic(radius: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: Colors.white.withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDockItem(0, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, Translations.get(langCode, 'tab_ask')),
                _buildDockItem(1, Icons.grid_view_rounded, Icons.grid_view_rounded, Translations.get(langCode, 'tab_discover')),
                _buildDockItem(2, Icons.person_outline_rounded, Icons.person_rounded, Translations.get(langCode, 'tab_you')),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, duration: 1000.ms, curve: Curves.easeOutQuart);
  }

  Widget _buildDockItem(int index, IconData icon, IconData activeIcon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: 400.ms,
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? SahaayakTheme.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : SahaayakTheme.textSecondary,
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.w800, 
                  fontSize: 14, 
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn().slideX(begin: -0.2),
            ],
          ],
        ),
      ),
    );
  }
}

