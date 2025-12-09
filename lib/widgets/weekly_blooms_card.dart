import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Weekly blooms card showing garden progress
class WeeklyBloomsCard extends StatelessWidget {
  final bool hasBloomsThisWeek;

  const WeeklyBloomsCard({
    super.key,
    this.hasBloomsThisWeek = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Sky gradient top
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primaryBlue.withValues(alpha: 0.3),
                            AppTheme.accentTeal.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Soil area
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: const Color(0xFFF5F0E8),
                    ),
                  ),
                ],
              ),
            ),
            // Sun icon top right
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.achievementGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wb_sunny,
                  color: AppTheme.achievementGold,
                  size: 24,
                ),
              ),
            ),
            // Current week filter
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Current Week',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 18, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
            // Navigation arrows
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.chevron_left, color: AppTheme.textSecondary),
                  onPressed: () {},
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                  onPressed: () {},
                ),
              ),
            ),
            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco,
                    size: 48,
                    color: AppTheme.primaryBlue.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasBloomsThisWeek ? 'Your blooms this week' : 'No blooms this week.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
