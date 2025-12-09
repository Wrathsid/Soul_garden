import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_model.dart';
import '../data/profile_repository.dart';

final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchProfile();
});

final profileStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchStats();
});

// Re-export milestones provider from milestone_repository for convenience
// The main milestonesProvider and milestonesRepositoryProvider are defined in milestone_repository.dart
