import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../utils/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final LinearGradient? gradient;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.gradient,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: width ?? double.infinity,
        height: height,
        borderRadius: borderRadius?.resolve(TextDirection.ltr).topLeft.x ?? AppTheme.borderRadius,
        blur: 20,
        padding: padding ?? const EdgeInsets.all(AppTheme.paddingMedium),
        margin: margin,
        alignment: Alignment.center,
        border: 2,
        linearGradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.glassCardColor.withOpacity(0.1),
                AppTheme.glassCardColor.withOpacity(0.05),
              ],
              stops: const [0.1, 1],
            ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.glassBorderColor.withOpacity(0.5),
            AppTheme.glassBorderColor.withOpacity(0.1),
          ],
        ),
        child: child,
      ),
    );
  }
}