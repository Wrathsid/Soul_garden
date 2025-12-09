import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Blue Color Palette
  static const Color deepBackground = Color(0xFF021024);   // Night background
  static const Color primarySurface = Color(0xFF052659);   // Cards, surfaces
  static const Color secondaryAccent = Color(0xFF5483B3);  // Buttons, icons
  static const Color softHighlight = Color(0xFF7DA0CA);    // Secondary
  static const Color lightAccent = Color(0xFFC1E8FF);      // Chips, callouts
  
  // Text colors for dark theme
  static const Color textPrimary = Color(0xFFF9FAFB);      // Near-white
  static const Color textSecondary = Color(0xFFCBD5F5);    // Light gray-blue
  
  // Accent colors
  static const Color accentGreen = Color(0xFF10B981);      // Success/XP
  static const Color accentWarning = Color(0xFFFBBF24);
  static const Color accentError = Color(0xFFEF4444);
  
  // Warm accent colors for emotional elements
  static const Color warmGold = Color(0xFFFFC857);         // XP star, streak flame
  static const Color warmPeach = Color(0xFFFFD6A5);        // Soft warm highlights
  static const Color warmSunrise = Color(0xFFFFB347);      // Sun glow
  static const Color warmSuccess = Color(0xFFFFE4B5);      // Success glow (moccasin)
  
  // Legacy aliases for backward compatibility
  static const Color primaryBlue = secondaryAccent;
  static const Color secondaryTeal = softHighlight;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: secondaryAccent,
      scaffoldBackgroundColor: deepBackground,
      colorScheme: const ColorScheme.dark(
        primary: secondaryAccent,
        secondary: softHighlight,
        surface: primarySurface,
        onSurface: textPrimary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
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
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
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
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primarySurface,
        selectedItemColor: lightAccent,
        unselectedItemColor: softHighlight,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: softHighlight,
          side: const BorderSide(color: softHighlight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primarySurface,
        hintStyle: TextStyle(color: textSecondary.withAlpha(153)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: softHighlight.withAlpha(77)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: softHighlight.withAlpha(77)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryAccent, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primarySurface,
        labelStyle: GoogleFonts.inter(color: lightAccent),
        side: BorderSide(color: softHighlight.withAlpha(77)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: primarySurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: primarySurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primarySurface,
        contentTextStyle: GoogleFonts.inter(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Keep lightTheme as fallback (not used but good to have)
  static ThemeData get lightTheme => darkTheme;
}

