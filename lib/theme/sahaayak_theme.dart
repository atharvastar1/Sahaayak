import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SahaayakTheme {
  // --- ELITE MNC PALETTE (Apple & Google Standard) ---
  static const Color primary = Color(0xFF007AFF); // Apple Blue
  static const Color primaryDark = Color(0xFF1D1D1F); // Apple Midnight
  static const Color accentAI = Color(0xFF6366F1); // Indigo AI Signal
  static const Color success = Color(0xFF34C759); // Apple Green
  static const Color warning = Color(0xFFFF9500); // Apple Orange
  
  static const Color background = Color(0xFFF2F2F7); // Apple System Background
  static const Color surface = Colors.white;
  static const Color surfaceGlass = Color(0xB3FFFFFF); // 70% White Glass
  
  static const Color textBody = Color(0xFF1D1D1F);
  static const Color textSecondary = Color(0xFF86868B);
  static const Color textOnDark = Colors.white;

  // --- PREMIUM GRADIENTS ---
  static const LinearGradient appleGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF00C7BE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiAura = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- DESIGN TOKENS ---
  
  // Apple-style Glassmorphism
  static BoxDecoration glassmorphic({double radius = 24}) {
    return BoxDecoration(
      color: surfaceGlass,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Premium Card (Soft & Subtle)
  static BoxDecoration premiumCard({double radius = 28}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 40,
          offset: const Offset(0, 15),
        ),
      ],
    );
  }

  // Silicon Orb Shadow (Tactile 3D)
  static BoxDecoration siliconOrb({Color? glowColor}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: (glowColor ?? primary).withValues(alpha: 0.2),
          blurRadius: 50,
          spreadRadius: 5,
          offset: const Offset(0, 20),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static ThemeData get premiumTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accentAI,
        surface: surface,
        onSurface: textBody,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w800,
          fontSize: 48,
          color: textBody,
          letterSpacing: -2,
          height: 1.0,
        ),
        displayMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 34,
          color: textBody,
          letterSpacing: -1,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 26,
          color: textBody,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textBody,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
    );
  }

  // Legacy compatibility helpers (to prevent breaking current code)
  static const Color primaryBlue = primary;
  static const Color accentPurple = accentAI;
  static const Color accentSaffron = warning;
  static const Color emeraldActive = success;
  static const Color successGreen = success;
  static const Color accentTeal = Color(0xFF00C7BE);
  static const Color accentIndigo = Color(0xFF5856D6);
  static const Color vantaBlack = primaryDark;
  static const Color primaryDeep = primaryDark;
  static const Color textMain = textBody;
  static const Color textDim = textSecondary;
  static const LinearGradient techGradient = appleGradient;

  static BoxDecoration bentoCard({double radius = 32, Color? color}) => premiumCard(radius: radius).copyWith(color: color);
  static BoxDecoration glassPortal({double radius = 32}) => glassmorphic(radius: radius);
  static BoxDecoration glassDecoration({double radius = 32}) => glassmorphic(radius: radius);
  static BoxDecoration silverDecoration({double radius = 32}) => premiumCard(radius: radius);
  static BoxDecoration eliteElevation({double radius = 100}) => siliconOrb();

  // Category Badge Style
  static BoxDecoration categoryBadge({required Color color}) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
    );
  }
}


