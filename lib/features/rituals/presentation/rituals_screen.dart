import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'rituals_providers.dart';

class RitualsScreen extends ConsumerStatefulWidget {
  const RitualsScreen({super.key});

  @override
  ConsumerState<RitualsScreen> createState() => _RitualsScreenState();
}

class _RitualsScreenState extends ConsumerState<RitualsScreen> {
  // Track favorite rituals locally
  final Set<String> _favorites = {};
  
  // Mock usage data (in production would come from provider)
  final Map<String, int> _weeklyUsage = {
    'breathe': 3,
    'dream': 0,
    'journal': 1,
    'stillness': 2,
    'affirmations': 0,
  };

  void _toggleFavorite(String ritualId) {
    setState(() {
      if (_favorites.contains(ritualId)) {
        _favorites.remove(ritualId);
      } else {
        _favorites.add(ritualId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final streaks = ref.watch(ritualStreaksProvider);

    // Build ritual list, favorites first
    final rituals = [
      _RitualData('breathe', 'Breathing', 'Box breathing', Icons.air, const Color(0xFF00BFA5), '/rituals/breathe'),
      _RitualData('dream', 'Dream Journal', 'Record dreams', Icons.cloud_outlined, const Color(0xFF7C4DFF), '/rituals/dream'),
      _RitualData('journal', 'Deep Healing', '5-step reflection', Icons.favorite_border, const Color(0xFFFF7043), '/rituals/journal', isPremium: true),
      _RitualData('stillness', 'Night Wind-Down', 'Sleep preparation', Icons.nightlight_round, const Color(0xFF5C6BC0), '/rituals/stillness', isPremium: true),
      _RitualData('affirmations', 'Stress Flush', 'Release tension', Icons.water_drop_outlined, const Color(0xFF29B6F6), '/rituals/affirmations', isPremium: true),
    ];

    // Sort: favorites first
    rituals.sort((a, b) {
      final aFav = _favorites.contains(a.id) ? 0 : 1;
      final bFav = _favorites.contains(b.id) ? 0 : 1;
      return aFav.compareTo(bFav);
    });

    return Scaffold(
      backgroundColor: AppTheme.deepBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // H1 Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Rituals',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'Daily practices for inner peace',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.78,
                children: rituals.map((ritual) {
                  return _buildRitualCard(
                    context,
                    id: ritual.id,
                    title: ritual.title,
                    description: ritual.description,
                    icon: ritual.icon,
                    accentColor: ritual.accentColor,
                    route: ritual.route,
                    streak: streaks[ritual.id] ?? 0,
                    isPremium: ritual.isPremium,
                    weeklyCount: _weeklyUsage[ritual.id] ?? 0,
                    isFavorite: _favorites.contains(ritual.id),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRitualCard(BuildContext context, {
    required String id,
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required String route,
    int streak = 0,
    bool isPremium = false,
    int weeklyCount = 0,
    bool isFavorite = false,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFavorite 
              ? AppTheme.warmGold.withAlpha(100) 
              : AppTheme.softHighlight.withAlpha(51),
            width: isFavorite ? 2 : 1,
          ),
          boxShadow: isFavorite ? [
            BoxShadow(
              color: AppTheme.warmGold.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary.withAlpha(180),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Progress chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: weeklyCount > 0 
                      ? accentColor.withAlpha(40)
                      : Colors.grey.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    weeklyCount > 0 ? '${weeklyCount}x this week' : 'New',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: weeklyCount > 0 ? accentColor : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            // Favorite star (top-right)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _toggleFavorite(id),
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? AppTheme.warmGold : AppTheme.softHighlight.withAlpha(150),
                  size: 22,
                ),
              ),
            ),
            // Premium badge (if applicable)
            if (isPremium)
              const Positioned(
                top: 0,
                left: 0,
                child: Icon(Icons.workspace_premium, color: Colors.amber, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _RitualData {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String route;
  final bool isPremium;

  _RitualData(this.id, this.title, this.description, this.icon, this.accentColor, this.route, {this.isPremium = false});
}
