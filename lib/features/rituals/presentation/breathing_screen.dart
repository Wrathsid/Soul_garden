import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/theme/app_theme.dart';
import '../data/rituals_repository.dart';

class BreathingScreen extends ConsumerStatefulWidget {
  const BreathingScreen({super.key});

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _instruction = "Inhale";
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4s inhale
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _instruction = "Exhale");
          _controller.reverse(from: 1.0); // 4s exhale
        } else if (status == AnimationStatus.dismissed) {
          setState(() => _instruction = "Inhale");
          _controller.forward(from: 0.0);
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finishSession() async {
    setState(() => _isCompleted = true);
    _controller.stop();
    
    // Log completion
    await ref.read(ritualsRepositoryProvider).logCompletion('breathe');
    
    // Wait for animation then pop
    if (mounted) {
       Future.delayed(const Duration(seconds: 2), () {
         if (mounted) context.pop();
       });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Breathe')),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isCompleted ? "Well done." : _instruction,
                    style: Theme.of(context).textTheme.displayMedium,
                  ).animate(target: _isCompleted ? 1 : 0).fadeIn(),
                  const SizedBox(height: 48),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        width: 200 + (_controller.value * 100),
                        height: 200 + (_controller.value * 100),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.secondaryTeal.withAlpha(100),
                              AppTheme.primaryBlue.withAlpha(50),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isCompleted ? Colors.amber.withValues(alpha: 0.5) : AppTheme.secondaryTeal.withAlpha(50),
                              blurRadius: _isCompleted ? 50 : 20 + (_controller.value * 20),
                              spreadRadius: _isCompleted ? 20 : 10 + (_controller.value * 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                               _isCompleted ? Icons.check : Icons.air, 
                               size: 64, 
                               color: _isCompleted ? Colors.amber : AppTheme.secondaryTeal
                            ).animate(target: _isCompleted ? 1 : 0)
                             .scale(begin: const Offset(1,1), end: const Offset(1.2,1.2), curve: Curves.elasticOut, duration: 800.ms)
                             .then().shimmer(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  if (!_isCompleted)
                    ElevatedButton(
                      onPressed: _finishSession,
                      child: const Text('Finish Session'),
                    ),
                ],
              ),
            ),
            if (_isCompleted)
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: List.generate(20, (index) {
                      // Simple confetti simulation with Icons
                      return Align(
                        alignment: Alignment.center,
                        child: Icon(Icons.star, color: Colors.amber, size: 20)
                        .animate()
                        .move(
                          begin: const Offset(0,0), 
                          end: Offset((index % 2 == 0 ? 100 : -100) * (index + 1).toDouble() / 5, (index % 3 == 0 ? -100 : 100) * (index + 1).toDouble() / 5), 
                          duration: 1000.ms,
                          curve: Curves.easeOut
                        )
                        .fadeOut(delay: 500.ms, duration: 500.ms),
                      );
                    }),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
