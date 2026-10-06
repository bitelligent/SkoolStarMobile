import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';

/// One function used everywhere to show a styled bottom sheet. Handles the
/// rounded top, grab handle, title row and padding.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
    ),
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title, style: AppTextStyles.titleMedium),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.iconSubtle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(child: builder(sheetContext)),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    ),
  );
}

/// Selectable option used by [showAppOptionsSheet].
class AppOption<T> {
  const AppOption({
    required this.id,
    required this.label,
    this.icon,
    this.color,
    this.subtitle,
  });

  final T id;
  final String label;
  final IconData? icon;
  final Color? color;
  final String? subtitle;
}

/// Common multi-select sheet. Returns the user's final [Set] of ids, or
/// null if the sheet was dismissed without an Apply. Shows a checkable
/// row per option plus a "Clear all" / "Apply" footer.
Future<Set<T>?> showAppMultiSelectSheet<T>(
  BuildContext context, {
  required String title,
  required List<AppOption<T>> options,
  required Set<T> initialSelection,
  String applyLabel = 'Apply',
}) {
  return showAppSheet<Set<T>>(
    context,
    title: title,
    isScrollControlled: true,
    builder: (sheetContext) => _MultiSelectBody<T>(
      options: options,
      initialSelection: initialSelection,
      applyLabel: applyLabel,
      onApply: (set) => Navigator.of(sheetContext).pop(set),
    ),
  );
}

class _MultiSelectBody<T> extends StatefulWidget {
  const _MultiSelectBody({
    required this.options,
    required this.initialSelection,
    required this.applyLabel,
    required this.onApply,
  });

  final List<AppOption<T>> options;
  final Set<T> initialSelection;
  final String applyLabel;
  final ValueChanged<Set<T>> onApply;

  @override
  State<_MultiSelectBody<T>> createState() => _MultiSelectBodyState<T>();
}

class _MultiSelectBodyState<T> extends State<_MultiSelectBody<T>> {
  late Set<T> _selection = Set<T>.from(widget.initialSelection);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.55,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            shrinkWrap: true,
            itemCount: widget.options.length,
            itemBuilder: (context, i) {
              final o = widget.options[i];
              final selected = _selection.contains(o.id);
              final accent = o.color ?? AppColors.primary;
              return InkWell(
                onTap: () => setState(() {
                  if (selected) {
                    _selection.remove(o.id);
                  } else {
                    _selection.add(o.id);
                  }
                }),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md - 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        selected ? accent.withOpacity(0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: selected ? accent : AppColors.border,
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (o.icon != null) ...[
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(o.icon, size: 16, color: accent),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.label, style: AppTextStyles.titleSmall),
                            if (o.subtitle != null)
                              Text(
                                o.subtitle!,
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
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _selection.isEmpty
                    ? null
                    : () => setState(_selection.clear),
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text('Clear all'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${_selection.length} selected',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => widget.onApply(_selection),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(widget.applyLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Common single-select sheet. Returns the picked [T] or null if dismissed.
Future<T?> showAppOptionsSheet<T>(
  BuildContext context, {
  required String title,
  required List<AppOption<T>> options,
  T? selectedId,
}) {
  return showAppSheet<T>(
    context,
    title: title,
    builder: (sheetContext) => ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      shrinkWrap: true,
      itemCount: options.length,
      itemBuilder: (context, i) {
        final o = options[i];
        final selected = o.id == selectedId;
        final accent = o.color ?? AppColors.primary;
        return InkWell(
          onTap: () => Navigator.of(sheetContext).pop(o.id),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md - 2,
            ),
            decoration: BoxDecoration(
              color: selected ? accent.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                if (o.icon != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(o.icon, size: 16, color: accent),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.label, style: AppTextStyles.titleSmall),
                      if (o.subtitle != null)
                        Text(
                          o.subtitle!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: accent, size: 20),
              ],
            ),
          ),
        );
      },
    ),
  );
}
