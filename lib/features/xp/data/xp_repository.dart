import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../services/supabase_client.dart';

final xpRepositoryProvider = Provider((ref) => XPRepository());

/// Central repository for all XP-related operations.
/// Handles earning, spending, and syncing XP to the profiles table.
class XPRepository {
  /// Adds XP to the user's profile and logs the transaction.
  /// [amount] - Amount of XP to add
  /// [source] - Source of XP (mood, ritual, therapy, streak_bonus)
  Future<void> addXp(int amount, String source) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    // Update profiles table by incrementing XP
    await SupabaseService.client.rpc('increment_xp', params: {
      'user_id_param': userId,
      'amount_param': amount,
    });
    
    // If RPC doesn't exist, fall back to fetch + update
    // Note: This is less safe (race conditions) but works without DB function
    /*
    try {
      final current = await SupabaseService.client
          .from(AppConstants.tableProfiles)
          .select('xp')
          .eq('id', userId)
          .maybeSingle();
      
      final currentXp = (current?['xp'] as int?) ?? 0;
      
      await SupabaseService.client
          .from(AppConstants.tableProfiles)
          .upsert({
        'id': userId,
        'xp': currentXp + amount,
      });
    } catch (e) {
      // Log error but don't crash
    }
    */
  }

  /// Retrieves the user's current XP balance.
  Future<int> getXp() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return 0;

    try {
      final data = await SupabaseService.client
          .from(AppConstants.tableProfiles)
          .select('xp')
          .eq('id', userId)
          .maybeSingle();

      return (data?['xp'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Attempts to spend XP. Returns true if successful, false if insufficient.
  /// [amount] - Amount of XP to spend
  /// [itemName] - Name of item being purchased (for logging)
  Future<bool> spendXp(int amount, String itemName) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return false;

    try {
      final currentXp = await getXp();
      if (currentXp < amount) return false;

      // Deduct XP
      await SupabaseService.client
          .from(AppConstants.tableProfiles)
          .update({'xp': currentXp - amount})
          .eq('id', userId);

      // Log to inventory
      await SupabaseService.client
          .from(AppConstants.tableUserInventory)
          .insert({
        'user_id': userId,
        'item_name': itemName,
        'cost': amount,
        'is_consumed': false,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Calculates total XP from all sources for display purposes.
  /// This aggregates mood entries, rituals, and other XP sources.
  Future<int> calculateTotalXp() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return 0;

    try {
      // Count mood entries
      final moodCount = await SupabaseService.client
          .from(AppConstants.tableMoodEntries)
          .select()
          .eq('user_id', userId);

      // Count rituals
      final ritualCount = await SupabaseService.client
          .from(AppConstants.tableRitualsCompleted)
          .select()
          .eq('user_id', userId);

      // Count purchases (deductions)
      final purchases = await SupabaseService.client
          .from(AppConstants.tableUserInventory)
          .select('cost')
          .eq('user_id', userId);

      final earnedXp = (moodCount as List).length * AppConstants.xpMoodCheckIn +
          (ritualCount as List).length * AppConstants.xpRitual;

      final spentXp = (purchases as List)
          .fold<int>(0, (sum, p) => sum + ((p['cost'] as int?) ?? 0));

      return earnedXp - spentXp;
    } catch (e) {
      return 0;
    }
  }
}

/// Provider that exposes the current XP value reactively.
/// Use ref.invalidate(xpProvider) to refresh after earning/spending.
final xpProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(xpRepositoryProvider);
  return repo.calculateTotalXp();
});
