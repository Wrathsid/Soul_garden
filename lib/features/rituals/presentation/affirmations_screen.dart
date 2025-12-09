import 'package:flutter/material.dart';

class AffirmationsScreen extends StatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<String> _affirmations = [
    "I release all tension from my body and mind.",
    "I am calm, centered, and at peace.",
    "I let go of stress and embrace tranquility.",
    "My breath flows easily and deeply.",
    "I am worthy of rest and relaxation.",
    "Every exhale releases negativity from my being.",
    "I am present in this moment, and all is well.",
    "I choose peace over worry.",
    "My body knows how to heal and restore itself.",
    "I am safe, I am supported, I am loved.",
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stress Release'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Release & Affirm',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFFC1E8FF),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Swipe through affirmations. Breathe deeply with each one.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF7DA0CA),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 40),

          // Affirmation cards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: _affirmations.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF052659),
                            const Color(0xFF5483B3).withAlpha(77),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF7DA0CA).withAlpha(77),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5483B3).withAlpha(51),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.water_drop_outlined,
                            size: 48,
                            color: Color(0xFF7DA0CA),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _affirmations[index],
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _affirmations.length,
                (index) => Container(
                  width: index == _currentIndex ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index == _currentIndex
                        ? const Color(0xFF5483B3)
                        : const Color(0xFF7DA0CA).withAlpha(77),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Complete button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _complete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5483B3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Complete Session',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _complete() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stress release complete! 💙')),
    );
    Navigator.of(context).pop();
  }
}
