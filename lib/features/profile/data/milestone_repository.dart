import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../services/supabase_client.dart';

final milestonesRepositoryProvider = Provider((ref) => MilestonesRepository());

/// Milestone definition with criteria
class MilestoneDefinition {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int rewardXp;
  final MilestoneType type;
  final int targetValue;

  const MilestoneDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rewardXp,
    required this.type,
    required this.targetValue,
  });
}

enum MilestoneType {
  moodEntries,
  ritualsCompleted,
  streakDays,
  therapySessions,
  shopPurchases,
}

/// All available milestones in the app
const List<MilestoneDefinition> allMilestones = [
  // Mood Milestones
  MilestoneDefinition(
    id: 'first_bloom',
    title: 'First Bloom',
    description: 'Log your first mood entry',
    icon: Icons.local_florist,
    rewardXp: 25,
    type: MilestoneType.moodEntries,
    targetValue: 1,
  ),
  MilestoneDefinition(
    id: 'growing_garden',
    title: 'Growing Garden',
    description: 'Log 10 mood entries',
    icon: Icons.park,
    rewardXp: 50,
    type: MilestoneType.moodEntries,
    targetValue: 10,
  ),
  MilestoneDefinition(
    id: 'flourishing_garden',
    title: 'Flourishing Garden',
    description: 'Log 50 mood entries',
    icon: Icons.forest,
    rewardXp: 150,
    type: MilestoneType.moodEntries,
    targetValue: 50,
  ),
  
  // Ritual Milestones
  MilestoneDefinition(
    id: 'first_ritual',
    title: 'First Ritual',
    description: 'Complete your first wellness ritual',
    icon: Icons.self_improvement,
    rewardXp: 25,
    type: MilestoneType.ritualsCompleted,
    targetValue: 1,
  ),
  MilestoneDefinition(
    id: 'ritual_seeker',
    title: 'Ritual Seeker',
    description: 'Complete 25 rituals',
    icon: Icons.spa,
    rewardXp: 100,
    type: MilestoneType.ritualsCompleted,
    targetValue: 25,
  ),
  MilestoneDefinition(
    id: 'ritual_master',
    title: 'Ritual Master',
    description: 'Complete 100 rituals',
    icon: Icons.auto_awesome,
    rewardXp: 300,
    type: MilestoneType.ritualsCompleted,
    targetValue: 100,
  ),
  
  // Streak Milestones
  MilestoneDefinition(
    id: 'week_warrior',
    title: 'Week Warrior',
    description: 'Maintain a 7-day streak',
    icon: Icons.local_fire_department,
    rewardXp: 75,
    type: MilestoneType.streakDays,
    targetValue: 7,
  ),
  MilestoneDefinition(
    id: 'fortnight_flame',
    title: 'Fortnight Flame',
    description: 'Maintain a 14-day streak',
    icon: Icons.whatshot,
    rewardXp: 150,
    type: MilestoneType.streakDays,
    targetValue: 14,
  ),
  MilestoneDefinition(
    id: 'monthly_dedication',
    title: 'Monthly Dedication',
    description: 'Maintain a 30-day streak',
    icon: Icons.emoji_events,
    rewardXp: 500,
    type: MilestoneType.streakDays,
    targetValue: 30,
  ),
  
  // Therapy Milestones
  MilestoneDefinition(
    id: 'first_conversation',
    title: 'First Conversation',
    description: 'Start your first chat with Sol',
    icon: Icons.chat_bubble_outline,
    rewardXp: 20,
    type: MilestoneType.therapySessions,
    targetValue: 1,
  ),
  MilestoneDefinition(
    id: 'trusted_friend',
    title: 'Trusted Friend',
    description: 'Have 10 conversations with Sol',
    icon: Icons.favorite,
    rewardXp: 100,
    type: MilestoneType.therapySessions,
    targetValue: 10,
  ),
];

/// Completed milestone record
class CompletedMilestone {
  final String id;
  final String milestoneId;
  final DateTime completedAt;

  CompletedMilestone({
    required this.id,
    required this.milestoneId,
    required this.completedAt,
  });

