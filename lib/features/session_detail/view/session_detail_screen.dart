import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_pill_tabs.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_top_bar.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/repositories/attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/homework_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_cubit.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';
import 'package:skoolstar_teacher_module/features/session_detail/view/attendance_tab.dart';
import 'package:skoolstar_teacher_module/features/session_detail/view/feedback_tab.dart';
import 'package:skoolstar_teacher_module/features/session_detail/view/homework_tab.dart';
import 'package:skoolstar_teacher_module/features/session_detail/view/session_tab.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SessionDetailCubit(
        sessionId: sessionId,
        sessionRepository: context.read<SessionRepository>(),
        classRepository: context.read<ClassRepository>(),
        subjectRepository: context.read<SubjectRepository>(),
        attendanceRepository: context.read<AttendanceRepository>(),
        homeworkRepository: context.read<HomeworkRepository>(),
        feedbackRepository: context.read<FeedbackRepository>(),
      )..load(),
      child: const _SessionDetailView(),
    );
  }
}

class _SessionDetailView extends StatefulWidget {
  const _SessionDetailView();

  @override
  State<_SessionDetailView> createState() => _SessionDetailViewState();
}

class _SessionDetailViewState extends State<_SessionDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Session'),
      body: BlocBuilder<SessionDetailCubit, SessionDetailState>(
        builder: (context, state) {
          return switch (state) {
            SessionDetailInitial() ||
            SessionDetailLoading() => const LoadingView(),
            SessionDetailError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<SessionDetailCubit>().load(),
            ),
            SessionDetailLoaded() => Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: AppPillTabs(
                    controller: _tabs,
                    variant: AppPillTabsVariant.dark,
                    height: 48,
                    items: const [
                      AppPillTab(
                        label: 'Session',
                        icon: Icons.podcasts_rounded,
                      ),
                      AppPillTab(
                        label: 'Attendance',
                        icon: Icons.rule_rounded,
                      ),
                      AppPillTab(
                        label: 'Homework',
                        icon: Icons.assignment_rounded,
                      ),
                      AppPillTab(
                        label: 'Feedback',
                        icon: Icons.reviews_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      SessionTab(
                        state: state,
                        onJumpToFeedback: () => _tabs.animateTo(3),
                        onJumpToAttendance: () => _tabs.animateTo(1),
                      ),
                      AttendanceTab(state: state),
                      HomeworkTab(state: state),
                      FeedbackTab(state: state),
                    ],
                  ),
                ),
              ],
            ),
          };
        },
      ),
    );
  }
}
