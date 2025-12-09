import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Premium animated splash screen with blooming flower
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bloomController;
  late AnimationController _fadeController;
  late AnimationController _shimmerController;
  
  late Animation<double> _flowerScale;
  late Animation<double> _flowerRotation;
  late Animation<double> _textFade;
  late Animation<double> _shimmerProgress;

  @override
  void initState() {
    super.initState();

    // Flower bloom animation
    _bloomController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _flowerScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bloomController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _flowerRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _bloomController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Text fade in
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Shimmer effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      _shimmerController,
    );

    // Start animations in sequence
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _bloomController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _fadeController.forward();
    _shimmerController.repeat();
    
    // Navigate after animation completes
    await Future.delayed(const Duration(milliseconds: 1700));
    if (mounted) {
      context.go('/garden');
    }
  }

  @override
  void dispose() {
    _bloomController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.deepBackground,
              AppTheme.primarySurface.withValues(alpha: 0.5),
              AppTheme.deepBackground,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated flower
              AnimatedBuilder(
                animation: Listenable.merge([_bloomController, _shimmerController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _flowerScale.value,
                    child: Transform.rotate(
                      angle: _flowerRotation.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.warmGold.withValues(
                                    alpha: 0.3 * _flowerScale.value,
                                  ),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          // Flower icon
                          CustomPaint(
                            size: const Size(100, 100),
                            painter: _FlowerPainter(
                              progress: _flowerScale.value,
                              shimmer: _shimmerProgress.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // App name with fade
              AnimatedBuilder(
                animation: _textFade,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFade.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _textFade.value)),
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                AppTheme.lightAccent,
                                AppTheme.softHighlight,
                                AppTheme.lightAccent,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'SoulGarden',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'nurture your mind',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary.withValues(alpha: 0.7),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Loading shimmer
              AnimatedBuilder(
                animation: _shimmerProgress,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFade.value * 0.7,
                    child: SizedBox(
                      width: 100,
                      height: 3,
                      child: CustomPaint(
                        painter: _ShimmerPainter(
                          progress: _shimmerProgress.value,
                          color: AppTheme.softHighlight,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom flower painter with bloom animation
class _FlowerPainter extends CustomPainter {
  final double progress;
  final double shimmer;

  _FlowerPainter({required this.progress, required this.shimmer});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw petals
    const petalCount = 8;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i * pi * 2 / petalCount) - pi / 2;
      final petalProgress = (progress * 1.2 - i * 0.05).clamp(0.0, 1.0);
      
      if (petalProgress > 0) {
        final petalLength = 35 * petalProgress;
        final petalWidth = 18 * petalProgress;
        
        final paint = Paint()
          ..shader = RadialGradient(
            colors: [
              Color.lerp(
                AppTheme.warmPeach,
                AppTheme.warmGold,
                shimmer,
              )!,
              AppTheme.warmSunrise.withValues(alpha: 0.8),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: petalLength));
        
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(angle);
        
        final path = Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(
            petalWidth,
            petalLength * 0.5,
            0,
            petalLength,
          )
          ..quadraticBezierTo(
            -petalWidth,
            petalLength * 0.5,
            0,
            0,
          );
        
        canvas.drawPath(path, paint);
        canvas.restore();
      }
    }
    
    // Draw center
    final centerPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          AppTheme.warmGold,
          AppTheme.warmSunrise,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 12));
    
    canvas.drawCircle(center, 12 * progress, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _FlowerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.shimmer != shimmer;
  }
}

/// Shimmer loading indicator
class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShimmerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.2),
          color.withValues(alpha: 0.8),
          color.withValues(alpha: 0.2),
        ],
        stops: [
          (progress - 0.3).clamp(0.0, 1.0),
          progress,
          (progress + 0.3).clamp(0.0, 1.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
