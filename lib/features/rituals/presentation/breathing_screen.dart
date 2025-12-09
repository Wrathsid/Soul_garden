import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../data/rituals_repository.dart';

/// Breathing styles with their timing configurations
enum BreathingStyle {
  relaxing(
    name: 'Relaxing',
    description: 'Simple 4-4 breathing',
    inhale: 4,
    hold1: 0,
    exhale: 4,
    hold2: 0,
    icon: Icons.spa,
  ),
  boxBreathing(
    name: 'Box Breathing',
    description: '4-4-4-4 pattern for focus',
    inhale: 4,
    hold1: 4,
    exhale: 4,
    hold2: 4,
    icon: Icons.crop_square,
  ),
  calm478(
    name: '4-7-8 Calm',
    description: 'Deep relaxation technique',
    inhale: 4,
    hold1: 7,
    exhale: 8,
    hold2: 0,
    icon: Icons.nights_stay,
  );

  final String name;
  final String description;
  final int inhale;
  final int hold1;
  final int exhale;
  final int hold2;
  final IconData icon;

  const BreathingStyle({
    required this.name,
    required this.description,
    required this.inhale,
    required this.hold1,
    required this.exhale,
    required this.hold2,
    required this.icon,
  });

  int get totalDuration => inhale + hold1 + exhale + hold2;
}

class BreathingScreen extends ConsumerStatefulWidget {
  const BreathingScreen({super.key});

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen>
    with TickerProviderStateMixin {
  BreathingStyle _selectedStyle = BreathingStyle.relaxing;
  bool _isBreathing = false;
  bool _isCompleted = false;
  int _cycleCount = 0;
  static const int _targetCycles = 4;

  // Phase tracking
  String _currentPhase = 'Ready';
  int _currentSeconds = 0;
  Timer? _phaseTimer;

  // Animation controller for the breathing circle
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(vsync: this);
    _breatheAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _breatheController.dispose();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
      _cycleCount = 0;
    });
    _runCycle();
  }

  Future<void> _runCycle() async {
    if (_cycleCount >= _targetCycles) {
      _finishSession();
      return;
    }

    // Inhale
    await _runPhase('Inhale', _selectedStyle.inhale, expand: true);
    if (!_isBreathing) return;

    // Hold 1 (if applicable)
    if (_selectedStyle.hold1 > 0) {
      await _runPhase('Hold', _selectedStyle.hold1, expand: false);
      if (!_isBreathing) return;
    }

    // Exhale
    await _runPhase('Exhale', _selectedStyle.exhale, expand: false, shrink: true);
    if (!_isBreathing) return;

    // Hold 2 (if applicable)
    if (_selectedStyle.hold2 > 0) {
      await _runPhase('Hold', _selectedStyle.hold2, expand: false);
      if (!_isBreathing) return;
    }

    // Next cycle
    setState(() => _cycleCount++);
    _runCycle();
  }

  Future<void> _runPhase(String phaseName, int seconds,
      {bool expand = false, bool shrink = false}) async {
    if (!mounted || !_isBreathing) return;

    setState(() {
      _currentPhase = phaseName;
      _currentSeconds = seconds;
    });

    // Animate the circle
    if (expand) {
      _breatheController.duration = Duration(seconds: seconds);
      _breatheController.forward(from: 0.0);
    } else if (shrink) {
      _breatheController.duration = Duration(seconds: seconds);
      _breatheController.reverse(from: 1.0);
    }

    // Countdown timer
    final completer = Completer<void>();
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isBreathing) {
        timer.cancel();
        completer.complete();
        return;
      }
      setState(() => _currentSeconds--);
      if (_currentSeconds <= 0) {
        timer.cancel();
        completer.complete();
      }
    });

    return completer.future;
  }

  void _stopBreathing() {
    _phaseTimer?.cancel();
    _breatheController.stop();
    setState(() {
      _isBreathing = false;
      _currentPhase = 'Ready';
    });
  }

  void _finishSession() async {
    _phaseTimer?.cancel();
    _breatheController.stop();
    setState(() {
      _isBreathing = false;
      _isCompleted = true;
    });

    await ref.read(ritualsRepositoryProvider).logCompletion('breathe');

    if (mounted) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) context.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Breathe'),
          actions: [
            if (_isBreathing)
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: _stopBreathing,
              ),
          ],
        ),
        body: SafeArea(
          child: _isCompleted
              ? _buildCompletionView()
              : _isBreathing
                  ? _buildBreathingView()
                  : _buildSelectionView(),
        ),
      ),
    );
  }

  Widget _buildSelectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose Your Rhythm',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Select a breathing pattern that feels right for you.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...BreathingStyle.values.map((style) => _buildStyleCard(style)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _startBreathing,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryTeal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Begin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleCard(BreathingStyle style) {
    final isSelected = _selectedStyle == style;
    return GestureDetector(
      onTap: () => setState(() => _selectedStyle = style),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.secondaryTeal.withAlpha(40)
              : Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.secondaryTeal : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.secondaryTeal.withAlpha(80)
                    : Colors.white12,
                shape: BoxShape.circle,
              ),
              child: Icon(style.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    style.description,
                    style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.secondaryTeal),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cycle progress
          Text(
            'Cycle ${_cycleCount + 1} of $_targetCycles',
            style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
          ),
          const SizedBox(height: 24),
          // Phase instruction
          Text(
            _currentPhase,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                ),
          ).animate(key: ValueKey(_currentPhase)).fadeIn(duration: 300.ms),
          const SizedBox(height: 48),
          // Breathing circle with countdown
          AnimatedBuilder(
            animation: _breatheAnimation,
            builder: (context, child) {
              final size = 180 + (_breatheAnimation.value * 80);
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.secondaryTeal.withAlpha(60),
                      AppTheme.primaryBlue.withAlpha(30),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryTeal.withAlpha(40),
                      blurRadius: 30 + (_breatheAnimation.value * 20),
                      spreadRadius: 10 + (_breatheAnimation.value * 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$_currentSeconds',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w200,
                          fontSize: 64,
                        ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          // Soft ambient text
          Text(
            _getAmbientText(),
            style: TextStyle(
              color: Colors.white.withAlpha(140),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getAmbientText() {
    switch (_currentPhase) {
      case 'Inhale':
        return 'Let the air fill your lungs gently...';
      case 'Hold':
        return 'Rest in stillness...';
      case 'Exhale':
        return 'Release all tension...';
      default:
        return 'Find your center...';
    }
  }

  Widget _buildCompletionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.warmGold.withAlpha(60),
                  blurRadius: 40,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: const Icon(Icons.self_improvement,
                size: 80, color: AppTheme.warmGold),
          )
              .animate()
              .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.elasticOut)
              .fadeIn(),
          const SizedBox(height: 32),
          Text(
            'Well done.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 8),
          Text(
            'Your garden thanks you for this moment of calm.',
            style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}
