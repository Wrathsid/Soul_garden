import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

/// Time periods with distinct visual themes
enum TimeOfDay {
  morning,    // 5am - 11am: Warm gold, sunrise
  afternoon,  // 11am - 5pm: Bright sky blue
  evening,    // 5pm - 9pm: Sunset coral/peach
  night,      // 9pm - 5am: Deep navy, fireflies
}

/// Visual theme configuration for each time of day
class TimeTheme {
  final LinearGradient backgroundGradient;
  final Color ambientGlow;
  final Color particleColor;
  final bool showFireflies;
  final Color cardOverlay;
  final String greeting;

  const TimeTheme({
    required this.backgroundGradient,
    required this.ambientGlow,
    required this.particleColor,
    required this.showFireflies,
    required this.cardOverlay,
    required this.greeting,
  });

  // Morning: Warm gold sunrise
  static TimeTheme get morning => TimeTheme(
    backgroundGradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF1A1A2E),  // Deep purple-navy at top
        Color(0xFF3D2C4D),  // Purple mid
        Color(0xFF7B4A5C),  // Warm rose
        Color(0xFFCF8F6F),  // Sunrise peach
      ],
      stops: [0.0, 0.3, 0.6, 1.0],
    ),
    ambientGlow: const Color(0xFFFFD700),  // Gold
    particleColor: const Color(0xFFFFE4B5).withValues(alpha: 0.6),  // Moccasin
    showFireflies: false,
    cardOverlay: const Color(0xFF3D2C4D).withValues(alpha: 0.3),
    greeting: 'Good morning',
  );

  // Afternoon: Bright sky energetic
  static TimeTheme get afternoon => TimeTheme(
    backgroundGradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF021024),  // Deep background
        Color(0xFF052659),  // Primary surface
        Color(0xFF0A3A7D),  // Bright mid
        Color(0xFF1E5AA8),  // Energetic blue
      ],
      stops: [0.0, 0.4, 0.7, 1.0],
    ),
    ambientGlow: const Color(0xFF87CEEB),  // Sky blue
    particleColor: const Color(0xFFC1E8FF).withValues(alpha: 0.5),  // Light blue
    showFireflies: false,
    cardOverlay: const Color(0xFF052659).withValues(alpha: 0.2),
    greeting: 'Good afternoon',
  );

  // Evening: Sunset coral warmth
  static TimeTheme get evening => TimeTheme(
    backgroundGradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF1A1A2E),  // Deep purple
        Color(0xFF4A2C4D),  // Warm purple
        Color(0xFF8B4B6C),  // Rose
        Color(0xFFE07864),  // Coral sunset
      ],
      stops: [0.0, 0.35, 0.65, 1.0],
    ),
    ambientGlow: const Color(0xFFFF7F50),  // Coral
    particleColor: const Color(0xFFFFB6C1).withValues(alpha: 0.5),  // Light pink
    showFireflies: false,
    cardOverlay: const Color(0xFF4A2C4D).withValues(alpha: 0.3),
    greeting: 'Good evening',
  );

  // Night: Deep navy with fireflies
  static TimeTheme get night => TimeTheme(
    backgroundGradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0A0A14),  // Nearly black
        Color(0xFF0D1525),  // Deep navy
        Color(0xFF0F1C30),  // Navy
        Color(0xFF021024),  // Deep background
      ],
      stops: [0.0, 0.3, 0.6, 1.0],
    ),
    ambientGlow: const Color(0xFF6B8CFF),  // Soft blue glow
    particleColor: const Color(0xFFFFE87C).withValues(alpha: 0.8),  // Firefly gold
    showFireflies: true,
    cardOverlay: const Color(0xFF0D1525).withValues(alpha: 0.4),
    greeting: 'Good night',
  );
}

/// Get current time of day
TimeOfDay getCurrentTimeOfDay() {
  final hour = DateTime.now().hour;
  
  if (hour >= 5 && hour < 11) {
    return TimeOfDay.morning;
  } else if (hour >= 11 && hour < 17) {
    return TimeOfDay.afternoon;
  } else if (hour >= 17 && hour < 21) {
    return TimeOfDay.evening;
  } else {
    return TimeOfDay.night;
  }
}

/// Get theme for time of day
TimeTheme getTimeTheme(TimeOfDay timeOfDay) {
  switch (timeOfDay) {
    case TimeOfDay.morning:
      return TimeTheme.morning;
    case TimeOfDay.afternoon:
      return TimeTheme.afternoon;
    case TimeOfDay.evening:
      return TimeTheme.evening;
    case TimeOfDay.night:
      return TimeTheme.night;
  }
}

/// Provider for current time-based theme (updates every minute)
final timeOfDayProvider = StateProvider<TimeOfDay>((ref) {
  return getCurrentTimeOfDay();
});

final timeThemeProvider = Provider<TimeTheme>((ref) {
  final timeOfDay = ref.watch(timeOfDayProvider);
  return getTimeTheme(timeOfDay);
});

/// Animated background widget that uses time-based gradients
class TimeBasedBackground extends StatelessWidget {
  final Widget child;
  final bool useTimeTheme;

  const TimeBasedBackground({
    super.key,
    required this.child,
    this.useTimeTheme = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!useTimeTheme) {
      return Container(
        decoration: const BoxDecoration(
          color: AppTheme.deepBackground,
        ),
        child: child,
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final timeTheme = ref.watch(timeThemeProvider);
        
        return AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: timeTheme.backgroundGradient,
          ),
          child: child,
        );
      },
    );
  }
}
