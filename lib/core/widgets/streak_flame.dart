import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated streak flame icon that flickers based on streak length
class StreakFlame extends StatefulWidget {
  final int streakDays;
  final double size;
  final bool showCount;

  const StreakFlame({
    super.key,
    required this.streakDays,
    this.size = 24,
    this.showCount = true,
  });

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame>
    with TickerProviderStateMixin {
  late AnimationController _flickerController;
  late AnimationController _glowController;
  late Animation<double> _flickerAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Flicker animation - subtle scale variation
    _flickerController = AnimationController(
      duration: Duration(milliseconds: 150 + Random().nextInt(100)),
      vsync: this,
    );
    
    _flickerAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 0.97), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.03), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 25),
    ]).animate(_flickerController);
    
    _flickerController.repeat();
    
    // Glow animation - pulsing glow intensity
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _flickerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color _getFlameColor() {
    // Intensity increases with streak length
    if (widget.streakDays >= 30) {
      return const Color(0xFFFF4500); // Red-orange (legendary)
    } else if (widget.streakDays >= 14) {
      return const Color(0xFFFF6B35); // Bright orange
    } else if (widget.streakDays >= 7) {
      return AppTheme.warmSunrise;
    } else {
      return AppTheme.warmGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flameColor = _getFlameColor();
    
    return AnimatedBuilder(
      animation: Listenable.merge([_flickerAnimation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: widget.streakDays > 0
                ? [
                    BoxShadow(
                      color: flameColor.withValues(alpha: _glowAnimation.value),
                      blurRadius: 12 + (widget.streakDays * 0.5).clamp(0, 10),
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: _flickerAnimation.value,
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: widget.streakDays > 0
                        ? [
                            Colors.yellow,
                            flameColor,
                            flameColor.withValues(alpha: 0.8),
                          ]
                        : [
                            Colors.grey.shade400,
                            Colors.grey.shade600,
                          ],
                  ).createShader(bounds),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    size: widget.size,
                    color: Colors.white,
                  ),
                ),
              ),
              if (widget.showCount) ...[
                const SizedBox(width: 4),
                Text(
                  '${widget.streakDays}',
                  style: TextStyle(
                    fontSize: widget.size * 0.7,
                    fontWeight: FontWeight.bold,
                    color: widget.streakDays > 0 ? flameColor : Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Streak chip for use in headers/profile
class StreakChip extends StatelessWidget {
  final int streakDays;

  const StreakChip({super.key, required this.streakDays});

  String _getStreakLabel() {
    if (streakDays == 0) return 'Start your streak!';
    if (streakDays == 1) return '1 day';
    if (streakDays < 7) return '$streakDays days';
    if (streakDays < 14) return '$streakDays days 🔥';
    if (streakDays < 30) return '$streakDays days 🔥🔥';
    return '$streakDays days 🔥🔥🔥';
  }

  @override
  Widget build(BuildContext context) {
    final isActive = streakDays > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [
                  AppTheme.warmSunrise.withValues(alpha: 0.2),
                  AppTheme.warmGold.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isActive ? null : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppTheme.warmSunrise.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreakFlame(
            streakDays: streakDays,
            size: 18,
            showCount: false,
          ),
          const SizedBox(width: 6),
          Text(
            _getStreakLabel(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? AppTheme.warmSunrise : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
