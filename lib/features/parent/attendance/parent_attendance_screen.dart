import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/config/attendance_status_config.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_stat_tile.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/features/parent/attendance/parent_attendance_cubit.dart';

/// Visual style of one attendance status.
({String label, IconData icon, Color color, Color soft}) attendanceStyle(
  String status,
) => switch (status) {
  AttendanceStatusConfig.present => (
    label: 'Present',
    icon: Icons.check_circle_rounded,
    color: AppColors.success,
    soft: AppColors.successSoft,
  ),
  AttendanceStatusConfig.late => (
    label: 'Late',
    icon: Icons.schedule_rounded,
    color: AppColors.warning,
    soft: AppColors.warningSoft,
  ),
  AttendanceStatusConfig.absent => (
    label: 'Absent',
    icon: Icons.cancel_rounded,
    color: AppColors.danger,
    soft: AppColors.dangerSoft,
  ),
  _ => (
    label: 'Not recorded',
    icon: Icons.help_outline_rounded,
    color: AppColors.textSecondary,
    soft: AppColors.surfaceMuted,
  ),
};

class ParentAttendanceScreen extends StatelessWidget {
  const ParentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentAttendanceCubit, ParentAttendanceState>(
      builder: (context, state) => switch (state) {
        ParentAttendanceInitial() ||
        ParentAttendanceLoading() => const LoadingView(),
        ParentAttendanceError(:final message) => ErrorView(
          message: message,
          onRetry: () => context.read<ParentAttendanceCubit>().load(),
        ),
        ParentAttendanceLoaded() => _Loaded(state: state),
      },
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state});

  final ParentAttendanceLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ParentAttendanceCubit>();
    final counts = cubit.counts();
    final records = cubit.visible();

    return RefreshIndicator(
      color: context.brand.primary,
      onRefresh: () async {
        final error = await cubit.refresh();
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error)));
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Attendance', style: AppTextStyles.headingMedium),
          const SizedBox(height: 2),
          Text(
            'Session attendance for ${state.child.name}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppStatTile(
                  icon: Icons.list_alt_rounded,
                  value: '${counts.total}',
                  label: 'Total',
                  color: context.brand.primary,
                  selected: state.filter.isEmpty,
                  onTap: () => cubit.setFilter(''),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppStatTile(
                  icon: Icons.check_circle_rounded,
                  value: '${counts.present}',
                  label: 'Present',
                  color: AppColors.success,
                  selected: state.filter == AttendanceStatusConfig.present,
                  onTap: () => cubit.setFilter(AttendanceStatusConfig.present),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppStatTile(
                  icon: Icons.schedule_rounded,
                  value: '${counts.late}',
                  label: 'Late',
                  color: AppColors.warning,
                  selected: state.filter == AttendanceStatusConfig.late,
                  onTap: () => cubit.setFilter(AttendanceStatusConfig.late),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppStatTile(
                  icon: Icons.cancel_rounded,
                  value: '${counts.absent}',
                  label: 'Absent',
                  color: AppColors.danger,
                  selected: state.filter == AttendanceStatusConfig.absent,
                  onTap: () => cubit.setFilter(AttendanceStatusConfig.absent),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (records.isEmpty)
            AppCard(
              child: AppEmptyState(
                icon: Icons.fact_check_outlined,
                title: state.records.isEmpty
                    ? 'No attendance yet'
                    : 'Nothing matches this filter',
                subtitle: state.records.isEmpty
                    ? "Attendance appears here once the teacher marks "
                          "${state.child.name}'s sessions."
                    : 'Clear the filter to see every record.',
                compact: true,
              ),
            )
          else
            for (final r in records)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _RecordCard(record: r),
              ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final ChildAttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final style = attendanceStyle(record.status);
    final time = record.startTime.isEmpty
        ? ''
        : '${record.startTime} – ${record.endTime}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: style.soft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: style.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppChip(
                label: style.label,
                icon: style.icon,
                color: style.color,
                dense: true,
              ),
              const Spacer(),
              Text(
                DateFormat('d MMM y').format(record.date),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (record.className.isNotEmpty || record.subjectName.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              [
                record.className,
                record.subjectName,
              ].where((e) => e.isNotEmpty).join(' · '),
              style: AppTextStyles.titleSmall,
            ),
          ],
          if (time.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.iconSubtle,
                ),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (record.remarks != null) ...[
            const SizedBox(height: 6),
            Text(
              record.remarks!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
