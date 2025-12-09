import 'dart:math';
import 'package:flutter/material.dart';

/// Floating ambient particles for premium atmosphere
class AmbientParticles extends StatefulWidget {
  final Color particleColor;
  final int particleCount;
  final double speed;
  final bool isFirefly;

  const AmbientParticles({
    super.key,
    this.particleColor = const Color(0xFFFFE4B5),
    this.particleCount = 20,
    this.speed = 1.0,
    this.isFirefly = false,
  });

  @override
  State<AmbientParticles> createState() => _AmbientParticlesState();
}

class _AmbientParticlesState extends State<AmbientParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (_) => _Particle.random(_random, widget.isFirefly),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            color: widget.particleColor,
            progress: _controller.value,
            speed: widget.speed,
            isFirefly: widget.isFirefly,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x; // 0.0 to 1.0
  double y; // 0.0 to 1.0
  double size;
  double speedMultiplier;
  double opacity;
  double phaseOffset; // For firefly blinking
  double swayOffset; // For horizontal sway

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedMultiplier,
    required this.opacity,
    required this.phaseOffset,
    required this.swayOffset,
  });

  factory _Particle.random(Random random, bool isFirefly) {
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: isFirefly ? 2 + random.nextDouble() * 3 : 1 + random.nextDouble() * 2,
      speedMultiplier: 0.5 + random.nextDouble() * 0.5,
      opacity: 0.3 + random.nextDouble() * 0.5,
      phaseOffset: random.nextDouble() * pi * 2,
      swayOffset: random.nextDouble() * pi * 2,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  final double progress;
  final double speed;
  final bool isFirefly;

  _ParticlePainter({
    required this.particles,
    required this.color,
    required this.progress,
    required this.speed,
    required this.isFirefly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate position with upward drift and horizontal sway
      final y = (particle.y - (progress * speed * particle.speedMultiplier)) % 1.0;
      final sway = sin(progress * pi * 4 + particle.swayOffset) * 0.02;
      final x = (particle.x + sway).clamp(0.0, 1.0);

      // Calculate opacity with fade in/out at edges
      double opacity = particle.opacity;
      if (y < 0.1) {
        opacity *= y / 0.1;
      } else if (y > 0.9) {
        opacity *= (1.0 - y) / 0.1;
      }

      // Firefly blinking effect
      if (isFirefly) {
        final blink = (sin(progress * pi * 6 + particle.phaseOffset) + 1) / 2;
        opacity *= 0.3 + blink * 0.7;
      }

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final position = Offset(x * size.width, y * size.height);

      // Draw glow for fireflies
      if (isFirefly && opacity > 0.5) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: opacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(position, particle.size * 2, glowPaint);
      }

      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Floating petals effect for garden
class FloatingPetals extends StatefulWidget {
  final Color petalColor;
  final int petalCount;

  const FloatingPetals({
    super.key,
    this.petalColor = const Color(0xFFFFB6C1),
    this.petalCount = 12,
  });

  @override
  State<FloatingPetals> createState() => _FloatingPetalsState();
}

class _FloatingPetalsState extends State<FloatingPetals>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Petal> _petals;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _petals = List.generate(
      widget.petalCount,
      (_) => _Petal.random(_random),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _PetalPainter(
            petals: _petals,
            color: widget.petalColor,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Petal {
  double x;
  double y;
  double size;
  double rotation;
  double rotationSpeed;
  double fallSpeed;
  double swayAmplitude;
  double swayOffset;

  _Petal({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.fallSpeed,
    required this.swayAmplitude,
    required this.swayOffset,
  });

  factory _Petal.random(Random random) {
    return _Petal(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: 4 + random.nextDouble() * 4,
      rotation: random.nextDouble() * pi * 2,
      rotationSpeed: 0.5 + random.nextDouble(),
      fallSpeed: 0.3 + random.nextDouble() * 0.4,
      swayAmplitude: 0.02 + random.nextDouble() * 0.03,
      swayOffset: random.nextDouble() * pi * 2,
    );
  }
}

class _PetalPainter extends CustomPainter {
  final List<_Petal> petals;
  final Color color;
  final double progress;

  _PetalPainter({
    required this.petals,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final petal in petals) {
      // Calculate position with falling and swaying
      final y = (petal.y + progress * petal.fallSpeed) % 1.0;
      final sway = sin(progress * pi * 4 + petal.swayOffset) * petal.swayAmplitude;
      final x = (petal.x + sway).clamp(0.0, 1.0);

      // Calculate opacity with fade at edges
      double opacity = 0.6;
      if (y < 0.1) {
        opacity *= y / 0.1;
      } else if (y > 0.85) {
        opacity *= (1.0 - y) / 0.15;
      }

      final position = Offset(x * size.width, y * size.height);
      final rotation = petal.rotation + progress * pi * 2 * petal.rotationSpeed;

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(rotation);

      // Draw petal shape (ellipse)
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: petal.size,
          height: petal.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