  factory CompletedMilestone.fromJson(Map<String, dynamic> json) {
    return CompletedMilestone(
      id: json['id'] as String? ?? '',
      milestoneId: json['milestone_id'] as String? ?? '',
      completedAt: DateTime.tryParse(json['completed_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// User-facing milestone with completion state
class UserMilestone {
  final MilestoneDefinition definition;
  final bool isCompleted;
  final DateTime? completedAt;
  final int currentProgress;

  const UserMilestone({
    required this.definition,
    required this.isCompleted,
    this.completedAt,
    required this.currentProgress,
  });

  double get progressPercent => 
      (currentProgress / definition.targetValue).clamp(0.0, 1.0);
}

class MilestonesRepository {
  /// Fetches completed milestones from the database
  Future<List<CompletedMilestone>> fetchCompletedMilestones() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await SupabaseService.client
          .from('milestones_completed')
          .select()
          .eq('user_id', userId);

      return (data as List).map((e) => CompletedMilestone.fromJson(e)).toList();
    } catch (e) {
      // Table might not exist yet
      return [];
    }
  }

  /// Gets current progress counts for each milestone type
  Future<Map<MilestoneType, int>> fetchProgressCounts() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return {};

    try {
      final moodCount = await SupabaseService.client
          .from(AppConstants.tableMoodEntries)
          .select()
          .eq('user_id', userId);

      final ritualCount = await SupabaseService.client
          .from(AppConstants.tableRitualsCompleted)
          .select()
          .eq('user_id', userId);

      // For therapy sessions, count unique days with chat messages
      // Simplified: just count total messages for now
      final chatCount = await SupabaseService.client
          .from(AppConstants.tableAiChat)
          .select()
          .eq('user_id', userId)
          .eq('role', 'user');

      final purchaseCount = await SupabaseService.client
          .from(AppConstants.tableUserInventory)
          .select()
          .eq('user_id', userId);

      return {
        MilestoneType.moodEntries: (moodCount as List).length,
        MilestoneType.ritualsCompleted: (ritualCount as List).length,
        MilestoneType.therapySessions: (chatCount as List).length,
        MilestoneType.shopPurchases: (purchaseCount as List).length,
        MilestoneType.streakDays: 0, // Calculated separately from streak provider
      };
    } catch (e) {
      return {};
    }
  }

  /// Checks for newly earned milestones and records them
  Future<List<MilestoneDefinition>> checkAndAwardMilestones({
    required Map<MilestoneType, int> progressCounts,
    required List<String> completedIds,
    int currentStreak = 0,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    final newlyCompleted = <MilestoneDefinition>[];

    for (final milestone in allMilestones) {
      // Skip if already completed
      if (completedIds.contains(milestone.id)) continue;

      // Get current progress for this type
      int progress;
      if (milestone.type == MilestoneType.streakDays) {
        progress = currentStreak;
      } else {
        progress = progressCounts[milestone.type] ?? 0;
      }

      // Check if milestone is achieved
      if (progress >= milestone.targetValue) {
        try {
          await SupabaseService.client
              .from('milestones_completed')
              .insert({
            'user_id': userId,
            'milestone_id': milestone.id,
          });
          newlyCompleted.add(milestone);
        } catch (e) {
          // Might fail if table doesn't exist
        }
      }
    }

    return newlyCompleted;
  }

  /// Gets all milestones with their completion status
  Future<List<UserMilestone>> getAllMilestonesWithStatus({int currentStreak = 0}) async {
    final completed = await fetchCompletedMilestones();
    final completedIds = completed.map((c) => c.milestoneId).toSet();
    final progress = await fetchProgressCounts();

    return allMilestones.map((def) {
      int currentProgress;
      if (def.type == MilestoneType.streakDays) {
        currentProgress = currentStreak;
      } else {
        currentProgress = progress[def.type] ?? 0;
      }

      final completedRecord = completed.where((c) => c.milestoneId == def.id).firstOrNull;

      return UserMilestone(
        definition: def,
        isCompleted: completedIds.contains(def.id),
        completedAt: completedRecord?.completedAt,
        currentProgress: currentProgress,
      );
    }).toList();
  }
}

/// Provider for all milestones with status
final milestonesProvider = FutureProvider<List<UserMilestone>>((ref) async {
  final repo = ref.watch(milestonesRepositoryProvider);
  return repo.getAllMilestonesWithStatus();
});
