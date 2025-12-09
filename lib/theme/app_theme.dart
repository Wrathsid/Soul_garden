import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SoulGarden App Theme - Dark Blue Palette
class AppTheme {
  // Dark Blue Color Palette
  static const Color deepBackground = Color(0xFF021024);   // Night background
  static const Color primarySurface = Color(0xFF052659);   // Cards, surfaces
  static const Color secondaryAccent = Color(0xFF5483B3);  // Buttons, icons
  static const Color softHighlight = Color(0xFF7DA0CA);    // Secondary
  static const Color lightAccent = Color(0xFFC1E8FF);      // Chips, callouts
  
  // Legacy aliases for backward compatibility
  static const Color primaryBlue = secondaryAccent;
  static const Color accentTeal = softHighlight;
  static const Color secondaryTeal = softHighlight;
  static const Color backgroundTop = deepBackground;
  static const Color backgroundBottom = primarySurface;
  static const Color cardBackground = primarySurface;
  static const Color cardShadow = Color(0x4D000000);
  
  // Text colors for dark theme
  static const Color textPrimary = Color(0xFFF9FAFB);      // Near-white
  static const Color textSecondary = Color(0xFFCBD5F5);    // Light gray-blue
  static const Color textOnPrimary = Colors.white;
  
  // Achievement Colors
  static const Color achievementGold = Color(0xFFFFD700);
  static const Color achievementLocked = Color(0xFF475569);
  
  // Streak Colors
  static const Color streakRed = Color(0xFFEF4444);
  
  // Accent colors
  static const Color accentGreen = Color(0xFF10B981);      // Success/XP
  static const Color accentWarning = Color(0xFFFBBF24);
  static const Color accentError = Color(0xFFEF4444);

  /// Dark Theme Data
  static ThemeData get lightTheme => darkTheme;
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: secondaryAccent,
      scaffoldBackgroundColor: deepBackground,
      colorScheme: ColorScheme.dark(
        primary: secondaryAccent,
        secondary: softHighlight,
        surface: primarySurface,
        onPrimary: textOnPrimary,
        onSurface: textPrimary,
      ),
      textTheme: _textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryAccent,
          foregroundColor: textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: softHighlight,
          side: const BorderSide(color: softHighlight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: primarySurface,
        elevation: 4,
        shadowColor: const Color(0x4D000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: deepBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textOnPrimary,
      ),
    );
  }

  /// Gradient Background Decoration
  static BoxDecoration get backgroundGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [deepBackground, primarySurface],
      ),
    );
  }
}

