import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';

/// Compact header card used at the top of every Session Detail tab.
///
/// Layout, top to bottom:
///   1. Status badge (LIVE / TODAY / UPCOMING) + lock icon
///   2. Combined date + time card in a primary-soft panel — both facts
///      grouped visually since they describe the same thing
///   3. "SUBJECTS" eyebrow + chip row
///   4. "CLASSES"  eyebrow + chip row
class SessionHeaderCard extends StatelessWidget {
  const SessionHeaderCard({
    required this.session,
    required this.classes,
    required this.subjects,
    super.key,
  });

  final Session session;
  final List<ClassGroup> classes;
  final List<Subject> subjects;

  Color _parseHex(String hex) {
    final value = hex.replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  ({String label, IconData icon, Color color}) _statusChip() {
    if (session.isLive) {
      return (
        label: 'LIVE',
        icon: Icons.podcasts_rounded,
        color: AppColors.success,
      );
    }
    final n = DateTime.now();
    final isToday = session.date.year == n.year &&
        session.date.month == n.month &&
        session.date.day == n.day;
    if (isToday) {
      return (
        label: 'TODAY',
        icon: Icons.today_rounded,
        color: AppColors.primary,
      );
    }
    return (
      label: 'UPCOMING',
      icon: Icons.schedule_rounded,
      color: AppColors.accentIndigo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessSubjects =
        subjects.where((s) => session.subjectIds.contains(s.id)).toList();
    final sessClasses =
        classes.where((c) => session.classIds.contains(c.id)).toList();
    final status = _statusChip();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Status + lock
          Row(
            children: [
              AppChip(
                label: status.label,
                icon: status.icon,
                color: status.color,
                dense: true,
              ),
              const SizedBox(width: 6),
              Icon(
                session.isLocked
                    ? Icons.lock_rounded
                    : Icons.lock_open_rounded,
                size: 14,
                color: AppColors.iconSubtle,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 2. Date + time in one grouped card
          _DateTimePanel(session: session),

          const SizedBox(height: AppSpacing.md),

          // 3. Subjects
          if (sessSubjects.isNotEmpty)
            _ChipSection(
              label: 'Subjects',
              icon: Icons.menu_book_rounded,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: sessSubjects
                    .map(
                      (s) => AppChip(
                        label: s.name,
                        icon: Icons.circle,
                        color: _parseHex(s.colorHex),
                      ),
                    )
                    .toList(),
              ),
            ),

          if (sessSubjects.isNotEmpty && sessClasses.isNotEmpty)
            const SizedBox(height: AppSpacing.sm),

          // 4. Classes
          if (sessClasses.isNotEmpty)
            _ChipSection(
              label: 'Classes',
              icon: Icons.groups_rounded,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: sessClasses
                    .map(
                      (c) => AppChip(
                        label: c.name,
                        icon: Icons.groups_rounded,
                        color: AppColors.accentIndigo,
                        dense: true,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateTimePanel extends StatelessWidget {
  const _DateTimePanel({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          _DateTimeRow(
            icon: Icons.calendar_today_rounded,
            label: DateFormat('EEE, MMM d, y').format(session.date),
          ),
          const SizedBox(height: 6),
          _DateTimeRow(
            icon: Icons.access_time_rounded,
            label: '${session.startTime} – ${session.endTime}',
          ),
        ],
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
