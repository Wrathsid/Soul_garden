import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/supabase_client.dart';
import '../../../core/constants.dart';
import 'xp_transaction_model.dart';

final shopRepositoryProvider = Provider((ref) => ShopRepository());

class ShopRepository {
  Future<List<String>> fetchRecentPurchases() async {
    // This assumes inventory table has created_at and item_name/id
    // Returning list of item names or IDs
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await SupabaseService.client
          .from(AppConstants.tableUserInventory)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(3);
      
      return (data as List).map((e) => e['item_name'] as String? ?? 'Unknown').toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<XPTransaction>> fetchTransactionHistory() async {
     final userId = SupabaseService.currentUser?.id;
     if (userId == null) return [];

     // Fetch from 3 sources
     // 1. Mood Entries
     final moodData = await SupabaseService.client
         .from(AppConstants.tableMoodEntries)
         .select('created_at, mood_score')
         .eq('user_id', userId)
         .order('created_at', ascending: false)
         .limit(50); // limit for perf
     
     // 2. Rituals
     final ritualData = await SupabaseService.client
         .from(AppConstants.tableRitualsCompleted)
         .select('created_at, ritual_type')
         .eq('user_id', userId)
         .order('created_at', ascending: false)
         .limit(50);

     // 3. Purchases
     final purchaseData = await SupabaseService.client
         .from(AppConstants.tableUserInventory)
         .select('created_at, item_name, cost') // Assuming cost column exists
         .eq('user_id', userId)
         .order('created_at', ascending: false)
         .limit(50);

     List<XPTransaction> transactions = [];

     for (var m in (moodData as List)) {
       transactions.add(XPTransaction(
         description: 'Mood Check-in',
         amount: AppConstants.xpMoodCheckIn,
         date: DateTime.parse(m['created_at']),
         source: 'mood',
       ));
     }

     for (var r in (ritualData as List)) {
       final type = r['ritual_type'] ?? 'Ritual';
       transactions.add(XPTransaction(
         description: '$type Ritual',
         amount: AppConstants.xpRitual,
         date: DateTime.parse(r['created_at']),
         source: 'ritual',
       ));
     }

     for (var p in (purchaseData as List)) {
       final cost = p['cost'] as int? ?? 0;
       transactions.add(XPTransaction(
         description: 'Bought ${p['item_name']}',
         amount: -cost,
         date: DateTime.parse(p['created_at']),
         source: 'purchase',
       ));
     }

     // Global Sort
     transactions.sort((a, b) => b.date.compareTo(a.date));
     return transactions;
  }
}
