import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/theme/app_theme.dart';
import 'shop_providers.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentPurchasesProvider);
    final historyAsync = ref.watch(xpHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Garden Shop')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Recently Purchased
            recentAsync.when(
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recently Purchased', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: items.map((item) => Chip(
                        label: Text(item),
                        avatar: const Icon(Icons.check, size: 16),
                        backgroundColor: Colors.white,
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_,__) => const SizedBox.shrink(),
            ),

            Text('Available Items', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
              children: [
                _buildShopItem(context, 'Stone Path', 50, Icons.landscape),
                _buildShopItem(context, 'Lantern', 120, Icons.light),
                _buildShopItem(context, 'Fountain', 500, Icons.water_drop),
                _buildShopItem(context, 'Bench', 200, Icons.chair),
                _buildShopItem(context, 'Cat Statue', 300, Icons.pets),
              ],
            ),
            
            const SizedBox(height: 24),
            Text('XP History', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            
            historyAsync.when(
              data: (history) {
                 if (history.isEmpty) return const Text('No history yet.');
                 return AppCard(
                   child: ListView.separated(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     itemCount: history.length > 5 ? 5 : history.length,
                     separatorBuilder: (_,__) => const Divider(),
                     itemBuilder: (context, index) {
                       final tx = history[index];
                       final isPositive = tx.amount > 0;
                       return ListTile(
                         dense: true,
                         leading: Icon(
                           isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
                           color: isPositive ? Colors.green : Colors.red,
                         ),
                         title: Text(tx.description),
                         trailing: Text(
                           '${isPositive ? '+' : ''}${tx.amount} XP',
                           style: TextStyle(
                             color: isPositive ? Colors.green : Colors.red,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                         subtitle: Text(DateFormat.MMMd().format(tx.date)),
                       );
                     },
                   ),
                 );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e,__) => Text('Error loading history: $e'),
            ),
             const SizedBox(height: 50),
          ],
        ),
    );
  }

  Widget _buildShopItem(BuildContext context, String name, int price, IconData icon) {
    return AppCard(
      onTap: () {
        // Preview Modal
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Container(
                   height: 150,
                   width: double.infinity,
                   color: Colors.grey.shade100,
                   child: Icon(icon, size: 80, color: AppTheme.secondaryAccent),
                 ),
                 const SizedBox(height: 16),
                 const Text('Preview provided. This item will look great in your garden!'),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () { 
                   Navigator.pop(context);
                   // Buy logic would go here
                },
                child: Text('Buy for $price XP'),
              ),
            ],
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppTheme.secondaryAccent),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Chip(
            label: Text('$price XP'),
            backgroundColor: AppTheme.accentGreen.withAlpha(30),
            labelStyle: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
