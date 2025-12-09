import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../profile/data/milestone_repository.dart';

/// Overlay widget to celebrate milestone completion
class MilestoneCelebration extends StatelessWidget {
  final MilestoneDefinition milestone;
  final VoidCallback onDismiss;

  const MilestoneCelebration({
    super.key,
    required this.milestone,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: InkWell(
        onTap: onDismiss,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.warmGold.withAlpha(60),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.warmGold.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    milestone.icon,
                    size: 64,
                    color: AppTheme.warmGold,
                  ),
                )
                    .animate()
                    .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.elasticOut)
                    .shimmer(delay: 400.ms, duration: 800.ms),
                const SizedBox(height: 24),

                // Achievement text
                const Text(
                  '🎉 Achievement Unlocked!',
                  style: TextStyle(
                    color: AppTheme.warmGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),

                // Milestone name
                Text(
                  milestone.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),

                // Description
                Text(
                  milestone.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 20),

                // XP reward
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.warmGold.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.warmGold.withAlpha(100)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppTheme.warmGold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '+${milestone.rewardXp} XP',
                        style: const TextStyle(
                          color: AppTheme.warmGold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 24),

                // Dismiss button
                TextButton(
                  onPressed: onDismiss,
                  child: const Text('Continue', style: TextStyle(fontSize: 16)),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ).animate().scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
                curve: Curves.easeOut,
              ),
        ),
      ),
    );
  }
}

/// Helper to show milestone celebration as overlay
void showMilestoneCelebration(BuildContext context, MilestoneDefinition milestone) {
  late OverlayEntry overlayEntry;
  
  overlayEntry = OverlayEntry(
    builder: (context) => MilestoneCelebration(
      milestone: milestone,
      onDismiss: () => overlayEntry.remove(),
    ),
  );
  
  Overlay.of(context).insert(overlayEntry);
  
  // Auto-dismiss after 5 seconds
  Future.delayed(const Duration(seconds: 5), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}
