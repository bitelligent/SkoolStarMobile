import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';

/// Circular avatar that falls back to coloured initials if no image is given
/// or the network image fails to load.
class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    this.imageUrl,
    this.name = '',
    this.size = 44,
    this.background,
    this.foreground,
    super.key,
  });

  final String? imageUrl;
  final String name;
  final double size;
  final Color? background;
  final Color? foreground;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = background ?? AppColors.primaryLight;
    final fg = foreground ?? AppColors.primary;

    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        _initials,
        style: AppTextStyles.titleSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.34,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return fallback;
        },
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}
