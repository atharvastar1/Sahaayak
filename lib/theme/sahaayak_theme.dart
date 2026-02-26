import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SahaayakTheme {
  // CUPERTINO PREMIUM PALETTE
  static const Color primaryBlue = Color(0xFF007AFF); // Apple Blue
  static const Color primaryGreen = Color(0xFF34C759); // Apple Green
  static const Color textMain = Color(0xFF1C1C1E); // Apple Dark Grey
  static const Color textSecondary = Color(0xFF8E8E93); // Apple Label Grey
  static const Color surface = Color(0xFFF2F2F7); // Apple System Grey
  static const Color glassBase = Color(0xB3FFFFFF); // iOS 26 heavily blurred glass
  static const Color background = Colors.white;
  static const Color offlineGrey = Color(0xFFAEB2B8);

  static const LinearGradient appleGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static BoxDecoration appleCard({double radius = 28}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white, width: 2), // iOS 26 frosted glass border
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 40,
          offset: const Offset(0, 15),
        ),
      ],
    );
  }

  static BoxDecoration glassDecoration({double radius = 24}) {
    return BoxDecoration(
      color: glassBase,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 50,
          offset: const Offset(0, 20),
        ),
      ],
    );
  }

  static ThemeData get premiumTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: primaryGreen,
        surface: background,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 34,
          color: textMain,
          letterSpacing: -1.0,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 28,
          color: textMain,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: textMain,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: textMain,
          height: 1.4,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 15,
          color: textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}
