import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// A warm, glowing success toast widget for positive feedback
class SuccessToast extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onDismiss;

  const SuccessToast({
    super.key,
    required this.message,
    this.icon = Icons.check_circle,
    this.onDismiss,
  });

  /// Show the success toast as an overlay
  static void show(BuildContext context, String message, {IconData icon = Icons.check_circle}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 60,
        left: 24,
        right: 24,
        child: SuccessToast(
          message: message,
          icon: icon,
          onDismiss: () => entry.remove(),
        ),
      ),
    );
    
    overlay.insert(entry);
    
    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.warmGold.withAlpha(230),
              AppTheme.warmPeach.withAlpha(230),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.warmGold.withAlpha(100),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppTheme.warmSuccess.withAlpha(80),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF4A3728), // Dark warm brown for readability
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      )
      .animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: -0.3, end: 0, curve: Curves.easeOut)
      .then()
      .shimmer(duration: 1.seconds, color: Colors.white.withAlpha(50)),
    );
  }
}
