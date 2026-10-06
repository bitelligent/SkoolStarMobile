import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/feedback_chat_cubit.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/feedback_chat_state.dart';
import 'package:skoolstar_teacher_module/features/chat/widgets/feedback_topic_tile.dart';
import 'package:skoolstar_teacher_module/features/chat/widgets/new_feedback_sheet.dart';

class FeedbackChatScreen extends StatelessWidget {
  const FeedbackChatScreen({required this.threadId, super.key});

  final String threadId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedbackChatCubit(
        threadId: threadId,
        repository: context.read<ChatRepository>(),
      )..load(),
      child: const _FeedbackChatView(),
    );
  }
}

class _FeedbackChatView extends StatelessWidget {
  const _FeedbackChatView();

  Future<void> _openNewFeedback(
    BuildContext context,
    FeedbackChatLoaded state,
  ) async {
    final cubit = context.read<FeedbackChatCubit>();
    final draft =
        await showNewFeedbackSheet(context, parentName: state.thread.name);
    if (draft == null || !context.mounted) return;
    final ok = await cubit.createTopic(
      subject: draft.subject,
      tone: draft.tone,
      message: draft.message,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Feedback sent' : 'Could not send — try again'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<FeedbackChatCubit, FeedbackChatState>(
        builder: (context, state) {
          return switch (state) {
            FeedbackChatInitial() ||
            FeedbackChatLoading() =>
              const LoadingView(),
            FeedbackChatError(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<FeedbackChatCubit>().load(),
              ),
            FeedbackChatLoaded() => _Loaded(
                state: state,
                onNewFeedback: () => _openNewFeedback(context, state),
              ),
          };
        },
      ),
      ),
      floatingActionButton: BlocBuilder<FeedbackChatCubit, FeedbackChatState>(
        builder: (context, state) {
          if (state is! FeedbackChatLoaded || state.topics.isEmpty) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: state.creatingTopic
                ? null
                : () => _openNewFeedback(context, state),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 6,
            icon: state.creatingTopic
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.add_rounded),
            label: const Text(
              'New feedback',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          );
        },
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state, required this.onNewFeedback});

  final FeedbackChatLoaded state;
  final VoidCallback onNewFeedback;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FeedbackChatCubit>();
    final topics = state.topics;

    return Column(
      children: [
        _ParentHeader(thread: state.thread, topicCount: topics.length),
        Expanded(
          child: topics.isEmpty
              ? _EmptyFeedback(onCreate: onNewFeedback)
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: cubit.load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xxl + 72, // keep clear of the FAB
                    ),
                    itemCount: topics.length + 1,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      if (i == 0) return _CountRow(count: topics.length);
                      final t = topics[i - 1];
                      return FeedbackTopicTile(
                        key: ValueKey(t.id),
                        topic: t,
                        isExpanded: state.expandedTopicIds.contains(t.id),
                        isReplying: state.sendingReplyTopicId == t.id,
                        parentName: state.thread.name,
                        parentAvatarUrl: state.thread.avatarUrl,
                        onToggle: () => cubit.toggleExpanded(t.id),
                        onReply: (content) =>
                            cubit.replyToTopic(t.id, content),
                        onToggleResolved: () => cubit.toggleResolved(t.id),
                        onDelete: () => cubit.deleteTopic(t.id),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Parent header strip (back button + avatar + name + counter) ─────

class _ParentHeader extends StatelessWidget {
  const _ParentHeader({required this.thread, required this.topicCount});

  final ChatThread thread;
  final int topicCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          _BackButton(onTap: () => Navigator.of(context).maybePop()),
          const SizedBox(width: 4),
          Stack(
            clipBehavior: Clip.none,
            children: [
              AvatarCircle(
                imageUrl: thread.avatarUrl,
                name: thread.name,
                size: 46,
              ),
              if (thread.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(thread.name, style: AppTextStyles.titleMedium),
                if (thread.role.isNotEmpty)
                  Text(
                    thread.role,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$topicCount',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'feedback${topicCount == 1 ? '' : 's'}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Feedback history',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Newest first',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// Circular back button — matches the hit-target used by [AppTopBar] so
/// chat screens feel the same without the separate app bar.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }
}

// ─── Empty state (no feedbacks yet) ──────────────────────────────────

class _EmptyFeedback extends StatelessWidget {
  const _EmptyFeedback({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.reviews_outlined,
      title: 'No feedback yet',
      subtitle: 'Start a thread by sending the first feedback.',
      action: FilledButton.icon(
        onPressed: onCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New feedback'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
  }
}
