import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Smooth animated container for bottom tab navigation
/// Uses fade + subtle slide for premium feel
class AnimatedBranchContainer extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const AnimatedBranchContainer({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  @override
  State<AnimatedBranchContainer> createState() => _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer> 
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350), // Slightly longer for smoothness
      ),
    );

    // Create smooth fade animations
    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );
    }).toList();

    // Create subtle slide animations (very small movement)
    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0.0, 0.02), // Very subtle 2% slide
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );
    }).toList();

    // Initial state: show current index fully
    if (_controllers.isNotEmpty && 
        widget.navigationShell.currentIndex < _controllers.length) {
      _controllers[widget.navigationShell.currentIndex].value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Re-initialize if children count changes
    if (widget.children.length != oldWidget.children.length) {
      for (var controller in _controllers) {
        controller.dispose();
      }
      _initControllers();
    }

    final newIndex = widget.navigationShell.currentIndex;
    if (newIndex != _currentIndex) {
      _transition(from: _currentIndex, to: newIndex);
      _currentIndex = newIndex;
    }
  }

  late int _currentIndex = widget.navigationShell.currentIndex;
  
  void _transition({required int from, required int to}) {
    if (_controllers.isEmpty || 
        from >= _controllers.length || 
        to >= _controllers.length) {
      return;
    }
    
    // Reverse outgoing, forward incoming
    _controllers[from].reverse();
    _controllers[to].forward();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink(); 
    }

    return Stack(
      children: [
        for (int i = 0; i < widget.children.length; i++)
          AnimatedBuilder(
            animation: _controllers[i],
            builder: (context, child) {
              return IgnorePointer(
                ignoring: i != widget.navigationShell.currentIndex,
                child: FadeTransition(
                  opacity: _fadeAnimations[i],
                  child: SlideTransition(
                    position: _slideAnimations[i],
                    child: child,
                  ),
                ),
              );
            },
            child: widget.children[i],
          ),
      ],
    );
  }
}
