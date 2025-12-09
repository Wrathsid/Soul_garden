import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/mood_entry_model.dart';
import '../../../../core/theme/app_theme.dart';

class FlowerWidget extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback onTap;
  final bool isToday;

  const FlowerWidget({
    super.key,
    required this.entry,
    required this.onTap,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine flower visual based on moodScore
    // 1-2: Sad (Droopy, Blue/Grey)
    // 3: Neutral (Normal, Green/Teal)
    // 4-5: Happy (Bright, Yellow/Orange/Pink)
    
    Color flowerColor;
    IconData flowerIcon;
    double scale;

    if (entry.moodScore <= 2) {
      flowerColor = const Color(0xFF64748B); // Slate
      flowerIcon = Icons.local_florist_outlined;
      scale = 0.8;
    } else if (entry.moodScore == 3) {
      flowerColor = AppTheme.softHighlight;
      flowerIcon = Icons.filter_vintage_outlined;
      scale = 1.0;
    } else {
      flowerColor = const Color(0xFFF472B6); // Pink
      flowerIcon = Icons.auto_awesome;
      scale = 1.2;
    }

    Widget flower = Icon(
      flowerIcon,
      color: flowerColor,
      size: 32 * scale,
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .scale(
      duration: (2000 + (entry.moodScore * 200)).ms,
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.05, 1.05),
      curve: Curves.easeInOut,
    );

    // Apply enhanced entrance animation if it's today's bloom (new bloom)
    if (isToday) {
      flower = Stack(
        alignment: Alignment.center,
        children: [
          // Warm glow behind the flower
          Container(
            width: 40 * scale,
            height: 40 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.warmGold.withAlpha(120),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: AppTheme.warmPeach.withAlpha(80),
                  blurRadius: 25,
                  spreadRadius: 10,
                ),
              ],
            ),
          ).animate()
           .fadeIn(duration: 600.ms)
           .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), duration: 800.ms),
          flower,
        ],
      );
      
      // Wrap with entrance animation
      flower = flower.animate()
       .scale(
         begin: const Offset(0.8, 0.8), 
         end: const Offset(1.0, 1.0), 
         duration: 800.ms, 
         curve: Curves.elasticOut,
       )
       .fadeIn(duration: 400.ms);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          flower,
          Container(
            width: 2,
            height: 20,
            color: Colors.green.shade300,
          ),
        ],
      ),
    );
  }
}
