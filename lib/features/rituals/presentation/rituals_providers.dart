import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/rituals_repository.dart';
import '../data/ritual_completion_model.dart';

final ritualsProvider = FutureProvider<List<RitualCompletion>>((ref) async {
  final repo = ref.watch(ritualsRepositoryProvider);
  return repo.fetchRitualCompletions();
});

final ritualStreaksProvider = StateNotifierProvider<RitualStreaksNotifier, Map<String, int>>((ref) {
  return RitualStreaksNotifier(ref);
});

class RitualStreaksNotifier extends StateNotifier<Map<String, int>> {
  final Ref ref;

  RitualStreaksNotifier(this.ref) : super({}) {
    _calculateStreaks();
  }

  Future<void> _calculateStreaks() async {
    final ritualsAsync = ref.watch(ritualsProvider);
    
    // We only proceed if data is available
    if (ritualsAsync.isLoading || ritualsAsync.hasError || !ritualsAsync.hasValue) return;
    
    final rituals = ritualsAsync.value!;
    final Map<String, int> streaks = {};
    final types = rituals.map((e) => e.ritualType).toSet();
    
    // Check for "Global Streak" or Per-Ritual Streak? Detailed req says "Ritual Streak Counter".
    // Usually per ritual.

    for (final type in types) {
      if (type == 'freeze_protected') continue; // Don't calc streak for the freeze marker itself

      final completions = rituals.where((r) => r.ritualType == type || r.ritualType == 'freeze_protected').toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
      
      if (completions.isEmpty) {
        streaks[type] = 0;
        continue;
      }
      
      final dates = completions.map((e) => DateTime(e.completedAt.year, e.completedAt.month, e.completedAt.day)).toSet().toList()
          ..sort((a, b) => b.compareTo(a));

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      // Calculate current streak
      int currentStreak = 0;
      DateTime checkDate = dates.contains(today) ? today : yesterday;
      
      // If broken (neither today nor yesterday present)
      if (!dates.contains(today) && !dates.contains(yesterday)) {
        // Attempt Freeze Logic
        final repo = ref.read(ritualsRepositoryProvider);
        final hasFreeze = await repo.hasStreakFreeze();
        
        if (hasFreeze) {
          // Use freeze!
          await repo.useStreakFreeze();
          // Insert local mock to update UI immediately? 
          // Or just refetch. Refetch is safer.
          final _ = await ref.refresh(ritualsProvider.future); // This will trigger _calculateStreaks again
          return; // Exit this run
        } else {
          currentStreak = 0;
        }
      } else {
        // Count backwards
        while (dates.contains(checkDate)) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        }
      }
      
      streaks[type] = currentStreak;

      // Weekly Bonus Check
      if (currentStreak > 0 && currentStreak % 7 == 0) {
        // We really should check if bonus already awarded for this instance.
        // Simplifying for now.
        // ref.read(ritualsRepositoryProvider).awardStreakBonus(currentStreak);
      }
    }
    
    state = streaks;
  }
}
