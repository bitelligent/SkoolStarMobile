import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_status_toggle.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/data/models/student_model.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_cubit.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';
import 'package:skoolstar_teacher_module/features/session_detail/widgets/session_header_card.dart';

/// First tab — quick learner list with inline P/A/L buttons, bulk actions,
/// Save N/M button and shortcuts to the Attendance / Feedback tabs.
class SessionTab extends StatelessWidget {
  const SessionTab({
    required this.state,
    required this.onJumpToFeedback,
    required this.onJumpToAttendance,
    super.key,
  });

  final SessionDetailLoaded state;
  final VoidCallback onJumpToFeedback;
  final VoidCallback onJumpToAttendance;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SessionDetailCubit>();
    final students = cubit.filteredStudents();
    final saved = cubit.savedCount;
    final total = state.students.length;

    final filterChips = <AppChipOption>[
      const AppChipOption(id: '', label: 'All'),
      for (final c in state.classes.where(
        (c) => state.session.classIds.contains(c.id),
      ))
        AppChipOption(
          id: c.id,
          label: c.name,
          icon: Icons.groups_rounded,
          color: AppColors.accentIndigo,
        ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SessionHeaderCard(
          session: state.session,
          classes: state.classes,
          subjects: state.subjects,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '$total learners',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: cubit.markAllPresent,
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text('All present'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: cubit.clearAttendance,
                    icon: const Icon(Icons.restart_alt_rounded, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppSearchField(
                hint: 'Search students',
                onChanged: cubit.setStudentSearch,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppChipRow(
                options: filterChips,
                selectedId: state.activeClassFilter.isEmpty
                    ? ''
                    : state.activeClassFilter,
                onSelect: (id) => cubit.setClassFilter(id ?? ''),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (students.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Center(
                    child: Text(
                      'No students match your filters.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...students.map(
                  (s) => _LearnerRow(
                    student: s,
                    status: state.attendance[s.id] ?? 'unmarked',
                    onStatus: (status) => cubit.setStatus(s.id, status),
                    onChat: () => _snack(
                      context,
                      'Chat with ${s.firstName} ${s.lastName}',
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _SaveButton(
                saved: saved,
                total: total,
                isLoading: state.attendanceSubmitting,
                onTap: () async {
                  final ok = await cubit.submitAttendance();
                  if (!context.mounted) return;
                  _snack(context, ok ? 'Attendance saved' : 'Save failed');
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _OutlineAction(
              icon: Icons.rule_rounded,
              label: 'Full view',
              onTap: onJumpToAttendance,
            ),
            const SizedBox(width: AppSpacing.sm),
            _OutlineAction(
              icon: Icons.reviews_rounded,
              label: 'Feedback',
              onTap: onJumpToFeedback,
            ),
          ],
        ),
      ],
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }
}

class _LearnerRow extends StatelessWidget {
  const _LearnerRow({
    required this.student,
    required this.status,
    required this.onStatus,
    required this.onChat,
  });

  final Student student;
  final String status;
  final ValueChanged<String> onStatus;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            AvatarCircle(
              name: '${student.firstName} ${student.lastName}',
              size: 34,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${student.firstName} ${student.lastName}',
                    style: AppTextStyles.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    status == 'unmarked'
                        ? 'Not marked yet'
                        : 'Marked ${status[0].toUpperCase()}${status.substring(1)}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AppAttendanceToggle(
              value: status,
              onChanged: onStatus,
              compact: true,
            ),
            const SizedBox(width: 4),
            InkResponse(
              onTap: onChat,
              radius: 18,
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.saved,
    required this.total,
    required this.isLoading,
    required this.onTap,
  });

  final int saved;
  final int total;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = saved > 0 && !isLoading;
    return Material(
      color: enabled ? AppColors.primary : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              else
                Icon(
                  Icons.save_rounded,
                  size: 16,
                  color: enabled ? Colors.white : AppColors.iconSubtle,
                ),
              const SizedBox(width: 6),
              Text(
                'Save  $saved/$total',
                style: AppTextStyles.titleSmall.copyWith(
                  color: enabled ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
