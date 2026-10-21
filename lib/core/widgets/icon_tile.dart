import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';

/// Rounded coloured square that holds an icon. Used in Quick Actions and
/// as the trailing visual on class cards.
class IconTile extends StatelessWidget {
  const IconTile({
    required this.icon,
    this.background,
    this.foreground,
    this.size = 44,
    this.iconSize,
    this.radius,
    super.key,
  });

  final IconData icon;
  final Color? background;
  final Color? foreground;
  final double size;
  final double? iconSize;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final foreground = this.foreground ?? context.brand.primary;
    final background = this.background ?? context.brand.primaryLight;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius ?? AppRadius.md),
      ),
      child: Icon(
        icon,
        size: iconSize ?? size * 0.5,
        color: foreground,
      ),
    );
  }
}
