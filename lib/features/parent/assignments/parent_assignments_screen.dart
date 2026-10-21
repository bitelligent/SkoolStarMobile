import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_stat_tile.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/assignment_detail_sheet.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/parent_assignments_cubit.dart';

/// Visual style of an assignment's status.
({String label, IconData icon, Color color, Color soft}) assignmentStyle(
  AssignmentStatus status,
) => switch (status) {
  AssignmentStatus.completed => (
    label: 'Completed',
    icon: Icons.check_circle_rounded,
    color: AppColors.success,
    soft: AppColors.successSoft,
  ),
  AssignmentStatus.overdue => (
    label: 'Overdue',
    icon: Icons.error_rounded,
    color: AppColors.danger,
    soft: AppColors.dangerSoft,
  ),
  AssignmentStatus.pending => (
    label: 'Pending',
    icon: Icons.pending_rounded,
    color: AppColors.accentOrange,
    soft: AppColors.accentOrangeSoft,
  ),
};

class ParentAssignmentsScreen extends StatelessWidget {
  const ParentAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentAssignmentsCubit, ParentAssignmentsState>(
      builder: (context, state) => switch (state) {
        ParentAssignmentsInitial() ||
        ParentAssignmentsLoading() => const LoadingView(),
        ParentAssignmentsError(:final message) => ErrorView(
          message: message,
          onRetry: () => context.read<ParentAssignmentsCubit>().load(),
        ),
        ParentAssignmentsLoaded() => _Loaded(state: state),
      },
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state});

  final ParentAssignmentsLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ParentAssignmentsCubit>();
    final counts = cubit.counts();
    final items = cubit.visible();

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
          Text('Assignments', style: AppTextStyles.headingMedium),
          const SizedBox(height: 2),
          Text(
            'Homework and tasks for ${state.child.name}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppStatTile(
                  icon: Icons.assignment_rounded,
                  value: '${counts.total}',
                  label: 'Total',
                  color: context.brand.primary,
                  onTap: () => cubit.setFilter(AssignmentFilter.all),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppStatTile(
                  icon: Icons.check_circle_rounded,
                  value: '${counts.completed}',
                  label: 'Completed',
                  color: AppColors.success,
                  onTap: () => cubit.setFilter(AssignmentFilter.completed),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppStatTile(
                  icon: Icons.pending_rounded,
                  value: '${counts.pending}',
                  label: 'Pending',
                  color: AppColors.accentOrange,
                  onTap: () => cubit.setFilter(AssignmentFilter.pending),
                ),
              ),
            ],
          ),
          if (state.filter != AssignmentFilter.all) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                label: Text('Showing ${state.filter.name}'),
                onDeleted: () => cubit.setFilter(state.filter),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            AppCard(
              child: AppEmptyState(
                icon: Icons.assignment_outlined,
                title: state.items.isEmpty
                    ? 'No assignments'
                    : 'Nothing matches this filter',
                subtitle: state.items.isEmpty
                    ? "Homework from teachers will appear here."
                    : 'Clear the filter to see every assignment.',
                compact: true,
              ),
            )
          else
            for (final a in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _AssignmentCard(
                  assignment: a,
                  now: cubit.now,
                  onTap: () => showAssignmentDetail(
                    context,
                    assignment: a,
                    now: cubit.now,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.assignment,
    required this.now,
    required this.onTap,
  });

  final ChildAssignment assignment;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = assignmentStyle(assignment.statusAt(now));
    final a = assignment;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: style.soft.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: style.color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    a.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppChip(
                  label: style.label,
                  icon: style.icon,
                  color: style.color,
                  dense: true,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              [
                if (a.className.isNotEmpty) a.className,
                if (a.sessionDate != null)
                  DateFormat('d MMM y').format(a.sessionDate!),
              ].join(' · '),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (a.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                a.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Pill(
                  icon: Icons.event_rounded,
                  text:
                      'Due ${DateFormat('d MMM y, h:mm a').format(a.deadline)}',
                ),
                _Pill(
                  icon: Icons.star_rounded,
                  text: a.isGraded
                      ? '${a.marks}/${a.maxMarks}'
                      : 'Out of ${a.maxMarks}',
                  highlight: a.isGraded,
                ),
              ],
            ),
            if (a.feedback != null && a.feedback!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: 16,
                    color: AppColors.iconSubtle,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      a.feedback!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text, this.highlight = false});

  final IconData icon;
  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: highlight ? AppColors.success : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: highlight ? AppColors.success : AppColors.iconSubtle,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
