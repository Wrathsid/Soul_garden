import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Calm mode options for user preference
enum CalmMode {
  light,  // Soft pastels, glass surfaces, airy feel
  deep,   // Current deep navy (default) - immersive, focused
}

/// Provider for calm mode preference
final calmModeProvider = StateNotifierProvider<CalmModeNotifier, CalmMode>((ref) {
  return CalmModeNotifier();
});

class CalmModeNotifier extends StateNotifier<CalmMode> {
  CalmModeNotifier() : super(CalmMode.deep) {
    _loadPreference();
  }

  static const _prefsKey = 'calm_mode';

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_prefsKey);
      if (value == 'light') {
        state = CalmMode.light;
      }
    } catch (_) {
      // Default to deep mode on error
    }
  }

  Future<void> setMode(CalmMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode == CalmMode.light ? 'light' : 'deep');
    } catch (_) {
      // Ignore persistence errors
    }
  }

  void toggle() {
    setMode(state == CalmMode.light ? CalmMode.deep : CalmMode.light);
  }
}

/// Extended theme configuration with light calm mode
class CalmTheme {
  // Light Calm Mode Colors - Soft, airy, pastel
  static const Color lightBackground = Color(0xFFF0F4F8);     // Soft gray-blue
  static const Color lightSurface = Color(0xFFFFFFFF);        // Pure white cards
  static const Color lightPrimary = Color(0xFF5B8DEF);        // Soft blue
  static const Color lightSecondary = Color(0xFF8BA4CC);      // Muted blue
  static const Color lightAccent = Color(0xFFB8D4E8);         // Very soft blue
  static const Color lightText = Color(0xFF2D3748);           // Dark gray
  static const Color lightTextSecondary = Color(0xFF718096);  // Medium gray
  static const Color lightGlass = Color(0x80FFFFFF);          // White glass

  /// Get ThemeData based on calm mode
  static ThemeData getTheme(CalmMode mode) {
    return mode == CalmMode.light ? lightCalmTheme : AppTheme.darkTheme;
  }

  /// Light Calm Theme - Pastel, airy, glass-like
  static ThemeData get lightCalmTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: lightPrimary,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
        onSurface: lightText,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      textTheme: AppTheme.darkTheme.textTheme.apply(
        bodyColor: lightText,
        displayColor: lightText,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shadowColor: const Color(0x1A000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppTheme.darkTheme.appBarTheme.copyWith(
        backgroundColor: lightBackground,
        foregroundColor: lightText,
        iconTheme: const IconThemeData(color: lightText),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: lightPrimary,
        unselectedItemColor: lightSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        hintStyle: TextStyle(color: lightTextSecondary.withAlpha(153)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightSecondary.withAlpha(77)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightSecondary.withAlpha(77)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}

/// Widget to toggle between calm modes
class CalmModeToggle extends ConsumerWidget {
  const CalmModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calmMode = ref.watch(calmModeProvider);
    final isDark = calmMode == CalmMode.deep;

    return GestureDetector(
      onTap: () => ref.read(calmModeProvider.notifier).toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark 
            ? AppTheme.primarySurface.withValues(alpha: 0.5)
            : CalmTheme.lightSecondary.withValues(alpha: 0.2),
          border: Border.all(
            color: isDark ? AppTheme.softHighlight : CalmTheme.lightPrimary,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 18,
              color: isDark ? AppTheme.lightAccent : CalmTheme.lightPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              isDark ? 'Deep Calm' : 'Light Calm',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.textPrimary : CalmTheme.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
