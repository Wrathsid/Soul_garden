import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../services/supabase_client.dart';

final streakRepositoryProvider = Provider((ref) => StreakRepository());

/// Model representing the user's streak data
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final bool completedToday;
  final bool hasFreezeAvailable;
  final DateTime? lastActivityDate;

  const StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completedToday = false,
    this.hasFreezeAvailable = false,
    this.lastActivityDate,
  });

  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    bool? completedToday,
    bool? hasFreezeAvailable,
    DateTime? lastActivityDate,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completedToday: completedToday ?? this.completedToday,
      hasFreezeAvailable: hasFreezeAvailable ?? this.hasFreezeAvailable,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }
}

/// Repository for streak calculations and management
class StreakRepository {
  /// Calculates the user's current streak from activity data
  Future<StreakData> calculateStreak() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      return const StreakData();
    }

    try {
      // Get all ritual completions and mood entries ordered by date
      final rituals = await SupabaseService.client
          .from(AppConstants.tableRitualsCompleted)
          .select('created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final moods = await SupabaseService.client
          .from(AppConstants.tableMoodEntries)
          .select('created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Combine and get unique dates
      final allDates = <DateTime>{};
      
      for (final r in (rituals as List)) {
        final date = DateTime.tryParse(r['created_at']?.toString() ?? '');
        if (date != null) {
          allDates.add(DateTime(date.year, date.month, date.day));
        }
      }
      
      for (final m in (moods as List)) {
        final date = DateTime.tryParse(m['created_at']?.toString() ?? '');
        if (date != null) {
          allDates.add(DateTime(date.year, date.month, date.day));
        }
      }

      if (allDates.isEmpty) {
        return const StreakData();
      }

      // Sort dates descending
      final sortedDates = allDates.toList()..sort((a, b) => b.compareTo(a));
      
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);
      final yesterday = todayNormalized.subtract(const Duration(days: 1));

      // Check if user has activity today
      final completedToday = sortedDates.contains(todayNormalized);

      // Calculate current streak
      int currentStreak = 0;
      DateTime checkDate = completedToday ? todayNormalized : yesterday;

      for (int i = 0; i < sortedDates.length; i++) {
        if (sortedDates.contains(checkDate)) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      // If no activity today or yesterday, streak is broken
      if (!completedToday && !sortedDates.contains(yesterday)) {
        currentStreak = 0;
      }

      // Check for streak freeze
      final freezeCheck = await SupabaseService.client
          .from(AppConstants.tableUserInventory)
          .select('id')
          .eq('user_id', userId)
          .eq('item_name', 'Streak Freeze')
          .eq('is_consumed', false);

      final hasFreezeAvailable = (freezeCheck as List).isNotEmpty;

      return StreakData(
        currentStreak: currentStreak,
        longestStreak: currentStreak, // TODO: Track in profiles table
        completedToday: completedToday,
        hasFreezeAvailable: hasFreezeAvailable,
        lastActivityDate: sortedDates.isNotEmpty ? sortedDates.first : null,
      );
    } catch (e) {
      return const StreakData();
    }
  }

  /// Awards streak bonus XP at milestones (7, 14, 30 days)
  Future<int> checkAndAwardStreakBonus(int currentStreak) async {
    if (currentStreak == 7) return 50;
    if (currentStreak == 14) return 100;
    if (currentStreak == 30) return 250;
    if (currentStreak == 60) return 500;
    if (currentStreak == 100) return 1000;
    return 0;
  }
}

/// Provider that exposes streak data reactively
final streakProvider = FutureProvider<StreakData>((ref) async {
  final repo = ref.watch(streakRepositoryProvider);
  return repo.calculateStreak();
});
