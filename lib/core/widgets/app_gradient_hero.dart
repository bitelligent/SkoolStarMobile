import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';

/// Rounded gradient card for hero/featured content (greeting banner,
/// LIVE NOW, promotional callouts). Keeps every gradient card consistent.
class AppGradientHero extends StatelessWidget {
  const AppGradientHero({
    required this.child,
    this.gradient,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.radius,
    this.glowColor,
    super.key,
  });

  final Widget child;
  final LinearGradient? gradient;
  final EdgeInsetsGeometry padding;
  final BorderRadius? radius;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final g = gradient ?? AppGradients.primary;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: g,
        borderRadius: radius ?? BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.glow(glowColor ?? g.colors.last),
      ),
      child: child,
    );
  }
}
