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
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/filter_chip_row.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/session_card.dart';
import 'package:skoolstar_teacher_module/features/schedule/cubit/schedule_cubit.dart';
import 'package:skoolstar_teacher_module/features/schedule/cubit/schedule_state.dart';
import 'package:skoolstar_teacher_module/features/schedule/widgets/date_strip.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScheduleCubit(
        sessionRepository: context.read<SessionRepository>(),
        classRepository: context.read<ClassRepository>(),
        subjectRepository: context.read<SubjectRepository>(),
      )..load(),
      child: const _ScheduleView(),
    );
  }
}

class _ScheduleView extends StatelessWidget {
  const _ScheduleView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, state) {
            return switch (state) {
              ScheduleInitial() || ScheduleLoading() => const LoadingView(),
              ScheduleError(:final message) => ErrorView(
                  message: message,
                  onRetry: () => context.read<ScheduleCubit>().load(),
                ),
              ScheduleLoaded() => _Loaded(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state});

  final ScheduleLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();
    final items = cubit.filtered();
    final anchor = state.dateFilter ?? DateTime.now();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => cubit.load(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Schedule',
                        style: AppTextStyles.displayMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${items.length} sessions · ${DateFormat('MMMM y').format(anchor)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _TodayPill(
                  onTap: () => cubit.setDate(DateTime.now()),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DateStrip(
            anchor: anchor,
            selected: state.dateFilter,
            onSelect: cubit.setDate,
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: FilterChipRow(
              classes: state.classes,
              subjects: state.subjects,
              dayFilter: '',
              classFilterIds: state.classFilterIds,
              subjectFilterIds: state.subjectFilterIds,
              onDayChanged: (_) {},
              onClassesChanged: cubit.setClassFilters,
              onSubjectsChanged: cubit.setSubjectFilters,
              onReset: cubit.reset,
              showDay: false,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppCard(
                child: AppEmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'Nothing scheduled',
                  subtitle: state.dateFilter == null
                      ? 'No sessions match the active filters.'
                      : 'No sessions on ${DateFormat('EEE, d MMM').format(state.dateFilter!)}.',
                  compact: true,
                ),
              ),
            )
          else
            ...items.map(
              (session) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: SessionCard(
                  session: session,
                  subjects: state.subjects,
                  classes: state.classes,
                  showDate: state.dateFilter == null,
                  onTap: () => context.pushNamed(
                    AppRoutes.sessionDetail,
                    pathParameters: {'id': session.id},
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TodayPill extends StatelessWidget {
  const _TodayPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: AppShadows.glow(AppColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.today_rounded,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'Today',
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
