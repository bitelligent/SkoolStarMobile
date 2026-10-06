import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';

/// Universal pill-shaped chip. Use for subject tags, class filters, status
/// badges, selectable options — anywhere a small coloured label is needed.
///
/// Pass [selected] when the chip is tappable; the fill switches from the
/// soft tint to the solid [color], with white text + icon.
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.icon,
    this.color = AppColors.primary,
    this.selected = false,
    this.onTap,
    this.dense = false,
    this.showCheck = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;
  final bool dense;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? color : color.withOpacity(0.12);
    final fg = selected ? Colors.white : color;
    final padH = dense ? AppSpacing.sm : AppSpacing.md;
    final padV = dense ? 4.0 : 6.0;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: dense ? 12 : 14, color: fg),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: (dense ? AppTextStyles.labelSmall : AppTextStyles.labelMedium)
              .copyWith(color: fg, fontWeight: FontWeight.w600),
        ),
        if (showCheck && selected) ...[
          const SizedBox(width: 4),
          Icon(Icons.check_rounded, size: dense ? 12 : 14, color: fg),
        ],
      ],
    );

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: selected ? color : color.withOpacity(0.16),
        ),
      ),
      child: content,
    );

    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: chip,
    );
  }
}

/// Horizontally scrollable row of [AppChip]s backed by a controller value.
/// Pass [options] as `(id, label, color?, icon?)` records; `null` id acts
/// as the "All" / unselected sentinel.
class AppChipRow extends StatelessWidget {
  const AppChipRow({
    required this.options,
    required this.selectedId,
    required this.onSelect,
    this.height = 36,
    super.key,
  });

  final List<AppChipOption> options;
  final String? selectedId;
  final ValueChanged<String?> onSelect;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final o = options[i];
          return AppChip(
            label: o.label,
            icon: o.icon,
            color: o.color ?? AppColors.primary,
            selected: selectedId == o.id,
            onTap: () => onSelect(o.id),
          );
        },
      ),
    );
  }
}

/// Lightweight record-like option for [AppChipRow].
class AppChipOption {
  const AppChipOption({
    required this.id,
    required this.label,
    this.color,
    this.icon,
  });

  final String? id;
  final String label;
  final Color? color;
  final IconData? icon;
}
