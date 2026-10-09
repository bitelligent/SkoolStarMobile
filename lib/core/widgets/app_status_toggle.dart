import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';

/// Three-way attendance pill — Present / Absent / Late. The selected
/// segment fills with its matching colour; the rest stay muted.
class AppAttendanceToggle extends StatelessWidget {
  const AppAttendanceToggle({
    required this.value,
    required this.onChanged,
    this.labels = const AppAttendanceLabels(),
    this.compact = false,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final AppAttendanceLabels labels;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final items = <(_StatusVariant, String, String, IconData, Color)>[
      (
        _StatusVariant.present,
        'present',
        labels.present,
        Icons.check_rounded,
        AppColors.success,
      ),
      (
        _StatusVariant.absent,
        'absent',
        labels.absent,
        Icons.close_rounded,
        AppColors.danger,
      ),
      (
        _StatusVariant.late,
        'late',
        labels.late,
        Icons.schedule_rounded,
        AppColors.warning,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: items
            .map(
              (it) => _StatusSegment(
                statusId: it.$2,
                label: it.$3,
                icon: it.$4,
                color: it.$5,
                active: value == it.$2,
                compact: compact,
                onTap: () => onChanged(it.$2),
              ),
            )
            .toList(),
      ),
    );
  }
}

class AppAttendanceLabels {
  const AppAttendanceLabels({
    this.present = 'Present',
    this.absent = 'Absent',
    this.late = 'Late',
  });
  final String present;
  final String absent;
  final String late;
}

enum _StatusVariant { present, absent, late }

class _StatusSegment extends StatelessWidget {
  const _StatusSegment({
    required this.statusId,
    required this.label,
    required this.icon,
    required this.color,
    required this.active,
    required this.onTap,
    required this.compact,
  });

  final String statusId;
  final String label;
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          vertical: compact ? 7 : 9,
          horizontal: AppSpacing.sm,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        // Scales the icon + label down when a third of the toggle is too
        // narrow (small phones, large text) instead of overflowing.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: compact ? 16 : 18,
                color: active ? Colors.white : color,
              ),
              if (!compact) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  maxLines: 1,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: active ? Colors.white : color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return compact ? child : Expanded(child: child);
  }
}
