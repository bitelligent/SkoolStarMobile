import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_sheet.dart';

/// Field-style dropdown. Tapping opens the common bottom sheet picker
/// defined in [showAppOptionsSheet].
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    required this.sheetTitle,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint,
    this.leading,
    super.key,
  });

  final String sheetTitle;
  final T? value;
  final List<AppOption<T>> options;
  final ValueChanged<T> onChanged;
  final String? hint;
  final Widget? leading;

  String get _display {
    for (final o in options) {
      if (o.id == value) return o.label;
    }
    return hint ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showAppOptionsSheet<T>(
          context,
          title: sheetTitle,
          options: options,
          selectedId: value,
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Expanded(
              child: Text(
                _display,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: value == null
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.iconSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

/// Field-style date picker. Shows the formatted date, opens
/// `showDatePicker` when tapped.
class AppDateField extends StatelessWidget {
  const AppDateField({
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.hint = 'Pick a date',
    super.key,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: firstDate ?? DateTime(2020),
          lastDate: lastDate ?? DateTime(2100),
          initialDate: value ?? DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value == null
                    ? hint
                    : DateFormat('EEE, d MMM y').format(value!),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: value == null
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.iconSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

/// Field-style time picker.
class AppTimeField extends StatelessWidget {
  const AppTimeField({
    required this.value,
    required this.onChanged,
    this.hint = 'Pick a time',
    super.key,
  });

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value == null ? hint : value!.format(context),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: value == null
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.iconSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
