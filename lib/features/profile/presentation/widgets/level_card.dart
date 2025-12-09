import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LevelCard extends StatelessWidget {
  final int xp;
  final int level;
  final double progress;

  const LevelCard({
    super.key,
    required this.xp,
    required this.level,
    required this.progress,
  });

  String _getLevelTitle(int level) {
    if (level == 1) return 'Seedling Gardener';
    if (level == 2) return 'Budding Grower';
    if (level == 3) return 'Bloom Keeper';
    if (level == 4) return 'Garden Guardian';
    return 'Soul Cultivator';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(51)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withAlpha(38),
                Colors.white.withAlpha(13),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level $level',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getLevelTitle(level),
                        style: TextStyle(
                          color: Colors.white.withAlpha(179),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.warmGold.withAlpha(77),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.warmGold.withAlpha(128)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.warmGold.withAlpha(40),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: AppTheme.warmGold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$xp XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withAlpha(26),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.warmGold),
                  minHeight: 8,
                ),
              ).animate(target: 1).shimmer(duration: 2.seconds, delay: 500.ms, color: Colors.white.withAlpha(50)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}% to next level',
                    style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 12),
                  ),
                  Text(
                    'Keep growing! 🌱',
                    style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
