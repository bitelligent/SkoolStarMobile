import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_sheet.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';

/// Chip-style filter picker used on the Dashboard and Schedule. Day stays a
/// single-select; Classes and Subjects are **multi-select** — tapping a
/// chip opens a sheet with checkboxes, and the chip label collapses to
/// "N classes" / "N subjects" once more than one is picked.
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    required this.classes,
    required this.subjects,
    required this.dayFilter,
    required this.classFilterIds,
    required this.subjectFilterIds,
    required this.onDayChanged,
    required this.onClassesChanged,
    required this.onSubjectsChanged,
    required this.onReset,
    this.showDay = true,
    this.defaultDay = '',
    this.selectedDate,
    super.key,
  });

  final List<ClassGroup> classes;
  final List<Subject> subjects;
  final String dayFilter;
  final Set<String> classFilterIds;
  final Set<String> subjectFilterIds;
  final ValueChanged<String> onDayChanged;
  final ValueChanged<Set<String>> onClassesChanged;
  final ValueChanged<Set<String>> onSubjectsChanged;
  final VoidCallback onReset;
  final bool showDay;

  /// The day filter value that counts as "not filtered" (the app's default).
  final String defaultDay;

  /// A specific day picked on the calendar; shown in the Day chip.
  final DateTime? selectedDate;

  bool get _dayActive =>
      selectedDate != null || (showDay && dayFilter != defaultDay);

  bool get _anyActive =>
      _dayActive || classFilterIds.isNotEmpty || subjectFilterIds.isNotEmpty;

  Color _parseHex(String hex) {
    final value = hex.replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  String _classesLabel() {
    if (classFilterIds.isEmpty) return 'All classes';
    if (classFilterIds.length == 1) {
      final c = classes.firstWhere(
        (x) => x.id == classFilterIds.first,
        orElse: () => classes.first,
      );
      return c.name;
    }
    return '${classFilterIds.length} classes';
  }

  String _subjectsLabel() {
    if (subjectFilterIds.isEmpty) return 'All subjects';
    if (subjectFilterIds.length == 1) {
      final s = subjects.firstWhere(
        (x) => x.id == subjectFilterIds.first,
        orElse: () => subjects.first,
      );
      return s.name;
    }
    return '${subjectFilterIds.length} subjects';
  }

  Color _subjectAccent() {
    if (subjectFilterIds.length == 1) {
      final s = subjects.firstWhere(
        (x) => x.id == subjectFilterIds.first,
        orElse: () => subjects.first,
      );
      return _parseHex(s.colorHex);
    }
    return AppColors.accentPurple;
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel = selectedDate != null
        ? DateFormat('EEE, d MMM').format(selectedDate!)
        : switch (dayFilter) {
            '' => 'All days',
            'today' => 'Today',
            'week' => 'This week',
            'month' => 'This month',
            final other => other,
          };

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (showDay) ...[
            _Chip(
              label: dayLabel,
              icon: Icons.calendar_today_rounded,
              active: _dayActive,
              count: 0,
              color: AppColors.primary,
              onTap: () => _pickDay(context),
            ),
            const SizedBox(width: 8),
          ],
          _Chip(
            label: _classesLabel(),
            icon: Icons.groups_rounded,
            active: classFilterIds.isNotEmpty,
            count: classFilterIds.length,
            color: AppColors.accentIndigo,
            onTap: () => _pickClasses(context),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: _subjectsLabel(),
            icon: Icons.menu_book_rounded,
            active: subjectFilterIds.isNotEmpty,
            count: subjectFilterIds.length,
            color: _subjectAccent(),
            onTap: () => _pickSubjects(context),
          ),
          if (_anyActive) ...[
            const SizedBox(width: 8),
            _ResetChip(onTap: onReset),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDay(BuildContext context) async {
    final picked = await showAppOptionsSheet<String>(
      context,
      title: 'Day',
      selectedId: selectedDate != null
          ? null
          : (dayFilter.isEmpty ? 'all' : dayFilter),
      options: const [
        AppOption(
          id: 'all',
          label: 'All days',
          icon: Icons.calendar_today_outlined,
        ),
        AppOption(id: 'today', label: 'Today', icon: Icons.today_rounded),
        AppOption(
          id: 'week',
          label: 'This week',
          icon: Icons.date_range_rounded,
        ),
        AppOption(
          id: 'month',
          label: 'This month',
          icon: Icons.event_repeat_rounded,
        ),
      ],
    );
    if (picked != null) onDayChanged(picked == 'all' ? '' : picked);
  }

  Future<void> _pickClasses(BuildContext context) async {
    final picked = await showAppMultiSelectSheet<String>(
      context,
      title: 'Filter by class',
      initialSelection: classFilterIds,
      options: [
        for (final c in classes)
          AppOption(
            id: c.id,
            label: c.name,
            icon: Icons.groups_rounded,
            color: _parseHex(c.colorHex),
            subtitle: c.studentCount == 1
                ? '1 student'
                : '${c.studentCount} students',
          ),
      ],
    );
    if (picked != null) onClassesChanged(picked);
  }

  Future<void> _pickSubjects(BuildContext context) async {
    final picked = await showAppMultiSelectSheet<String>(
      context,
      title: 'Filter by subject',
      initialSelection: subjectFilterIds,
      options: [
        for (final s in subjects)
          AppOption(
            id: s.id,
            label: s.name,
            icon: Icons.menu_book_rounded,
            color: _parseHex(s.colorHex),
          ),
      ],
    );
    if (picked != null) onSubjectsChanged(picked);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.active,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final int count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = active ? color : AppColors.surface;
    final fg = active ? Colors.white : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: active ? color : AppColors.border),
          boxShadow: active ? null : AppShadows.cardSoft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (active && count > 1) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: fg.withOpacity(active ? 1 : 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetChip extends StatelessWidget {
  const _ResetChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.danger.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.filter_alt_off_rounded,
              size: 14,
              color: AppColors.danger,
            ),
            const SizedBox(width: 4),
            Text(
              'Clear',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
