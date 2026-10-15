import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/utils/day_filter.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_pill_tabs.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_stat_tile.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/filter_chip_row.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/month_calendar.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/session_card.dart';
import 'package:skoolstar_teacher_module/features/parent/home/parent_home_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/home/parent_home_state.dart';

/// Parent "Dashboard": the selected child's schedule with Month / Agenda
/// views and Day / Subject / Teacher filters, plus quick stats.
class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentHomeCubit, ParentHomeState>(
      builder: (context, state) => switch (state) {
        ParentHomeInitial() || ParentHomeLoading() => const LoadingView(),
        ParentHomeError(:final message) => ErrorView(
          message: message,
          onRetry: () => context.read<ParentHomeCubit>().load(),
        ),
        ParentHomeLoaded() => _Loaded(state: state),
      },
    );
  }
}

class _Loaded extends StatefulWidget {
  const _Loaded({required this.state});

  final ParentHomeLoaded state;

  @override
  State<_Loaded> createState() => _LoadedState();
}

class _LoadedState extends State<_Loaded> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs.index = widget.state.view == ParentHomeView.month ? 0 : 1;
    _tabs.addListener(_onTab);
    _search.text = widget.state.query;
  }

  void _onTab() {
    if (_tabs.indexIsChanging) return;
    final view = _tabs.index == 0
        ? ParentHomeView.month
        : ParentHomeView.agenda;
    if (widget.state.view != view) {
      context.read<ParentHomeCubit>().setView(view);
    }
  }

  @override
  void didUpdateWidget(covariant _Loaded old) {
    super.didUpdateWidget(old);
    final target = widget.state.view == ParentHomeView.month ? 0 : 1;
    if (_tabs.index != target && !_tabs.indexIsChanging) {
      _tabs.animateTo(target);
    }
    // Reset button clears the query from the cubit: mirror it in the field.
    if (_search.text != widget.state.query) _search.text = widget.state.query;
  }

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTab)
      ..dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final error = await context.read<ParentHomeCubit>().refresh();
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final cubit = context.read<ParentHomeCubit>();
    final sessions = cubit.filteredSessions();
    final live = s.sessions.where((x) => x.isLive).firstOrNull;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: ListView(
        // Always scrollable so pull-to-refresh works on short content.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          const SizedBox(height: AppSpacing.md),
          if (live != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _LiveBanner(
                session: live,
                state: s,
                onOpen: () => _open(context, live.id),
              ),
            ),
          if (live != null) const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: AppStatTile(
                    icon: Icons.event_available_rounded,
                    value: '${cubit.todayCount()}',
                    label: 'Today',
                    color: AppColors.primary,
                  ),
                ),
                if (s.pendingAssignments != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppStatTile(
                      icon: Icons.assignment_late_rounded,
                      value: '${s.pendingAssignments}',
                      label: 'Pending',
                      color: AppColors.accentOrange,
                    ),
                  ),
                ],
                if (s.presentCount != null && s.attendanceTotal != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppStatTile(
                      icon: Icons.check_circle_rounded,
                      value: '${s.presentCount}/${s.attendanceTotal}',
                      label: 'Present',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppSectionTitle(
              title: 'Schedule Overview',
              icon: Icons.event_rounded,
              trailing: _CountBadge(count: sessions.length),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppPillTabs(
              controller: _tabs,
              layout: AppPillTabsLayout.equal,
              items: const [
                AppPillTab(label: 'Month', icon: Icons.grid_view_rounded),
                AppPillTab(label: 'Agenda', icon: Icons.list_rounded),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppSearchField(
              controller: _search,
              hint: 'Search subject or teacher',
              onChanged: cubit.setQuery,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: FilterChipRow(
              classes: s.classes,
              subjects: s.subjects,
              showClasses: false,
              dayFilter: s.dayFilter,
              defaultDay: defaultDayFilter,
              selectedDate: s.selectedDate,
              classFilterIds: const {},
              subjectFilterIds: s.subjectFilterIds,
              teachers: cubit.teachers(),
              teacherFilterIds: s.teacherFilterIds,
              onDayChanged: cubit.setDayFilter,
              onClassesChanged: (_) {},
              onSubjectsChanged: cubit.setSubjectFilters,
              onTeachersChanged: cubit.setTeacherFilters,
              onReset: cubit.resetFilters,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: s.view == ParentHomeView.month
                ? AppCard(
                    child: MonthCalendar(
                      focus: s.focusDate,
                      selectedDate: s.selectedDate,
                      sessions: cubit.calendarSessions(),
                      onPrev: () => cubit.stepMonth(-1),
                      onNext: () => cubit.stepMonth(1),
                      onToday: cubit.goToToday,
                      onDayTap: cubit.focusDate,
                    ),
                  )
                : _Agenda(
                    state: s,
                    sessions: sessions,
                    onOpen: (id) => _open(context, id),
                    onClearDate: cubit.clearSelectedDate,
                  ),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, String id) => context.pushNamed(
    AppRoutes.parentSessionDetail,
    pathParameters: {'id': id},
  );
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.primarySoft,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Text(
      '$count',
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _LiveBanner extends StatelessWidget {
  const _LiveBanner({
    required this.session,
    required this.state,
    required this.onOpen,
  });

  final Session session;
  final ParentHomeLoaded state;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final subjects = state.subjects
        .where((s) => session.subjectIds.contains(s.id))
        .map((s) => s.name)
        .join(', ');
    return AppCard(
      onTap: onOpen,
      background: AppColors.successSoft,
      borderColor: AppColors.success.withValues(alpha: 0.35),
      child: Row(
        children: [
          const Icon(Icons.podcasts_rounded, color: AppColors.success),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class in progress',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subjects.isEmpty ? 'Session' : subjects,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall,
                ),
                Text(
                  '${session.startTime} – ${session.endTime}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.success),
        ],
      ),
    );
  }
}

class _Agenda extends StatelessWidget {
  const _Agenda({
    required this.state,
    required this.sessions,
    required this.onOpen,
    required this.onClearDate,
  });

  final ParentHomeLoaded state;
  final List<Session> sessions;
  final ValueChanged<String> onOpen;
  final VoidCallback onClearDate;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Session>>{};
    for (final x in sessions) {
      grouped
          .putIfAbsent(DateFormat('EEEE, MMM d').format(x.date), () => [])
          .add(x);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.selectedDate != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _DateBanner(date: state.selectedDate!, onClear: onClearDate),
          ),
        if (sessions.isEmpty)
          const AppCard(
            child: AppEmptyState(
              icon: Icons.event_busy_rounded,
              title: 'No sessions',
              subtitle: 'Try another day or change the filters.',
              compact: true,
            ),
          )
        else
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.key,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            for (final session in entry.value)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: SessionCard(
                  session: session,
                  subjects: state.subjects,
                  classes: state.classes,
                  showDate: false,
                  onTap: () => onOpen(session.id),
                ),
              ),
          ],
      ],
    );
  }
}

class _DateBanner extends StatelessWidget {
  const _DateBanner({required this.date, required this.onClear});

  final DateTime date;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_available_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing ${DateFormat('EEE, MMM d, y').format(date)}',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }
}
