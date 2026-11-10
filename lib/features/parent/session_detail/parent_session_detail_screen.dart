import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_top_bar.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_schedule_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/assignment_detail_sheet.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/parent_assignments_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/attendance/parent_attendance_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/session_detail/parent_session_detail_cubit.dart';
import 'package:skoolstar_teacher_module/features/session_detail/widgets/session_header_card.dart';

class ParentSessionDetailScreen extends StatelessWidget {
  const ParentSessionDetailScreen({
    required this.child,
    required this.sessionId,
    super.key,
  });

  final Child child;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ParentSessionDetailCubit(
        child: child,
        sessionId: sessionId,
        schedule: ctx.read<ChildScheduleRepository>(),
        attendance: ctx.read<ChildAttendanceRepository>(),
        assignments: ctx.read<ChildAssignmentsRepository>(),
      )..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppTopBar(
          title: 'Session',
          onBack: () => context.canPop() ? context.pop() : null,
        ),
        body: BlocBuilder<ParentSessionDetailCubit, ParentSessionDetailState>(
          builder: (context, state) => switch (state) {
            ParentSessionLoading() => const LoadingView(),
            ParentSessionNotFound() => const AppEmptyState(
              icon: Icons.event_busy_rounded,
              title: 'Session not found',
              subtitle: 'It may have been removed or rescheduled.',
            ),
            ParentSessionError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<ParentSessionDetailCubit>().load(),
            ),
            ParentSessionLoaded() => _Loaded(state: state),
          },
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state});

  final ParentSessionLoaded state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final teachers = s.session.teachers;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          s.child.name,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SessionHeaderCard(
          session: s.session,
          classes: s.classes,
          subjects: s.subjects,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Attendance', style: AppTextStyles.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              _AttendanceRow(status: s.attendance?.status),
            ],
          ),
        ),
        if (teachers.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Teachers', style: AppTextStyles.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                for (final t in teachers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: AppColors.iconSubtle,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            t.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            [
                              for (final sub in s.subjects)
                                if (t.subjectIds.contains(sub.id)) sub.name,
                            ].join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Homework', style: AppTextStyles.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              if (s.assignments.isEmpty)
                Text(
                  'No homework was given in this session.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                )
              else
                for (final a in s.assignments)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      a.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      a.isGraded
                          ? '${a.marks}/${a.maxMarks}'
                          : 'Out of ${a.maxMarks}',
                    ),
                    trailing: AppChip(
                      label: assignmentStyle(a.statusAt(DateTime.now())).label,
                      color: assignmentStyle(a.statusAt(DateTime.now())).color,
                      dense: true,
                    ),
                    onTap: () => showAssignmentDetail(
                      context,
                      assignment: a,
                      now: DateTime.now(),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final style = attendanceStyle(status ?? 'unmarked');
    return Row(
      children: [
        AppChip(label: style.label, icon: style.icon, color: style.color),
        if (status == null || status == 'unmarked') ...[
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'The teacher has not marked this session yet.',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
