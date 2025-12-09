import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Hero circle for Start Your Journey section
class HeroCircle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const HeroCircle({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.local_florist,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing circle with orbiting dots
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.2),
                    AppTheme.primaryBlue.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Inner circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.accentTeal,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
            ),
            // Orbiting dots
            ...List.generate(4, (index) {
              final angle = (index * 90) * 3.14159 / 180;
              final radius = 60.0;
              return Positioned(
                left: 70 + radius * _cos(angle) - 4,
                top: 70 + radius * _sin(angle) - 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentTeal.withValues(alpha: 0.6),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  double _sin(double radians) => radians.isNaN ? 0 : (radians - radians * radians * radians / 6);
  double _cos(double radians) => radians.isNaN ? 1 : (1 - radians * radians / 2);
}
