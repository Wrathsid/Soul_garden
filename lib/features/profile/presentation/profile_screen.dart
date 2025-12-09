import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../data/milestone_repository.dart';
import 'profile_providers.dart';
import 'widgets/level_card.dart';
import 'widgets/milestone_card.dart';
import 'widgets/streak_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _getXpTierName(int xp) {
    if (xp < 50) return 'Seedling Gardener';
    if (xp < 150) return 'Budding Grower';
    if (xp < 300) return 'Bloom Keeper';
    if (xp < 500) return 'Garden Guardian';
    return 'Soul Cultivator';
  }

  String _getMoodEmoji(int? latestMood) {
    if (latestMood == null) return '';
    const emojis = ['😢', '😕', '😐', '🙂', '🤩'];
    if (latestMood < 1) return emojis[0];
    if (latestMood > 5) return emojis[4];
    return emojis[latestMood - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final milestonesAsync = ref.watch(milestonesProvider);

    // Mock stats (in production would come from provider)
    const journalCount = 2;
    const ritualCount = 1;
    const latestMood = 4;

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // H1 Header
                Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Avatar Section with Guardian Glow
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsing glow
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.warmGold.withAlpha(60),
                              blurRadius: 25,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .custom(
                         duration: 3.seconds,
                         builder: (context, value, child) {
                           return Container(
                             width: 130,
                             height: 130,
                             decoration: BoxDecoration(
                               shape: BoxShape.circle,
                               boxShadow: [
                                 BoxShadow(
                                   color: AppTheme.warmGold.withAlpha((40 + (value * 40)).toInt()),
                                   blurRadius: 25 + (value * 10),
                                   spreadRadius: 10 + (value * 5),
                                 ),
                                 BoxShadow(
                                   color: AppTheme.warmPeach.withAlpha((20 + (value * 30)).toInt()),
                                   blurRadius: 35 + (value * 15),
                                   spreadRadius: 15 + (value * 8),
                                 ),
                               ],
                             ),
                           );
                         }),
                      // Avatar container
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppTheme.primaryBlue, width: 4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ClipOval(
                            child: Container(
                                color: Colors.grey.shade200, 
                                child: const Icon(Icons.pets, size: 60, color: Colors.grey)
                            ),
                          ),
                        ),
                      ),
                      // Mood emoji badge
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(25),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            _getMoodEmoji(latestMood),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                
                profileAsync.when(
                  data: (profile) {
                    final xp = profile?.xp ?? 0;
                    final level = (xp / 100).floor() + 1;
                    final progress = (xp % 100) / 100.0;
                    
                    return Column(
                      children: [
                        Center(
                          child: Text(
                            profile?.displayName ?? 'Gardener',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // XP tier display
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.warmGold.withAlpha(40),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: AppTheme.warmGold, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  '$xp XP · ${_getXpTierName(xp)}',
                                  style: const TextStyle(
                                    color: AppTheme.warmGold,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        LevelCard(xp: xp, level: level, progress: progress),
                        const SizedBox(height: 16),
                        // Decorate Garden Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Navigate to decorate screen
                            },
                            icon: const Icon(Icons.brush, color: Colors.white),
                            label: const Text('Decorate Garden', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const Text('Error loading profile'),
                ),

                const SizedBox(height: 24),
                
                // Stats with improved streak display
                statsAsync.when(
                  data: (stats) {
                    final streakDays = stats['entries'] ?? 0;
                    return StreakCard(streakDays: streakDays);
                  },
                  loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox(),
                ),
                
                const SizedBox(height: 24),

                // Summary line
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySurface.withAlpha(200),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.softHighlight.withAlpha(50)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_stories, color: AppTheme.warmPeach, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "You've written $journalCount journals and completed $ritualCount ritual so far.",
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Milestones
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    'Milestones',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                milestonesAsync.when(
                  data: (milestones) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: milestones.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return MilestoneCard(milestone: milestones[index])
                            .animate()
                            .fadeIn(duration: 500.ms, delay: (100 * index).ms)
                            .slideX(begin: 0.1, end: 0);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error loading milestones: $err'),
                ),
                
                const SizedBox(height: 24),
                
                // Sign Out Button
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Sign out logic
                    },
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
    );
  }
}
