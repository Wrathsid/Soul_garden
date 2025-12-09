import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import 'garden_providers.dart';
import 'widgets/flower_widget.dart';
import 'widgets/mood_checkin_modal.dart';

class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getXpTierName(int xp) {
    if (xp < 50) return 'Seedling Gardener';
    if (xp < 150) return 'Budding Grower';
    if (xp < 300) return 'Bloom Keeper';
    if (xp < 500) return 'Garden Guardian';
    return 'Soul Cultivator';
  }

  @override
  Widget build(BuildContext context) {
    final gardenAsync = ref.watch(gardenProvider);

    return Scaffold(
      backgroundColor: AppTheme.deepBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 0. Personalized Greeting (H1)
              Text(
                '${_getGreeting()}, Siddharth',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 16),
              
              // 1. Stats Row (Streak & XP Chips)
              Row(
                children: [
                  Expanded(child: _buildStreakChip()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildXPChip()),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Garden Card - Main Visual
              _buildGardenCard(context, gardenAsync),
              
              const SizedBox(height: 20),

              // 3. Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.spa_outlined,
                      label: 'Talk to Sol',
                      onTap: () => context.go('/therapy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.self_improvement,
                      label: 'Start a Ritual',
                      onTap: () => context.go('/rituals'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCheckInModal(context),
        backgroundColor: AppTheme.secondaryAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Check In'),
      ),
    );
  }

  Widget _buildStreakChip() {
    const streakDays = 1; // TODO: Get from provider
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.warmGold.withAlpha(77)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warmGold.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_fire_department, color: AppTheme.warmGold, size: 20),
          const SizedBox(width: 8),
          Text(
            '$streakDays-day growth streak',
            style: TextStyle(
              color: AppTheme.warmGold,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPChip() {
    const xp = 10; // TODO: Get from provider
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.warmGold.withAlpha(77)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warmGold.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: AppTheme.warmGold, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$xp XP · ${_getXpTierName(xp)}',
              style: TextStyle(
                color: AppTheme.warmGold,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGardenCard(BuildContext context, AsyncValue gardenAsync) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Sky portion
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF7DA0CA),  // Soft highlight
                    Color(0xFFC1E8FF),  // Light accent
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Sun with warm glow
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.warmSunrise,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.warmGold.withAlpha(150),
                            blurRadius: 35,
                            spreadRadius: 15,
                          ),
                          BoxShadow(
                            color: AppTheme.warmPeach.withAlpha(100),
                            blurRadius: 50,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Month header
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                          onPressed: _previousMonth,
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_selectedMonth),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.white),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Green grass portion with flowers
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 120),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4ADE80), // Bright grass green
                    Color(0xFF22C55E), // Deeper green
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Grass texture pattern (simple hills)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: CustomPaint(
                      size: const Size(double.infinity, 30),
                      painter: _GrassWavePainter(),
                    ),
                  ),
                  // Flowers content
                  gardenAsync.when(
                    data: (entries) {
                      if (entries.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.eco_outlined,
                                  size: 44,
                                  color: Colors.white.withAlpha(200),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Your garden is waiting for\nits first feeling 🌱',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(230),
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: entries.map((entry) {
                            return FlowerWidget(
                              entry: entry,
                              isToday: false,
                              onTap: () {},
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                    error: (e, s) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  // Bloom counter with emotional context
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(60),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: gardenAsync.when(
                        data: (entries) {
                          final monthName = DateFormat('MMMM').format(_selectedMonth);
                          return Text(
                            '${entries.length} blooms from your $monthName feelings',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          );
                        },
                        loading: () => const Text(
                          '...',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        error: (_, __) => const Text(
                          '0 blooms',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
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

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.softHighlight.withAlpha(51),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.softHighlight, size: 24),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckInModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.primarySurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const MoodCheckInModal(),
    );
  }
}

// Custom painter for grass wave effect at top of grass area
class _GrassWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    
    // Create gentle wave
    for (var i = 0.0; i <= size.width; i += size.width / 8) {
      path.quadraticBezierTo(
        i + size.width / 16,
        (i.toInt() % 2 == 0) ? 0 : size.height * 0.6,
        i + size.width / 8,
        size.height,
      );
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

