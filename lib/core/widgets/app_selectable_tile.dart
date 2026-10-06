import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';

/// Tappable row with avatar/initials + title/subtitle + selection check.
/// The whole row acts as a checkbox — tap anywhere to toggle. The selected
/// state tints the background and shows a filled check icon.
class AppSelectableTile extends StatelessWidget {
  const AppSelectableTile({
    required this.title,
    required this.selected,
    required this.onToggle,
    this.subtitle,
    this.avatarName,
    this.avatarUrl,
    this.leadingIcon,
    this.leadingColor,
    this.accent = AppColors.primary,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? avatarName;
  final String? avatarUrl;
  final IconData? leadingIcon;
  final Color? leadingColor;
  final Color accent;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.08) : AppColors.surface,
          border: Border.all(
            color: selected ? accent : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            if (avatarName != null || avatarUrl != null)
              AvatarCircle(
                imageUrl: avatarUrl,
                name: avatarName ?? title,
                size: 36,
              )
            else if (leadingIcon != null)
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (leadingColor ?? accent).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  leadingIcon,
                  color: leadingColor ?? accent,
                  size: 18,
                ),
              ),
            if (avatarName != null || avatarUrl != null || leadingIcon != null)
              const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? accent : Colors.transparent,
                border: Border.all(
                  color: selected ? accent : AppColors.borderStrong,
                  width: 1.4,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
