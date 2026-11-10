import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_top_bar.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_gate.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/exam_results_section.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/parent_progress_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_charts.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_report.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_stats.dart';

/// How the selected child is doing: figures with trends, what needs
/// attention, and a timeline of teacher feedback, grades and attendance, each
/// a step away from replying to the teacher.
class ParentProgressScreen extends StatelessWidget {
  const ParentProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Progress'),
      body: ChildGate(
        builder: (context) =>
            BlocBuilder<ParentProgressCubit, ParentProgressState>(
              builder: (context, state) => switch (state) {
                ParentProgressInitial() ||
                ParentProgressLoading() => const LoadingView(),
                ParentProgressError(:final message) => ErrorView(
                  message: message,
                  onRetry: () => context.read<ParentProgressCubit>().load(),
                ),
                ParentProgressLoaded() => _Loaded(state: state),
              },
            ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state});

  final ParentProgressLoaded state;

  Future<void> _refresh(BuildContext context) async {
    final error = await context.read<ParentProgressCubit>().refresh();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _open(BuildContext context, ReportLink link) {
    switch (link.target) {
      case LinkTarget.assignments:
        context.go(AppRoutes.parentAssignmentsPath);
      case LinkTarget.attendance:
        context.go(AppRoutes.parentAttendancePath);
      case LinkTarget.feedbackThread:
        final id = link.threadId;
        if (id != null) {
          context.pushNamed(
            AppRoutes.parentFeedbackChat,
            pathParameters: {'id': id},
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ParentProgressCubit>();
    final report = cubit.report!;
    final period = state.period;

    return RefreshIndicator(
      color: context.brand.primary,
      onRefresh: () => _refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          _ChildLine(
            name: state.child.name,
            classLabel: state.child.classLabel,
          ),
          const SizedBox(height: AppSpacing.md),
          _PeriodSelector(
            selected: period,
            onChanged: cubit.setPeriod,
          ),
          if (state.partial) ...[
            const SizedBox(height: AppSpacing.md),
            const _PartialNotice(),
          ],
          const SizedBox(height: AppSpacing.md),
          if (!report.hasAnyData && !state.hasSchoolFigures)
            const AppCard(
              child: AppEmptyState(
                icon: Icons.insights_rounded,
                title: 'Nothing to show yet',
                subtitle:
                    'Progress appears here once classes are marked and '
                    'homework is handed in.',
                compact: true,
              ),
            )
          else ...[
            if (report.hasAnyData) ...[
              _SummaryCard(report: report),
              const SizedBox(height: AppSpacing.lg),
              _AttentionSection(
                report: report,
                onOpen: (l) => _open(context, l),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TrendSection(report: report),
              if (report.subjects.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                const AppSectionTitle(
                  title: 'Homework score by subject',
                  icon: Icons.menu_book_rounded,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(child: SubjectBars(subjects: report.subjects)),
              ],
            ],
            if (state.summary?.hasData ?? false) ...[
              const SizedBox(height: AppSpacing.lg),
              OverallStrip(summary: state.summary!),
            ],
            if (state.results.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              ExamResultsList(results: state.results),
            ],
            if (report.hasAnyData) ...[
              const SizedBox(height: AppSpacing.lg),
              _TimelineSection(
                events: report.timeline,
                onOpen: (l) => _open(context, l),
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.lg),
          _MessageTeacher(onTap: () => context.go(AppRoutes.parentChatPath)),
        ],
      ),
    );
  }
}

class _ChildLine extends StatelessWidget {
  const _ChildLine({required this.name, required this.classLabel});

  final String name;
  final String classLabel;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.child_care_rounded, color: context.brand.primary, size: 20),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Text(
          classLabel.isEmpty ? name : '$name  ·  $classLabel',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.titleMedium,
        ),
      ),
    ],
  );
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});

