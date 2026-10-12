import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';
import 'package:skoolstar_teacher_module/features/session_detail/widgets/attachment_viewer.dart';

/// Full details of one assigned homework, including tappable attachments.
Future<void> showHomeworkDetail(
  BuildContext context, {
  required Homework homework,
  required SessionDetailLoaded state,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => _HomeworkDetail(
        homework: homework,
        state: state,
        controller: controller,
        // Open from the page context so the viewer route outlives the sheet.
        openAttachment: (a) {
          Navigator.of(sheetContext).pop();
          return openHomeworkAttachment(context, a);
        },
      ),
    ),
  );
}

class _HomeworkDetail extends StatelessWidget {
  const _HomeworkDetail({
    required this.homework,
    required this.state,
    required this.controller,
    required this.openAttachment,
  });

  final Homework homework;
  final SessionDetailLoaded state;
  final ScrollController controller;
  final Future<void> Function(HomeworkAttachment) openAttachment;

  @override
  Widget build(BuildContext context) {
    final className = state.classes
        .where((c) => c.id == homework.classId)
        .map((c) => c.name)
        .firstOrNull;
    final subjectName = state.subjects
        .where((s) => s.id == homework.subjectId)
        .map((s) => s.name)
        .firstOrNull;
    final students = [
      for (final id in homework.assignedStudentIds)
        state.students
                .where((s) => s.id == id)
                .map((s) => '${s.firstName} ${s.lastName}'.trim())
                .firstOrNull ??
            'Student #$id',
    ];
    final overdue = homework.deadline.isBefore(DateTime.now());

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        Text(homework.title, style: AppTextStyles.headingSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            AppChip(
              label: homework.maxMarks == 1
                  ? '1 mark'
                  : '${homework.maxMarks} marks',
              color: AppColors.accentPurple,
              dense: true,
            ),
            if (className != null)
              AppChip(label: className, color: AppColors.primary, dense: true),
            if (subjectName != null)
              AppChip(
                label: subjectName,
                color: AppColors.accentTeal,
                dense: true,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Section(
          icon: Icons.event_rounded,
          title: 'Deadline',
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat(
                    'EEE, MMM d, y · h:mm a',
                  ).format(homework.deadline),
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              AppChip(
                label: overdue ? 'Past due' : 'Open',
                color: overdue ? AppColors.danger : AppColors.success,
                dense: true,
              ),
            ],
          ),
        ),
        _Section(
          icon: Icons.notes_rounded,
          title: 'Description',
          child: Text(
            homework.description.isEmpty
                ? 'No description provided.'
                : homework.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: homework.description.isEmpty
                  ? AppColors.textTertiary
                  : AppColors.textPrimary,
            ),
          ),
        ),
        _Section(
          icon: Icons.attach_file_rounded,
          title: 'Attachments (${homework.attachments.length})',
          child: homework.attachments.isEmpty
              ? Text(
                  'No attachments.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                )
              : Column(
                  children: [
                    for (final a in homework.attachments)
                      _AttachmentRow(
                        attachment: a,
                        onTap: () => openAttachment(a),
                      ),
                  ],
                ),
        ),
        _Section(
          icon: Icons.people_outline_rounded,
          title: 'Assigned to (${homework.studentTotal})',
          child: students.isEmpty
              ? Text(
                  homework.studentTotal > 0
                      ? '${homework.studentTotal} student(s). '
                            'Names are not provided for this task.'
                      : 'No students listed.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final name in students)
                      AppChip(
                        label: name,
                        color: AppColors.textSecondary,
                        dense: true,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.iconSubtle),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.attachment, required this.onTap});

  final HomeworkAttachment attachment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = attachment.isImage
        ? (Icons.image_rounded, AppColors.accentTeal)
        : attachment.isPdf
        ? (Icons.picture_as_pdf_rounded, AppColors.danger)
        : (Icons.description_rounded, AppColors.primary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  attachment.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              if (!attachment.hasLocation)
                Text(
                  'Unavailable',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.danger,
                  ),
                )
              else if (attachment.sizeKb > 0)
                Text(
                  '${attachment.sizeKb} KB',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              const SizedBox(width: 6),
              Icon(
                !attachment.hasLocation
                    ? Icons.link_off_rounded
                    : attachment.isImage
                    ? Icons.visibility_outlined
                    : Icons.open_in_new_rounded,
                size: 18,
                color: AppColors.iconSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
