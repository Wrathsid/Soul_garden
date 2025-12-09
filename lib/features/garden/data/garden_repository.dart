import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../services/supabase_client.dart';
import '../../xp/data/xp_repository.dart';
import 'mood_entry_model.dart';

final gardenRepositoryProvider = Provider((ref) => GardenRepository(ref));

class GardenRepository {
  final Ref _ref;
  
  GardenRepository(this._ref);

  Future<List<MoodEntry>> fetchMoodEntries({int? limit}) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return [];

      var query = SupabaseService.client
          .from(AppConstants.tableMoodEntries)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      if (limit != null) {
        query = query.limit(limit);
      }

      final data = await query;
      return (data as List).map((e) => MoodEntry.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Counts total mood entries for the user
  Future<int> countMoodEntries() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return 0;

    try {
      final data = await SupabaseService.client
          .from(AppConstants.tableMoodEntries)
          .select()
          .eq('user_id', userId);
      return (data as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Adds a mood entry and awards XP
  Future<void> addMoodEntry(MoodEntry entry) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    // Insert mood entry
    await SupabaseService.client.from(AppConstants.tableMoodEntries).insert({
      ...entry.toJson(),
      'user_id': userId,
    });

    // Award XP for mood check-in
    // XP is now calculated dynamically from activity counts, 
    // so this call is optional if using calculated XP approach.
    // If using stored XP in profiles, uncomment:
    // final xpRepo = _ref.read(xpRepositoryProvider);
    // await xpRepo.addXp(AppConstants.xpMoodCheckIn, 'mood');
    
    // Invalidate XP provider to refresh balance
    _ref.invalidate(xpProvider);
  }

  /// Gets mood entries for a specific date range
  Future<List<MoodEntry>> fetchMoodEntriesForRange(DateTime start, DateTime end) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await SupabaseService.client
          .from(AppConstants.tableMoodEntries)
          .select()
          .eq('user_id', userId)
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String())
          .order('created_at', ascending: false);

      return (data as List).map((e) => MoodEntry.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Gets today's mood entries
  Future<List<MoodEntry>> fetchTodaysMoodEntries() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    return fetchMoodEntriesForRange(todayStart, todayEnd);
  }
}
