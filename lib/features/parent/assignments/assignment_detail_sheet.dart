import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/parent_assignments_screen.dart';

/// Full details of one assignment: description, deadline, marks and the
/// teacher's review.
Future<void> showAssignmentDetail(
  BuildContext context, {
  required ChildAssignment assignment,
  required DateTime now,
  VoidCallback? onHandIn,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => _Detail(
        assignment: assignment,
        now: now,
        controller: controller,
        onHandIn: onHandIn,
      ),
    ),
  );
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.assignment,
    required this.now,
    required this.controller,
    this.onHandIn,
  });

  final ChildAssignment assignment;
  final DateTime now;
  final ScrollController controller;
  final VoidCallback? onHandIn;

  @override
  Widget build(BuildContext context) {
    final a = assignment;
    final style = assignmentStyle(a.statusAt(now));

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        Text(a.title, style: AppTextStyles.headingSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            AppChip(
              label: style.label,
              icon: style.icon,
              color: style.color,
              dense: true,
            ),
            if (a.className.isNotEmpty)
              AppChip(
                label: a.className,
                color: context.brand.primary,
                dense: true,
              ),
            if (a.subjectName.isNotEmpty)
              AppChip(
                label: a.subjectName,
                color: AppColors.accentTeal,
                dense: true,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Row(
          icon: Icons.event_rounded,
          label: 'Deadline',
          value: DateFormat('EEE, MMM d, y · h:mm a').format(a.deadline),
        ),
        if (a.sessionDate != null)
          _Row(
            icon: Icons.class_rounded,
            label: 'Given in session',
            value: DateFormat('EEE, MMM d, y').format(a.sessionDate!),
          ),
        _Row(
          icon: Icons.star_rounded,
          label: 'Marks',
          value: a.isGraded
              ? '${a.marks} out of ${a.maxMarks}'
              : 'Out of ${a.maxMarks} (not graded yet)',
        ),
        if (a.completedAt != null)
          _Row(
            icon: Icons.check_circle_rounded,
            label: 'Completed',
            value: DateFormat('MMM d, y · h:mm a').format(a.completedAt!),
          ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Description',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          a.description.isEmpty ? 'No description provided.' : a.description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: a.description.isEmpty
                ? AppColors.textTertiary
                : AppColors.textPrimary,
          ),
        ),
        if (a.feedback != null && a.feedback!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // One server field holds the guardian's note and the
                  // teacher's review.
                  a.isGraded ? "Teacher's feedback" : 'Note',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(a.feedback!, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
        if (onHandIn != null && !a.isCompleted) ...[
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Hand in homework',
            icon: Icons.upload_file_rounded,
            onPressed: () {
              Navigator.of(context).pop();
              onHandIn!();
            },
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.iconSubtle),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
