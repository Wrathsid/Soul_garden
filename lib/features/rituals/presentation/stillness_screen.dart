import 'dart:async';

import 'package:flutter/material.dart';

class StillnessScreen extends StatefulWidget {
  const StillnessScreen({super.key});

  @override
  State<StillnessScreen> createState() => _StillnessScreenState();
}

class _StillnessScreenState extends State<StillnessScreen> {
  int _currentStep = 0;
  bool _isRunning = false;
  int _countdown = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Body Scan',
      'description': 'Close your eyes and bring awareness to each part of your body, starting from your toes up to your head.',
      'duration': 60,
      'icon': Icons.accessibility_new,
    },
    {
      'title': 'Deep Breathing',
      'description': 'Take 5 slow, deep breaths. Inhale for 4 counts, hold for 4, exhale for 6.',
      'duration': 45,
      'icon': Icons.air,
    },
    {
      'title': 'Gratitude Moment',
      'description': 'Think of 3 things you are grateful for today. Let warmth fill your heart.',
      'duration': 30,
      'icon': Icons.favorite,
    },
    {
      'title': 'Release Thoughts',
      'description': 'Imagine your thoughts as clouds passing by. Observe them without judgment.',
      'duration': 45,
      'icon': Icons.cloud_outlined,
    },
    {
      'title': 'Set Sleep Intention',
      'description': 'Visualize peaceful, restful sleep. Set an intention to wake feeling refreshed.',
      'duration': 30,
      'icon': Icons.nightlight_round,
    },
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStep() {
    setState(() {
      _isRunning = true;
      _countdown = _steps[_currentStep]['duration'];
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          if (_currentStep < _steps.length - 1) {
            _currentStep++;
          }
        });
      }
    });
  }

  void _skipStep() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_currentStep < _steps.length - 1) {
        _currentStep++;
      }
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isLastStep = _currentStep == _steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Night Wind-Down'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Progress bar
            Row(
              children: List.generate(_steps.length, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? const Color(0xFF5483B3)
                          : const Color(0xFF7DA0CA).withAlpha(51),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${_currentStep + 1} of ${_steps.length}',
              style: const TextStyle(
                color: Color(0xFF7DA0CA),
                fontSize: 12,
              ),
            ),

            const Spacer(),

            // Current step card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF052659),
                    Color(0xFF021024),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF7DA0CA).withAlpha(51),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    step['icon'],
                    size: 64,
                    color: const Color(0xFF7DA0CA),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    step['title'],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    step['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFC1E8FF),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (_isRunning)
                    Text(
                      _formatTime(_countdown),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: const Color(0xFF5483B3),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      '${step['duration']} seconds',
                      style: const TextStyle(
                        color: Color(0xFF7DA0CA),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(),

            // Action buttons
            Row(
              children: [
                if (_isRunning)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _skipStep,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7DA0CA),
                        side: const BorderSide(color: Color(0xFF7DA0CA)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLastStep && !_isRunning && _countdown == 0
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Night wind-down complete! 🌙 Sweet dreams!'),
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          : _startStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5483B3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isLastStep && !_isRunning && _countdown == 0
                            ? 'Complete'
                            : 'Begin',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
