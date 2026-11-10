import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/utils/day_filter.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_pill_tabs.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_stat_tile.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/filter_chip_row.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/month_calendar.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/session_card.dart';
import 'package:skoolstar_teacher_module/features/parent/home/parent_home_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/home/parent_home_state.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_stats.dart';

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
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabs.index = widget.state.view == ParentHomeView.month ? 0 : 1;
    _tabs.addListener(_onTab);
    _search.text = widget.state.query;
    _showSearch = widget.state.query.isNotEmpty;
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
    final upcoming = cubit.upcomingSessions();

    return RefreshIndicator(
      color: context.brand.primary,
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
            child: InkWell(
              onTap: () => context.pushNamed(AppRoutes.parentProgress),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: AppSectionTitle(
                title: 'Progress',
                icon: Icons.trending_up_rounded,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Progress',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _ProgressTile(
                      icon: Icons.how_to_reg_rounded,
                      label: 'Attendance',
                      stat: s.attendanceStat,
                      onTap: () => context.goNamed(AppRoutes.parentAttendance),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _ProgressTile(
                      icon: Icons.assignment_turned_in_rounded,
                      label: 'Homework',
                      stat: s.homeworkStat,
                      onTap: () => context.goNamed(AppRoutes.parentAssignments),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _ProgressTile(
                      icon: Icons.grade_rounded,
                      label: 'Avg. score',
                      stat: s.scoreStat,
                      onTap: () => context.pushNamed(AppRoutes.parentProgress),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _UpNext(
                sessions: upcoming,
                state: s,
                onOpen: (id) => _open(context, id),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppSectionTitle(
              title: 'Schedule Overview',
              icon: Icons.event_rounded,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: _showSearch ? 'Close search' : 'Search',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      setState(() => _showSearch = !_showSearch);
                      if (!_showSearch) {
                        _search.clear();
                        cubit.setQuery('');
                      }
                    },
                    icon: Icon(
                      _showSearch ? Icons.close_rounded : Icons.search_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  _CountBadge(count: sessions.length),
                ],
              ),
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
          if (_showSearch) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppSearchField(
                controller: _search,
                hint: 'Search subject or teacher',
                autofocus: true,
                onChanged: cubit.setQuery,
              ),
            ),
          ],
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
      color: context.brand.primarySoft,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Text(
      '$count',
      style: AppTextStyles.labelMedium.copyWith(
        color: context.brand.primary,
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
                    decoration: BoxDecoration(
                      color: context.brand.primary,
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
        color: context.brand.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 16,
            color: context.brand.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing ${DateFormat('EEE, MMM d, y').format(date)}',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
                color: context.brand.primary,
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

/// One progress figure as a percentage with its name. Exact counts live on
/// the Progress screen; the home card stays glanceable.
class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.icon,
    required this.label,
    required this.stat,
    required this.onTap,
  });

  final IconData icon;
  final String label;

  /// `null` = could not be loaded; empty = nothing to measure yet.
  final RatioStat? stat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = stat?.percent;
    final color = switch (StatBand.of(percent)) {
      StatBand.good => AppColors.success,
      StatBand.fair => AppColors.warning,
      StatBand.poor => AppColors.danger,
      StatBand.none => AppColors.textTertiary,
    };
    final spoken = percent != null
        ? '$label $percent percent'
        : stat == null
        ? '$label unavailable'
        : '$label, no data yet';
    return Semantics(
      label: spoken,
      button: true,
      excludeSemantics: true,
      child: AppStatTile(
        icon: icon,
        value: percent == null ? '—' : '$percent%',
        label: label,
        color: color,
        onTap: onTap,
      ),
    );
  }
}

/// The next few classes as compact rows (the agenda below has the full
/// cards). Each row shows its time once and its day once.
class _UpNext extends StatelessWidget {
  const _UpNext({
    required this.sessions,
    required this.state,
    required this.onOpen,
  });

  final List<Session> sessions;
  final ParentHomeLoaded state;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionTitle(
          title: 'Up Coming',
          icon: Icons.upcoming_rounded,
          trailing: Text(
            sessions.length == 1
                ? 'Next class'
                : 'Next ${sessions.length} classes',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < sessions.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _UpNextRow(
                  session: sessions[i],
                  subjects: state.subjects,
                  onTap: () => onOpen(sessions[i].id),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _UpNextRow extends StatelessWidget {
  const _UpNextRow({
    required this.session,
    required this.subjects,
    required this.onTap,
  });

  final Session session;
  final List<Subject> subjects;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final names = {
      for (final s in subjects)
        if (session.subjectIds.contains(s.id)) s.name,
    }.join(', ');
    final title = names.isEmpty ? 'Class' : names;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: context.brand.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall,
                  ),
                  Text(
                    '${session.startTime} – ${session.endTime}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _StartsIn(session: session),
          ],
        ),
      ),
    );
  }
}

/// When the class is, refreshed every 30 s: "In 2 h 10 min" today, then just
/// the day. The clock time is shown once, as the row's subtitle.
class _StartsIn extends StatefulWidget {
  const _StartsIn({required this.session});

  final Session session;

  @override
  State<_StartsIn> createState() => _StartsInState();
}

class _StartsInState extends State<_StartsIn> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(
    upcomingWhenLabel(widget.session.startsAt, DateTime.now()),
    style: AppTextStyles.labelMedium.copyWith(
      color: context.brand.primary,
      fontWeight: FontWeight.w700,
    ),
  );
}

/// Short "when" for an upcoming class, without repeating its clock time:
/// "Starting now", "In 25 min", "In 3 h 15 min", "Tomorrow", "Friday",
/// "Nov 5".
String upcomingWhenLabel(DateTime start, DateTime now) {
  final diff = start.difference(now);
  if (diff.inMinutes < 1) return 'Starting now';
  if (diff.inMinutes < 60) return 'In ${diff.inMinutes} min';
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(start.year, start.month, start.day);
  final days = day.difference(today).inDays;
  if (days == 0) {
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return m == 0 ? 'In $h h' : 'In $h h $m min';
  }
  if (days == 1) return 'Tomorrow';
  if (days < 7) return DateFormat('EEEE').format(start);
  return DateFormat('MMM d').format(start);
}
