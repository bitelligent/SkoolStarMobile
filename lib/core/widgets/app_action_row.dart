import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/icon_tile.dart';

/// Row with a coloured leading icon, title (+ optional subtitle) and
/// a trailing chevron. Used in Profile sections, Settings screens, and
/// anywhere a tappable "list item" is needed.
class AppActionRow extends StatelessWidget {
  const AppActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.iconColor = AppColors.primary,
    this.iconBackground,
    this.trailing,
    this.dense = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color? iconBackground;
  final Widget? trailing;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: dense ? AppSpacing.sm : AppSpacing.md,
          horizontal: 2,
        ),
        child: Row(
          children: [
            IconTile(
              icon: icon,
              background: iconBackground ?? iconColor.withOpacity(0.12),
              foreground: iconColor,
              size: dense ? 32 : 36,
              iconSize: dense ? 16 : 18,
              radius: AppRadius.sm,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.titleSmall),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.iconSubtle,
                ),
          ],
        ),
      ),
    );
  }
}
