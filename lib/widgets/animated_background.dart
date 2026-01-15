import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const AnimatedBackground({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 30),
  });
  
  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Deep Ocean color palette
  static const List<Color> _backgroundColors = [
    Color(0xFF0F3460), // Deep Blue
    Color(0xFF1A1A2E), // Navy
    Color(0xFF16213E), // Dark Blue
  ];

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
      animation: _animation,
      builder: (context, child) {
        // Calculate moving gradient positions based on animation value
        final animationValue = _animation.value;
        
        // Create moving effect by animating gradient start/end positions
        final beginX = -1.0 + (2.0 * animationValue);
        final beginY = -0.5 + (1.0 * animationValue);
        final endX = 1.0 - (2.0 * animationValue);
        final endY = 0.5 - (1.0 * animationValue);
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _backgroundColors,
              begin: Alignment(beginX, beginY),
              end: Alignment(endX, endY),
              tileMode: TileMode.clamp,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}