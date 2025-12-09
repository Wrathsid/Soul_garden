import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../services/supabase_client.dart';
import '../../xp/data/xp_repository.dart';
import 'xp_transaction_model.dart';

final shopRepositoryProvider = Provider((ref) => ShopRepository(ref));

/// Shop item model
class ShopItem {
  final String name;
  final String description;
  final int cost;
  final String iconName;
  final String category;

  const ShopItem({
    required this.name,
    required this.description,
    required this.cost,
    required this.iconName,
    this.category = 'decoration',
  });
}

/// Available items in the shop
const List<ShopItem> shopItems = [
  ShopItem(name: 'Stone Path', description: 'A serene walking path for your garden', cost: 50, iconName: 'landscape'),
  ShopItem(name: 'Lantern', description: 'Soft light for peaceful evenings', cost: 120, iconName: 'light'),
  ShopItem(name: 'Fountain', description: 'The gentle sound of flowing water', cost: 500, iconName: 'water_drop'),
  ShopItem(name: 'Bench', description: 'A place to rest and reflect', cost: 200, iconName: 'chair'),
  ShopItem(name: 'Cat Statue', description: 'A guardian for your garden', cost: 300, iconName: 'pets'),
  ShopItem(name: 'Streak Freeze', description: 'Protects your streak for one missed day', cost: 100, iconName: 'ac_unit', category: 'consumable'),
  ShopItem(name: 'Golden Flower', description: 'A rare bloom that never wilts', cost: 1000, iconName: 'local_florist'),
];

class ShopRepository {
  final Ref _ref;
  
  ShopRepository(this._ref);

  /// Gets all available shop items
  List<ShopItem> getShopItems() => shopItems;

  /// Attempts to purchase an item. Returns success status.
  Future<PurchaseResult> purchaseItem(ShopItem item) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      return PurchaseResult.notAuthenticated;
    }

    // Get current XP
    final xpRepo = _ref.read(xpRepositoryProvider);
    final currentXp = await xpRepo.calculateTotalXp();

    if (currentXp < item.cost) {
      return PurchaseResult.insufficientXp;
    }

    try {
      // Insert into inventory
      await SupabaseService.client
          .from(AppConstants.tableUserInventory)
          .insert({
        'user_id': userId,
        'item_name': item.name,
        'cost': item.cost,
        'is_consumed': false,
      });

      // Invalidate XP provider to refresh balance
      _ref.invalidate(xpProvider);

      return PurchaseResult.success;
    } catch (e) {
      return PurchaseResult.error;
    }
  }

  /// Fetches recently purchased items
  Future<List<String>> fetchRecentPurchases({int limit = 3}) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await SupabaseService.client
          .from(AppConstants.tableUserInventory)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List).map((e) => e['item_name'] as String? ?? 'Unknown').toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetches the user's owned items
  Future<List<String>> fetchOwnedItems() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await SupabaseService.client
          .from(AppConstants.tableUserInventory)
          .select('item_name')
          .eq('user_id', userId)
          .eq('is_consumed', false);

      return (data as List).map((e) => e['item_name'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetches XP transaction history
  Future<List<XPTransaction>> fetchTransactionHistory({int limit = 50}) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    try {
      // Mood entries
      final moodData = await SupabaseService.client
          .from(AppConstants.tableMoodEntries)
          .select('created_at, mood_score')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      // Rituals
      final ritualData = await SupabaseService.client
          .from(AppConstants.tableRitualsCompleted)
          .select('created_at, ritual_type')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      // Purchases
      final purchaseData = await SupabaseService.client
          .from(AppConstants.tableUserInventory)
          .select('created_at, item_name, cost')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

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
        // Skip freeze_protected entries as they don't give XP
        if (type == 'freeze_protected') continue;
        
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

      // Sort by date descending
      transactions.sort((a, b) => b.date.compareTo(a.date));
      return transactions;
    } catch (e) {
      return [];
    }
  }
}

/// Result of a purchase attempt
enum PurchaseResult {
  success,
  insufficientXp,
  notAuthenticated,
  error,
}
