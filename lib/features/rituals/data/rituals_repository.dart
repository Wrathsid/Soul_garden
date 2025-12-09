import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../services/supabase_client.dart';
import '../../streak/data/streak_repository.dart';
import '../../xp/data/xp_repository.dart';
import 'ritual_completion_model.dart';

final ritualsRepositoryProvider = Provider((ref) => RitualsRepository(ref));

class RitualsRepository {
  final Ref _ref;
  
  RitualsRepository(this._ref);

  Future<List<RitualCompletion>> fetchRitualCompletions({int? limit}) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return [];

      var query = SupabaseService.client
          .from(AppConstants.tableRitualsCompleted)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final data = await query;
      return (data as List).map((e) => RitualCompletion.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Counts rituals completed this week
  Future<int> countThisWeeksRituals() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return 0;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartNormalized = DateTime(weekStart.year, weekStart.month, weekStart.day);

    try {
      final data = await SupabaseService.client
          .from(AppConstants.tableRitualsCompleted)
          .select()
          .eq('user_id', userId)
          .gte('created_at', weekStartNormalized.toIso8601String());
      return (data as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> hasStreakFreeze() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return false;

    final response = await SupabaseService.client
        .from(AppConstants.tableUserInventory)
        .select('id')
        .eq('user_id', userId)
        .eq('item_name', 'Streak Freeze')
        .eq('is_consumed', false);

    return (response as List).isNotEmpty;
  }

  Future<void> useStreakFreeze() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    final item = await SupabaseService.client
        .from(AppConstants.tableUserInventory)
        .select('id')
        .eq('user_id', userId)
        .eq('item_name', 'Streak Freeze')
        .eq('is_consumed', false)
        .limit(1)
        .maybeSingle();

    if (item != null) {
      // Mark as consumed instead of deleting
      await SupabaseService.client
          .from(AppConstants.tableUserInventory)
          .update({'is_consumed': true})
          .eq('id', item['id']);

      // Log freeze-protected entry for yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await SupabaseService.client.from(AppConstants.tableRitualsCompleted).insert({
        'user_id': userId,
        'ritual_type': 'freeze_protected',
        'created_at': yesterday.toIso8601String(),
      });

      // Refresh streak
      _ref.invalidate(streakProvider);
    }
  }

  /// Logs a ritual completion and triggers XP/streak updates
  Future<void> logCompletion(String ritualType) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    await SupabaseService.client.from(AppConstants.tableRitualsCompleted).insert({
      'user_id': userId,
      'ritual_type': ritualType,
    });

    // Invalidate providers to refresh XP and streak
    _ref.invalidate(xpProvider);
    _ref.invalidate(streakProvider);
  }

  /// Gets ritual counts by type for the current week
  Future<Map<String, int>> getWeeklyRitualCounts() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return {};

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartNormalized = DateTime(weekStart.year, weekStart.month, weekStart.day);

    try {
      final data = await SupabaseService.client
          .from(AppConstants.tableRitualsCompleted)
          .select('ritual_type')
          .eq('user_id', userId)
          .gte('created_at', weekStartNormalized.toIso8601String());

      final counts = <String, int>{};
      for (final item in (data as List)) {
        final type = item['ritual_type'] as String? ?? 'unknown';
        counts[type] = (counts[type] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      return {};
    }
  }
}