  final ProgressPeriod selected;
  final ValueChanged<ProgressPeriod> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final p in ProgressPeriod.values) ...[
          ChoiceChip(
            label: Text(p.label),
            selected: p == selected,
            onSelected: (_) => onChanged(p),
            selectedColor: context.brand.primary,
            labelStyle: AppTextStyles.labelLarge.copyWith(
              color: p == selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            showCheckmark: false,
            side: BorderSide(
              color: p == selected ? context.brand.primary : AppColors.border,
            ),
            backgroundColor: AppColors.surface,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ],
    ),
  );
}

class _PartialNotice extends StatelessWidget {
  const _PartialNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.warningSoft,
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: AppColors.warning,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Some information could not be loaded. Pull down to retry.',
            style: AppTextStyles.labelMedium,
          ),
        ),
      ],
    ),
  );
}

// ─── Summary ──────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.report});

  final ProgressReport report;

  @override
  Widget build(BuildContext context) {
    final vs = report.period.hasPrevious
        ? 'vs previous ${report.period.label}'
        : null;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.how_to_reg_rounded,
            label: 'Attendance',
            trend: report.attendance,
            detail: (r) => '${r.part} of ${r.whole} classes attended',
            emptyText: 'No classes marked in this period',
          ),
          const Divider(height: AppSpacing.xl),
          _SummaryRow(
            icon: Icons.assignment_turned_in_rounded,
            label: 'Homework handed in',
            trend: report.homework,
            detail: (r) =>
                '${r.part} of ${r.whole} ${r.whole == 1 ? 'task' : 'tasks'} due',
            emptyText: 'No homework was due',
          ),
          const Divider(height: AppSpacing.xl),
          _SummaryRow(
            icon: Icons.grade_rounded,
            label: 'Average score',
            trend: report.score,
            detail: (r) => '${r.part} of ${r.whole} marks on graded work',
            emptyText: 'No graded work yet',
          ),
          if (vs != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Arrows compare $vs',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.trend,
    required this.detail,
    required this.emptyText,
  });

  final IconData icon;
  final String label;
  final TrendStat trend;
  final String Function(RatioStat) detail;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final percent = trend.current.percent;
    final color = bandColor(percent);
    return Semantics(
      label: percent == null
          ? '$label: $emptyText'
          : '$label $percent percent. ${detail(trend.current)}',
      excludeSemantics: true,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Text(
                  percent == null ? emptyText : detail(trend.current),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (percent != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceMuted,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                percent == null ? '—' : '$percent%',
                style: AppTextStyles.headingMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: percent == null ? AppColors.textTertiary : color,
                ),
              ),
              TrendChip(delta: trend.delta),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Attention ────────────────────────────────────────────────────────

class _AttentionSection extends StatelessWidget {
  const _AttentionSection({required this.report, required this.onOpen});

  final ProgressReport report;
  final ValueChanged<ReportLink> onOpen;

  @override
  Widget build(BuildContext context) {
    final items = report.attention;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionTitle(
          title: 'Needs attention',
          icon: Icons.flag_rounded,
          iconColor: items.isEmpty ? AppColors.success : AppColors.warning,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (items.isEmpty)
          AppCard(
            background: AppColors.successSoft,
            borderColor: AppColors.success.withValues(alpha: 0.3),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.success),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    report.pending > 0
                        ? 'All on track. ${report.pending} '
                              'homework ${report.pending == 1 ? 'task is' : 'tasks are'} '
                              'still open.'
                        : 'All on track. Nothing needs your attention.',
                    style: AppTextStyles.titleSmall,
                  ),
                ),
              ],
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _AttentionRow(
                    item: items[i],
                    onTap: () => onOpen(items[i].link),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

({IconData icon, Color color}) _attentionStyle(AttentionKind kind) =>
    switch (kind) {
      AttentionKind.overdueHomework => (
        icon: Icons.assignment_late_rounded,
        color: AppColors.danger,
      ),
      AttentionKind.absence => (
        icon: Icons.event_busy_rounded,
        color: AppColors.warning,
      ),
      AttentionKind.lowScore => (
        icon: Icons.trending_down_rounded,
        color: AppColors.danger,
      ),
      AttentionKind.newFeedback => (
        icon: Icons.mark_chat_unread_rounded,
        color: AppColors.accentIndigo,
      ),
    };

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({required this.item, required this.onTap});

  final AttentionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _attentionStyle(item.kind);
    final isFeedback = item.kind == AttentionKind.newFeedback;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(style.icon, color: style.color, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall,
                  ),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isFeedback)
              Text(
                'Reply',
                style: AppTextStyles.labelLarge.copyWith(
                  color: context.brand.primary,
                  fontWeight: FontWeight.w800,
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.iconSubtle,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Trend chart ──────────────────────────────────────────────────────

class _TrendSection extends StatefulWidget {
  const _TrendSection({required this.report});

  final ProgressReport report;

  @override
  State<_TrendSection> createState() => _TrendSectionState();
}

class _TrendSectionState extends State<_TrendSection> {
  bool _attendance = true;

  @override
  Widget build(BuildContext context) {
    final weeks = widget.report.weeks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionTitle(
          title: 'Weekly trend',
          icon: Icons.bar_chart_rounded,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: true, label: Text('Attendance')),
                  ButtonSegment(value: false, label: Text('Homework')),
                ],
                selected: {_attendance},
                onSelectionChanged: (s) =>
                    setState(() => _attendance = s.first),
              ),
              const SizedBox(height: AppSpacing.lg),
              WeeklyBars(
                starts: [for (final w in weeks) w.start],
                values: [
                  for (final w in weeks)
                    (_attendance ? w.attendance : w.homework).percent,
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                children: const [
                  LegendDot(color: AppColors.success, label: '85%+'),
                  LegendDot(color: AppColors.warning, label: '70–84%'),
                  LegendDot(color: AppColors.danger, label: 'Below 70%'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Timeline ─────────────────────────────────────────────────────────

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.events, required this.onOpen});

  final List<TimelineEvent> events;
  final ValueChanged<ReportLink> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionTitle(
          title: 'Recent activity',
          icon: Icons.history_rounded,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (events.isEmpty)
          const AppCard(
            child: AppEmptyState(
              icon: Icons.inbox_rounded,
              title: 'No recent activity',
              subtitle: 'Teacher feedback, grades and absences show up here.',
              compact: true,
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < events.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _TimelineRow(
                    event: events[i],
                    onTap: () => onOpen(events[i].link),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

({IconData icon, Color color}) _eventStyle(TimelineEvent e) {
  switch (e.kind) {
    case EventKind.feedback:
      return (
        icon: Icons.chat_bubble_rounded,
        color: e.positive == false ? AppColors.warning : AppColors.accentIndigo,
      );
    case EventKind.graded:
      return (
        icon: Icons.grade_rounded,
        color: e.positive == true
            ? AppColors.success
            : e.positive == false
            ? AppColors.danger
            : AppColors.accentOrange,
      );
    case EventKind.absent:
      return (icon: Icons.event_busy_rounded, color: AppColors.danger);
    case EventKind.late:
      return (icon: Icons.schedule_rounded, color: AppColors.warning);
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.onTap});

  final TimelineEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _eventStyle(event);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(style.icon, size: 18, color: style.color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: event.isUnread
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (event.isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: context.brand.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (event.subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        event.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _when(event.at),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (event.kind == EventKind.feedback) ...[
                        const Spacer(),
                        Text(
                          'Reply',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: context.brand.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _when(DateTime at) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    final days = today.difference(day).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return DateFormat('EEEE').format(at);
    return DateFormat('MMM d').format(at);
  }
}

class _MessageTeacher extends StatelessWidget {
  const _MessageTeacher({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    background: context.brand.primarySoft,
    borderColor: context.brand.primary.withValues(alpha: 0.25),
    child: Row(
      children: [
        Icon(Icons.forum_rounded, color: context.brand.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Talk to the teacher', style: AppTextStyles.titleSmall),
              Text(
                'Ask about progress or reply to feedback.',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: context.brand.primary),
      ],
    ),
  );
}
