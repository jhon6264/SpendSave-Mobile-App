import 'package:flutter/material.dart';
import 'dart:math';

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

  // Original color palette from app_theme.dart
  static const List<Color> _baseColors = [
    Color(0xFF0F3460), // Deep Blue
    Color(0xFF1A1A2E), // Navy
    Color(0xFF16213E), // Dark Blue
  ];

  @override
  void initState() {
    super.initState();

    // Controller for infinite seamless animation
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear, // Linear for smooth continuous movement
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Generate interpolated colors for continuous cycling
  List<Color> _getCyclingColors(double progress) {
    // Multiply progress by number of colors for complete cycles
    final double offset = progress * _baseColors.length;

    // Create three interpolated colors that shift through the palette
    return List.generate(3, (index) {
      // Calculate which two base colors to interpolate between
      final double colorPos = (offset + index) % _baseColors.length;
      final int colorIndex = colorPos.floor();
      final double lerpAmount = colorPos - colorIndex;

      // Get the two colors to interpolate
      final Color colorA = _baseColors[colorIndex];
      final Color colorB = _baseColors[(colorIndex + 1) % _baseColors.length];

      // Smooth interpolation using sinusoidal easing
      final double easedLerp = _smoothStep(lerpAmount);
      return Color.lerp(colorA, colorB, easedLerp)!;
    });
  }

  // Smoothstep function for smoother transitions
  double _smoothStep(double t) {
    return t * t * (3 - 2 * t);
  }

  // Calculate gradient positions for flowing effect
  Alignment _getGradientStart(double progress) {
    // Create circular motion for gradient angle
    final double angle = progress * 2 * 3.14159;
    final double x = -0.5 + 0.3 * (1.0 + sin(angle)) / 2;
    final double y = -0.5 + 0.3 * (1.0 + cos(angle)) / 2;
    return Alignment(x, y);
  }

  Alignment _getGradientEnd(double progress) {
    // Opposite direction for dynamic gradient
    final double angle = progress * 2 * 3.14159 + 3.14159;
    final double x = 0.5 - 0.3 * (1.0 + sin(angle)) / 2;
    final double y = 0.5 - 0.3 * (1.0 + cos(angle)) / 2;
    return Alignment(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double progress = _animation.value;
        
        // Get current colors in the cycle
        final List<Color> currentColors = _getCyclingColors(progress);
        
        // Get current gradient positions
        final Alignment gradientStart = _getGradientStart(progress);
        final Alignment gradientEnd = _getGradientEnd(progress);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: currentColors,
              begin: gradientStart,
              end: gradientEnd,
              stops: const [0.0, 0.5, 1.0],
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