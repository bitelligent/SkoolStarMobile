import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_stat_tile.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_progress.dart';

/// "82" for whole scores, "78.5" otherwise.
String formatScore(num score) => score == score.roundToDouble()
    ? score.toInt().toString()
    : score.toStringAsFixed(1);

/// The school's all-time totals: homework done, exams taken, average score.
class OverallStrip extends StatelessWidget {
  const OverallStrip({required this.summary, super.key});

  final ChildProgress summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionTitle(
          title: 'Overall (all time)',
          icon: Icons.emoji_events_rounded,
        ),
        const SizedBox(height: AppSpacing.sm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AppStatTile(
                  icon: Icons.assignment_turned_in_rounded,
                  value:
                      '${summary.completedAssignments}/${summary.totalAssignments}',
                  label: 'Homework done',
                  color: AppColors.accentTeal,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppStatTile(
                  icon: Icons.quiz_rounded,
                  value: '${summary.totalResults}',
                  label: summary.totalResults == 1 ? 'Exam' : 'Exams',
                  color: context.brand.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppStatTile(
                  icon: Icons.grade_rounded,
                  value: summary.hasResults
                      ? formatScore(summary.averageScore)
                      : '—',
                  label: 'Avg. exam score',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Exam results, newest first; the latest few, with the rest on request.
class ExamResultsList extends StatefulWidget {
  const ExamResultsList({required this.results, super.key});

  final List<ExamResult> results;

  static const collapsedCount = 5;

  @override
  State<ExamResultsList> createState() => _ExamResultsListState();
}

class _ExamResultsListState extends State<ExamResultsList> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final results = widget.results;
    final shown = _all
        ? results
        : results.take(ExamResultsList.collapsedCount).toList();
    final hidden = results.length - shown.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionTitle(
          title: 'Exam results',
          icon: Icons.school_rounded,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < shown.length; i++) ...[
                if (i > 0) const Divider(height: AppSpacing.lg),
                _ResultRow(result: shown[i]),
              ],
              if (results.length > ExamResultsList.collapsedCount)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _all = !_all),
                    child: Text(_all ? 'Show fewer' : 'Show $hidden more'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result});

  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final remarks = result.remarks?.trim();
    return Semantics(
      label:
          '${result.examName}, score ${formatScore(result.score)}'
          '${remarks == null || remarks.isEmpty ? '' : '. $remarks'}',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.examName, style: AppTextStyles.titleSmall),
                if (result.createdAt != null)
                  Text(
                    DateFormat('d MMM y').format(result.createdAt!),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                if (remarks != null && remarks.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    remarks,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            formatScore(result.score),
            style: AppTextStyles.headingMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: context.brand.primary,
            ),
          ),
        ],
      ),
    );
  }
}
