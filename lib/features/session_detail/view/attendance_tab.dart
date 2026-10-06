import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_stat_tile.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_status_toggle.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_cubit.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';
import 'package:skoolstar_teacher_module/features/session_detail/widgets/session_header_card.dart';

/// Second tab — full-width attendance with 3-way pill controls per student
/// and summary tiles at the top.
class AttendanceTab extends StatelessWidget {
  const AttendanceTab({required this.state, super.key});

  final SessionDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SessionDetailCubit>();
    final students = cubit.filteredStudents();

    final filterChips = <AppChipOption>[
      const AppChipOption(id: '', label: 'All'),
      for (final c in state.classes
          .where((c) => state.session.classIds.contains(c.id)))
        AppChipOption(
          id: c.id,
          label: c.name,
          icon: Icons.groups_rounded,
          color: AppColors.accentIndigo,
        ),
    ];

    var present = 0;
    var absent = 0;
    var late = 0;
    for (final v in state.attendance.values) {
      if (v == 'present') present++;
      if (v == 'absent') absent++;
      if (v == 'late') late++;
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              SessionHeaderCard(
                session: state.session,
                classes: state.classes,
                subjects: state.subjects,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppStatTile(
                      icon: Icons.check_circle_rounded,
                      value: '$present',
                      label: 'Present',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppStatTile(
                      icon: Icons.cancel_rounded,
                      value: '$absent',
                      label: 'Absent',
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppStatTile(
                      icon: Icons.schedule_rounded,
                      value: '$late',
                      label: 'Late',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      const AppEmptyState(
                        icon: Icons.people_outline_rounded,
                        title: 'No students match',
                        compact: true,
                      )
                    else
                      ...students.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _AttendanceRow(
                            name: '${s.firstName} ${s.lastName}',
                            classGroupName: state.classes
                                .where((c) => c.id == s.classGroupId)
                                .map((c) => c.name)
                                .firstOrNull,
                            rollNo: s.rollNo,
                            status: state.attendance[s.id] ?? 'unmarked',
                            onStatus: (status) =>
                                cubit.setStatus(s.id, status),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: PrimaryButton(
            label: 'Submit Attendance',
            icon: Icons.send_rounded,
            isLoading: state.attendanceSubmitting,
            onPressed: () async {
              final ok = await cubit.submitAttendance();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Attendance submitted' : 'Failed'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.name,
    required this.rollNo,
    required this.classGroupName,
    required this.status,
    required this.onStatus,
  });

  final String name;
  final String rollNo;
  final String? classGroupName;
  final String status;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarCircle(name: name, size: 34),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 1),
                    Text(
                      [
                        if (rollNo.isNotEmpty) 'Roll $rollNo',
                        if (classGroupName != null) classGroupName!,
                      ].join(' · '),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppAttendanceToggle(value: status, onChanged: onStatus),
        ],
      ),
    );
  }
}
