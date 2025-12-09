import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/milestone_repository.dart';

class MilestoneCard extends StatelessWidget {
  final UserMilestone milestone;

  const MilestoneCard({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    // Determine visuals based on completion
    final opacity = milestone.isCompleted ? 1.0 : 0.5;
    final iconColor = milestone.isCompleted ? const Color(0xFF69F0AE) : Colors.grey;
    final backgroundColor = milestone.isCompleted
        ? Colors.lightGreenAccent.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.05);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  milestone.definition.icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.definition.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: opacity),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      milestone.definition.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: opacity * 0.7),
                          ),
                    ),
                    // Progress bar for incomplete milestones
                    if (!milestone.isCompleted) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: milestone.progressPercent,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber.withValues(alpha: 0.7),
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${milestone.currentProgress}/${milestone.definition.targetValue}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Status Indicator (Checkmark or Lock/Reward)
              if (milestone.isCompleted)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.black,
                  ),
                )
              else
                 Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(
                      Icons.lock_outline,
                       color: Colors.white.withValues(alpha: 0.3),
                       size: 20,
                     ),
                     const SizedBox(height: 2),
                     Text(
                       '+${milestone.definition.rewardXp} XP',
                       style: TextStyle(
                         color: Colors.amber.withValues(alpha: 0.7),
                         fontSize: 10,
                         fontWeight: FontWeight.bold,
                       ),
                     )
                   ],
                 ),
            ],
          ),
        ),
      ),
    );
  }
}
