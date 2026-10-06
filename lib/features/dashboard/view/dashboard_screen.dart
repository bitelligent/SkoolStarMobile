import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_pill_tabs.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_stat_tile.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/core/widgets/main_top_bar.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/institute_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/user_repository.dart';
import 'package:skoolstar_teacher_module/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:skoolstar_teacher_module/features/dashboard/cubit/dashboard_state.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/filter_chip_row.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/live_now_banner.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/month_calendar.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/session_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(
        instituteRepository: context.read<InstituteRepository>(),
        userRepository: context.read<UserRepository>(),
        sessionRepository: context.read<SessionRepository>(),
        classRepository: context.read<ClassRepository>(),
        subjectRepository: context.read<SubjectRepository>(),
      )..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            return switch (state) {
              DashboardInitial() || DashboardLoading() => const LoadingView(),
              DashboardError(:final message) => ErrorView(
                  message: message,
                  onRetry: () => context.read<DashboardCubit>().load(),
                ),
              DashboardLoaded() => _Loaded(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _Loaded extends StatefulWidget {
  const _Loaded({required this.state});

  final DashboardLoaded state;

  @override
  State<_Loaded> createState() => _LoadedState();
}

class _LoadedState extends State<_Loaded>
    with SingleTickerProviderStateMixin {
  late final TabController _viewTabs = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    _viewTabs.index = widget.state.view == DashboardView.month ? 0 : 1;
    _viewTabs.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_viewTabs.indexIsChanging) return;
    final targetView =
        _viewTabs.index == 0 ? DashboardView.month : DashboardView.agenda;
    final cubit = context.read<DashboardCubit>();
    final currentView = widget.state.view;
    if (currentView != targetView) cubit.setView(targetView);
  }

  /// Keep the TabController in sync when the view is changed from code
  /// (e.g. tapping a day on the calendar flips us to the agenda).
  @override
  void didUpdateWidget(covariant _Loaded old) {
    super.didUpdateWidget(old);
    final targetIndex = widget.state.view == DashboardView.month ? 0 : 1;
    if (_viewTabs.index != targetIndex && !_viewTabs.indexIsChanging) {
      _viewTabs.animateTo(targetIndex);
    }
  }

  @override
  void dispose() {
    _viewTabs
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _openSession(String id) => context.pushNamed(
        AppRoutes.sessionDetail,
        pathParameters: {'id': id},
      );

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final cubit = context.read<DashboardCubit>();
    final filtered = cubit.filteredSessions();
    final todayCount = filtered
        .where((x) => _isSameDay(x.date, DateTime.now()))
        .length;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => cubit.load(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          MainTopBar(
            institute: s.institute,
            user: s.user,
            onNotificationsTap: () =>
                context.pushNamed(AppRoutes.notifications),
            onAvatarTap: () => context.goNamed(AppRoutes.profile),
          ),
          if (s.liveSession != null) ...[
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: LiveNowBanner(
                session: s.liveSession!,
                subjects: s.subjects,
                classes: s.classes,
                onOpen: () => _openSession(s.liveSession!.id),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: AppStatTile(
                    icon: Icons.event_available_rounded,
                    value: '$todayCount',
                    label: 'Today',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppStatTile(
                    icon: Icons.menu_book_rounded,
                    value: '${s.subjects.length}',
                    label: 'Subjects',
                    color: AppColors.accentPurple,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppStatTile(
                    icon: Icons.groups_rounded,
                    value: '${s.classes.length}',
                    label: 'Classes',
                    color: AppColors.accentTeal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppSectionTitle(
              title: 'Schedule Overview',
              icon: Icons.event_rounded,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${filtered.length}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppPillTabs(
              controller: _viewTabs,
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
            child: FilterChipRow(
              classes: s.classes,
              subjects: s.subjects,
              dayFilter: s.dayFilter,
              classFilterIds: s.classFilterIds,
              subjectFilterIds: s.subjectFilterIds,
              onDayChanged: cubit.setDayFilter,
              onClassesChanged: cubit.setClassFilters,
              onSubjectsChanged: cubit.setSubjectFilters,
              onReset: cubit.resetFilters,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: s.view == DashboardView.month
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
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (s.selectedDate != null)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _SelectedDateBanner(
                            date: s.selectedDate!,
                            onClear: cubit.clearSelectedDate,
                          ),
                        ),
                      _AgendaList(
                        sessions: filtered,
                        state: s,
                        onOpen: _openSession,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _AgendaList extends StatelessWidget {
  const _AgendaList({
    required this.sessions,
    required this.state,
    required this.onOpen,
  });

  final List<Session> sessions;
  final DashboardLoaded state;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const AppCard(
        child: AppEmptyState(
          icon: Icons.calendar_today_rounded,
          title: 'No sessions',
          subtitle: 'Try changing your filters or come back later.',
          compact: true,
        ),
      );
    }
    final grouped = <String, List<Session>>{};
    for (final x in sessions) {
      final key = DateFormat('EEEE, MMM d').format(x.date);
      grouped.putIfAbsent(key, () => []).add(x);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.expand((entry) {
        return [
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
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          ...entry.value.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SessionCard(
                session: session,
                subjects: state.subjects,
                classes: state.classes,
                showDate: false,
                onTap: () => onOpen(session.id),
              ),
            ),
          ),
        ];
      }).toList(),
    );
  }
}

/// Compact banner shown above the agenda list when the user has picked a
/// specific day on the calendar — makes the current filter obvious and
/// one tap away from being cleared.
class _SelectedDateBanner extends StatelessWidget {
  const _SelectedDateBanner({required this.date, required this.onClear});

  final DateTime date;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'Showing  '),
                  TextSpan(
                    text: DateFormat('EEE, MMM d, y').format(date),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Clear',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
