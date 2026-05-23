import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SahaayakTheme {
  // --- SOFT PREMIUM INDIAN ACCESSIBILITY PALETTE ---
  static const Color primary = Color(0xFF00677D); // Teal
  static const Color primaryContainer = Color(0xFF00B4D8);
  static const Color onPrimaryContainer = Color(0xFF00414F);
  static const Color primaryDark = Color(0xFF00414F); 

  static const Color accentAI = Color(0xFF5B3CDD); // Indigo / Purple
  static const Color accentContainer = Color(0xFF7459F7);

  static const Color success = Color(0xFF19BC84); // Green
  static const Color warning = Color(0xFFF5A623); // Orange
  static const Color error = Color(0xFFBA1A1A); // Red

  static const Color background = Color(0xFFFAF8FF); // Soft Warm White
  static const Color surface = Colors.white;
  static const Color surfaceGlass = Color(0xCCFFFFFF); // 80% White Glass

  static const Color textBody = Color(0xFF0C1A3B); // Dark Navy
  static const Color textSecondary = Color(0xFF3D494D);
  static const Color textOnDark = Colors.white;

  // --- PREMIUM GRADIENTS ---
  static const LinearGradient appleGradient = LinearGradient(
    colors: [Color(0xFF00677D), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiAura = LinearGradient(
    colors: [Color(0xFF5B3CDD), Color(0xFF7459F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- DESIGN TOKENS ---
  
  // Soft Glassmorphism (Level 1 Elevation)
  static BoxDecoration glassmorphic({double radius = 20}) {
    return BoxDecoration(
      color: surfaceGlass,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0B193A).withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Premium Card (Soft Elevation - Level 2)
  static BoxDecoration premiumCard({double radius = 20}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0B193A).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Ultra-Premium Depth
  static List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: const Color(0xFF0B193A).withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x0AFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Silicon Orb Shadow (Voice Pulse)
  static BoxDecoration siliconOrb({Color? glowColor}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: (glowColor ?? accentContainer).withValues(alpha: 0.4),
          blurRadius: 32,
          spreadRadius: 8,
          offset: const Offset(0, 8),
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
        error: error,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w800,
          fontSize: 40, // Scaled down slightly for outfit
          color: textBody,
          letterSpacing: -0.02,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 36,
          color: textBody,
          letterSpacing: -0.02,
          height: 1.2,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: textBody,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: textBody,
          height: 1.6,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.02,
          color: textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryContainer,
          foregroundColor: onPrimaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          minimumSize: const Size(120, 48), // 48px height pill
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), // Pill
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.01),
          shadowColor: const Color(0xFF00677D).withValues(alpha: 0.2),
        ),
      ),
    );
  }

  // Legacy compatibility helpers
  static const Color primaryBlue = primary;
  static const Color accentPurple = accentAI;
  static const Color accentSaffron = warning;
  static const Color emeraldActive = success;
  static const Color successGreen = success;
  static const Color accentTeal = primaryContainer;
  static const Color accentIndigo = accentAI;
  static const Color vantaBlack = primaryDark;
  static const Color primaryDeep = primaryDark;
  static const Color textMain = textBody;
  static const Color textDim = textSecondary;
  static const LinearGradient techGradient = appleGradient;

  static BoxDecoration bentoCard({double radius = 24, Color? color}) => premiumCard(radius: radius).copyWith(color: color);
  static BoxDecoration glassPortal({double radius = 20}) => glassmorphic(radius: radius);
  static BoxDecoration glassDecoration({double radius = 20}) => glassmorphic(radius: radius);
  static BoxDecoration silverDecoration({double radius = 20}) => premiumCard(radius: radius);
  static BoxDecoration eliteElevation({double radius = 100}) => siliconOrb();

  // Category Badge Style
  static BoxDecoration categoryBadge({required Color color}) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(100), // Pill
      border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
    );
  }
}


