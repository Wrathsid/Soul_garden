import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/shop_repository.dart';
import '../data/xp_transaction_model.dart';

final recentPurchasesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.fetchRecentPurchases();
});

final xpHistoryProvider = FutureProvider<List<XPTransaction>>((ref) async {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.fetchTransactionHistory();
});
