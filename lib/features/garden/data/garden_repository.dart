import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/supabase_client.dart';
import '../../../core/constants.dart';
import 'mood_entry_model.dart';

final gardenRepositoryProvider = Provider((ref) => GardenRepository());

class GardenRepository {
  Future<List<MoodEntry>> fetchMoodEntries() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return [];

      final data = await SupabaseService.client
          .from(AppConstants.tableMoodEntries)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((e) => MoodEntry.fromJson(e)).toList();
    } catch (e) {
      // Return empty list on error for now (or throw)
      return [];
    }
  }

  Future<void> addMoodEntry(MoodEntry entry) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;
    
    await SupabaseService.client.from(AppConstants.tableMoodEntries).insert({
      ...entry.toJson(),
      'user_id': userId, // Ensure user_id is set from auth
    });
  }
}
