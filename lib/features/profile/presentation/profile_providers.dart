import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';
import '../data/profile_model.dart';
import '../data/milestone_repository.dart';
import '../domain/milestone.dart';

final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchProfile();
});

final profileStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchStats();
});

final milestoneRepositoryProvider = Provider((ref) => MilestoneRepository());

final milestonesProvider = FutureProvider<List<Milestone>>((ref) async {
  final repo = ref.watch(milestoneRepositoryProvider);
  return repo.getMilestones();
});
