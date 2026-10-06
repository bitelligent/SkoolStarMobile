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

/// Modern session card used across Dashboard and Schedule. Shows the time
/// band in the leading column, subject chips, class chips, and a trailing
/// chevron. The whole card is tappable.
class SessionCard extends StatelessWidget {
  const SessionCard({
    required this.session,
    required this.subjects,
    required this.classes,
    required this.onTap,
    this.showDate = true,
    super.key,
  });

  final Session session;
  final List<Subject> subjects;
  final List<ClassGroup> classes;
  final VoidCallback onTap;
  final bool showDate;

  Color _parseHex(String hex) {
    final value = hex.replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final sessionSubjects =
        subjects.where((s) => session.subjectIds.contains(s.id)).toList();
    final sessionClasses =
        classes.where((c) => session.classIds.contains(c.id)).toList();
    final accent = sessionSubjects.isEmpty
        ? AppColors.primary
        : _parseHex(sessionSubjects.first.colorHex);

    return AccentCard(
      accentColor: accent,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimeColumn(
            start: session.startTime,
            end: session.endTime,
            color: accent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: sessionSubjects
                      .map(
                        (s) => AppChip(
                          label: s.name,
                          color: _parseHex(s.colorHex),
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: sessionClasses
                      .map(
                        (c) => AppChip(
                          icon: Icons.groups_rounded,
                          label: c.name,
                          color: AppColors.textSecondary,
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
                if (showDate) ...[
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEE, MMM d, y').format(session.date),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          if (session.isLive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'LIVE',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            )
          else
            Icon(
              Icons.chevron_right_rounded,
              color: accent,
            ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.start,
    required this.end,
    required this.color,
  });

  final String start;
  final String end;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TimeText(
            value: start,
            style: AppTextStyles.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            width: 1,
            height: 10,
            color: color.withOpacity(0.3),
          ),
          _TimeText(
            value: end,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps the time on a single line and scales it down to fit when the
/// container is narrower than its natural width (big text-scale,
/// wider digit fonts, longer formats like `12:34 PM`, etc.).
class _TimeText extends StatelessWidget {
  const _TimeText({required this.value, required this.style});

  final String value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(
        value,
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.visible,
        style: style,
      ),
    );
  }
}
