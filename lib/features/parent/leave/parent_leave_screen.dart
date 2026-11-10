import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_confirm_dialog.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_top_bar.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/models/parent/leave_request.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_gate.dart';
import 'package:skoolstar_teacher_module/features/parent/leave/leave_request_sheet.dart';
import 'package:skoolstar_teacher_module/features/parent/leave/parent_leave_cubit.dart';

/// How each status looks.
extension LeaveStatusStyle on LeaveStatus {
  Color get color => switch (this) {
    LeaveStatus.pending => AppColors.warning,
    LeaveStatus.approved => AppColors.success,
    LeaveStatus.rejected => AppColors.danger,
    LeaveStatus.cancelled || LeaveStatus.unknown => AppColors.textSecondary,
  };

  IconData get icon => switch (this) {
    LeaveStatus.pending => Icons.hourglass_top_rounded,
    LeaveStatus.approved => Icons.check_circle_rounded,
    LeaveStatus.rejected => Icons.cancel_rounded,
    LeaveStatus.cancelled => Icons.remove_circle_outline_rounded,
    LeaveStatus.unknown => Icons.help_outline_rounded,
  };
}

/// "4 Nov 2026" for one day, "4 – 6 Nov 2026" / "30 Nov – 2 Dec 2026" for a
/// range.
extension LeaveRangeLabel on LeaveRequest {
  String get rangeLabel {
    final full = DateFormat('d MMM y');
    if (isSingleDay || startDate == endDate) return full.format(startDate);
    final sameYear = startDate.year == endDate.year;
    final from = sameYear ? DateFormat('d MMM') : full;
    return '${from.format(startDate)} – ${full.format(endDate)}';
  }
}

/// Leave requests of the selected child: ask for leave, follow the answer,
/// cancel while still pending.
class ParentLeaveScreen extends StatelessWidget {
  const ParentLeaveScreen({super.key});

  Future<void> _request(BuildContext context) async {
    final cubit = context.read<ParentLeaveCubit>();
    final child = cubit.child;
    if (child == null) return;
    final sent = await showLeaveRequestSheet(
      context,
      childName: child.name,
      onSubmit: (start, end, reason) =>
          cubit.submit(start: start, end: end, reason: reason),
    );
    if (sent && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Leave request sent')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Leave requests'),
      floatingActionButton: BlocBuilder<ParentLeaveCubit, ParentLeaveState>(
        builder: (context, state) => state is ParentLeaveLoaded
            ? FloatingActionButton.extended(
                onPressed: () => _request(context),
                backgroundColor: context.brand.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Request leave',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              )
            : const SizedBox.shrink(),
      ),
      body: ChildGate(
        builder: (context) => BlocBuilder<ParentLeaveCubit, ParentLeaveState>(
          builder: (context, state) => switch (state) {
            ParentLeaveInitial() || ParentLeaveLoading() => const LoadingView(),
            ParentLeaveError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<ParentLeaveCubit>().load(),
            ),
            ParentLeaveLoaded() => _Loaded(state: state),
          },
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state});

  final ParentLeaveLoaded state;

  Future<void> _refresh(BuildContext context) async {
    final error = await context.read<ParentLeaveCubit>().refresh();
    if (error != null && context.mounted) _snack(context, error);
  }

  Future<void> _cancel(BuildContext context, LeaveRequest r) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cancel this request?',
      message:
          'Leave for ${r.childName} (${r.rangeLabel}) will be withdrawn. '
          'You can send a new request any time.',
      confirmLabel: 'Cancel request',
    );
    if (!ok || !context.mounted) return;
    final error = await context.read<ParentLeaveCubit>().cancel(r.id);
    if (context.mounted) {
      _snack(context, error ?? 'Leave request cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ParentLeaveCubit>();
    return RefreshIndicator(
      color: context.brand.primary,
      onRefresh: () => _refresh(context),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.extentAfter < 240) cubit.loadMore();
          return false;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl + 72, // keep clear of the FAB
          ),
          children: [
            Row(
              children: [
                Icon(
                  Icons.child_care_rounded,
                  color: context.brand.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    state.child.classLabel.isEmpty
                        ? state.child.name
                        : '${state.child.name}  ·  ${state.child.classLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _FilterRow(selected: state.filter, onChanged: cubit.setFilter),
            const SizedBox(height: AppSpacing.md),
            if (state.items.isEmpty)
              AppCard(
                child: AppEmptyState(
                  icon: Icons.event_busy_rounded,
                  title: state.filter == null
                      ? 'No leave requests yet'
                      : 'No ${state.filter!.label.toLowerCase()} requests',
                  subtitle: state.filter == null
                      ? 'Tap "Request leave" to ask for time off for '
                            '${state.child.name}.'
                      : 'Tap the highlighted filter to see every request.',
                  compact: true,
                ),
              )
            else
              for (final r in state.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _LeaveCard(
                    request: r,
                    cancelling: state.cancelling.contains(r.id),
                    onCancel: () => _cancel(context, r),
                  ),
                ),
            if (state.loadingMore)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
          ],
        ),
      ),
    );
  }
}

void _snack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onChanged});

  final LeaveStatus? selected;
  final ValueChanged<LeaveStatus?> onChanged;

  static const _statuses = [
    LeaveStatus.pending,
    LeaveStatus.approved,
    LeaveStatus.rejected,
    LeaveStatus.cancelled,
  ];

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      AppChip(
        label: 'All',
        selected: selected == null,
        onTap: () => onChanged(null),
      ),
      for (final s in _statuses)
        AppChip(
          label: s.label,
          icon: s.icon,
          color: s.color,
          selected: selected == s,
          onTap: () => onChanged(s),
        ),
    ],
  );
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({
    required this.request,
    required this.cancelling,
    required this.onCancel,
  });

  final LeaveRequest request;
  final bool cancelling;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final r = request;
    final decision = r.decisionReason?.trim();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppChip(
                label: r.status.label,
                icon: r.status.icon,
                color: r.status.color,
                dense: true,
              ),
              const Spacer(),
              Text(
                '${r.durationDays} ${r.durationDays == 1 ? 'day' : 'days'}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(r.rangeLabel, style: AppTextStyles.titleSmall),
          const SizedBox(height: 4),
          Text(r.reason, style: AppTextStyles.bodyMedium),
          if (decision != null && decision.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: r.status.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'School: $decision',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
          if (r.submittedAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Requested ${DateFormat('d MMM, h:mm a').format(r.submittedAt!)}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
          if (r.canCancel) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: cancelling ? null : onCancel,
                icon: cancelling
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.close_rounded, size: 16),
                label: const Text('Cancel request'),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
