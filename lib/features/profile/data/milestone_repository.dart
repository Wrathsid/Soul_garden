import 'package:flutter/material.dart';
import '../domain/milestone.dart';

class MilestoneRepository {
  Future<List<Milestone>> getMilestones() async {
    // Mimic network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return const [
      Milestone(
        id: '1',
        title: 'First Bloom',
        description: 'Plant your first flower by writing a journal entry.',
        isCompleted: true,
        icon: Icons.local_florist,
        rewardXp: 100,
      ),
      Milestone(
        id: '2',
        title: 'Sprouting',
        description: 'Maintain a 3-day journaling streak.',
        isCompleted: true,
        icon: Icons.grass,
        rewardXp: 250,
      ),
      Milestone(
        id: '3',
        title: 'In Full Bloom',
        description: 'Maintain a 7-day journaling streak.',
        isCompleted: false,
        icon: Icons.filter_vintage,
        rewardXp: 500,
      ),
      Milestone(
        id: '4',
        title: 'Gardener',
        description: 'Reach Level 5.',
        isCompleted: false,
        icon: Icons.person_outline,
        rewardXp: 1000,
      ),
      Milestone(
        id: '5',
        title: 'Zen Master',
        description: 'Complete 10 meditation sessions.',
        isCompleted: false,
        icon: Icons.self_improvement,
        rewardXp: 750,
      ),
    ];
  }
}
