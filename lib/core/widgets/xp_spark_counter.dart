import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated XP counter with spark burst effect on increase
class XPSparkCounter extends StatefulWidget {
  final int xp;
  final TextStyle? style;
  final bool showIcon;

  const XPSparkCounter({
    super.key,
    required this.xp,
    this.style,
    this.showIcon = true,
  });

  @override
  State<XPSparkCounter> createState() => _XPSparkCounterState();
}

class _XPSparkCounterState extends State<XPSparkCounter>
    with TickerProviderStateMixin {
  late AnimationController _counterController;
  late AnimationController _sparkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sparkAnimation;
  
  int _displayedXp = 0;
  int _previousXp = 0;
  bool _showSparks = false;

  @override
  void initState() {
    super.initState();
    _displayedXp = widget.xp;
    _previousXp = widget.xp;
    
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _sparkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.95), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _counterController,
      curve: Curves.easeInOut,
    ));
    
    _sparkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkController, curve: Curves.easeOut),
    );
    
    _sparkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showSparks = false);
      }
    });
  }

  @override
  void didUpdateWidget(XPSparkCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.xp != oldWidget.xp) {
      _previousXp = oldWidget.xp;
      _animateChange();
    }
  }

  void _animateChange() {
    final difference = widget.xp - _previousXp;
    if (difference > 0) {
      // XP increased - show sparks!
      setState(() {
        _showSparks = true;
        _displayedXp = widget.xp;
      });
      _counterController.forward(from: 0);
      _sparkController.forward(from: 0);
    } else {
      setState(() => _displayedXp = widget.xp);
    }
  }

  @override
  void dispose() {
    _counterController.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Spark particles
        if (_showSparks)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _sparkAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SparkPainter(
                    progress: _sparkAnimation.value,
                    color: AppTheme.warmGold,
                  ),
                );
              },
            ),
          ),
        
        // Main counter
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showIcon) ...[
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppTheme.warmGold,
                          AppTheme.warmSunrise,
                        ],
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    '$_displayedXp XP',
                    style: widget.style ?? const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warmGold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Custom painter for spark burst effect
class _SparkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Random _random = Random(42); // Fixed seed for consistent pattern

  _SparkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: 1.0 - progress)
      ..style = PaintingStyle.fill;

    // Draw 8 sparks radiating outward
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + (_random.nextDouble() * 0.3);
      final distance = progress * 30 + _random.nextDouble() * 10;
      final sparkSize = (1 - progress) * 4;
      
      final sparkPos = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );
      
      canvas.drawCircle(sparkPos, sparkSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Compact XP display for chips/headers
class XPChip extends StatelessWidget {
  final int xp;
  final bool animate;

  const XPChip({
    super.key,
    required this.xp,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.warmGold.withValues(alpha: 0.2),
            AppTheme.warmSunrise.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.warmGold.withValues(alpha: 0.3),
        ),
      ),
      child: animate
          ? XPSparkCounter(xp: xp)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppTheme.warmGold,
                ),
                const SizedBox(width: 4),
                Text(
                  '$xp XP',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warmGold,
                  ),
                ),
              ],
            ),
    );
  }
}
