import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/supabase_client.dart';
import '../../../core/constants.dart';
import 'ritual_completion_model.dart';

final ritualsRepositoryProvider = Provider((ref) => RitualsRepository());

class RitualsRepository {
  Future<List<RitualCompletion>> fetchRitualCompletions() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return [];

      final data = await SupabaseService.client
          .from(AppConstants.tableRitualsCompleted)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((e) => RitualCompletion.fromJson(e)).toList();
    } catch (e) {
      return [];
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

    // 1. Consume item
    // Finding one instance
    final item = await SupabaseService.client
        .from(AppConstants.tableUserInventory)
        .select('id')
        .eq('user_id', userId)
        .eq('item_name', 'Streak Freeze')
        .limit(1)
        .maybeSingle();
    
    if (item != null) {
      await SupabaseService.client
          .from(AppConstants.tableUserInventory)
          .delete() // Or update is_consumed = true
          .eq('id', item['id']);

      // 2. Log 'freeze_protected' completion for *yesterday* to maintain streak
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await SupabaseService.client.from(AppConstants.tableRitualsCompleted).insert({
        'user_id': userId,
        'ritual_type': 'freeze_protected',
        'created_at': yesterday.toIso8601String(),
      });
    }
  }

  Future<void> logCompletion(String ritualType) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    await SupabaseService.client.from(AppConstants.tableRitualsCompleted).insert({
      'user_id': userId,
      'ritual_type': ritualType,
    });
    
    // Check for weekly reward (logic moved to provider or separate call to avoid side effects here, 
    // but simple version: if streak hits 7, 14 etc. give bonus).
    // For now, we leave it to the provider to check streak after refresh and award.
  }

  Future<void> awardStreakBonus(int streak) async {
     // Award XP
     // We assume logic elsewhere handles "only once per week" by checking a log.
     // For simplicity in this demo, we just log the XP event if not recently logged? 
     // Or we just rely on the user seeing the notification.
  }
}
