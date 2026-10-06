import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';

/// White rounded surface used everywhere for grouping content. Uses the
/// shared [AppShadows] tokens so elevation is consistent across the app.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.onTap,
    this.borderColor,
    this.borderRadius,
    this.background,
    this.showShadow = true,
    this.showBorder = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final Color? background;
  final bool showShadow;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.lg);
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: background ?? AppColors.surface,
        borderRadius: radius,
        border: showBorder
            ? Border.all(color: borderColor ?? AppColors.border)
            : null,
        boxShadow: showShadow ? AppShadows.cardSoft : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: card,
      ),
    );
  }
}

/// Card with a coloured left accent stripe — used for session cards,
/// highlighted rows, period markers.
class AccentCard extends StatelessWidget {
  const AccentCard({
    required this.child,
    required this.accentColor,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.onTap,
    this.stripeWidth = 4,
    super.key,
  });

  final Widget child;
  final Color accentColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double stripeWidth;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardSoft,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: stripeWidth, color: accentColor),
            Expanded(child: Padding(padding: padding, child: child)),
          ],
        ),
      ),
    );

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: body,
      ),
    );
  }
}

/// Full-width horizontal section title (icon + title + optional trailing).
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    required this.title,
    this.icon,
    this.iconColor,
    this.trailing,
    super.key,
  });

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
