import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SahaayakTheme {
  // WHITE PREMIUM PALETTE
  static const Color primaryBlue = Color(0xFF0F172A); // Deep Slate for trust
  static const Color accentPurple = Color(0xFF6366F1); // AI Indigo
  static const Color schemeGreen = Color(0xFF059669); // Trustworthy Green
  static const Color background = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color surface = Color(0xFFF8FAFC);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  
  static final LinearGradient aiGradient = const LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get premiumTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentPurple,
        primary: primaryBlue,
        secondary: accentPurple,
        tertiary: schemeGreen,
        background: background,
        surface: background,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w900,
          fontSize: 38,
          color: textMain,
          letterSpacing: -1.5,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w800,
          fontSize: 30,
          color: textMain,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: textMain,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textMain,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 16,
          color: textSecondary,
          height: 1.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        color: cardBg,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: accentPurple.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
