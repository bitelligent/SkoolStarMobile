import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/direct_message.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/direct_chat_cubit.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/direct_chat_state.dart';
import 'package:skoolstar_teacher_module/features/chat/widgets/direct_message_bubble.dart';
import 'package:skoolstar_teacher_module/features/chat/widgets/feedback_composer.dart';

class DirectChatScreen extends StatelessWidget {
  const DirectChatScreen({required this.threadId, super.key});

  final String threadId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DirectChatCubit(
        threadId: threadId,
        repository: context.read<ChatRepository>(),
      )..load(),
      child: const _DirectChatView(),
    );
  }
}

class _DirectChatView extends StatelessWidget {
  const _DirectChatView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DirectChatCubit, DirectChatState>(
          builder: (context, state) {
            return switch (state) {
              DirectChatInitial() ||
              DirectChatLoading() =>
                const LoadingView(),
              DirectChatError(:final message) => ErrorView(
                  message: message,
                  onRetry: () => context.read<DirectChatCubit>().load(),
                ),
              DirectChatLoaded() => _Loaded(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _Loaded extends StatefulWidget {
  const _Loaded({required this.state});

  final DirectChatLoaded state;

  @override
  State<_Loaded> createState() => _LoadedState();
}

class _LoadedState extends State<_Loaded> {
  final _scroll = ScrollController();
  int _lastKnownMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _lastKnownMessageCount = widget.state.messages.length;
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToEnd());
  }

  @override
  void didUpdateWidget(covariant _Loaded old) {
    super.didUpdateWidget(old);
    final current = widget.state.messages.length;
    if (current > _lastKnownMessageCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _animateToEnd());
    }
    _lastKnownMessageCount = current;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _jumpToEnd() {
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  void _animateToEnd() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DirectChatCubit>();
    final state = widget.state;
    final items = _buildTimeline(state.messages);

    return Column(
      children: [
        _ParentHeader(thread: state.thread),
        Expanded(
          child: items.isEmpty
              ? const AppEmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No messages yet',
                  subtitle: 'Say hello to start the conversation.',
                )
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) => items[i],
                ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: 6,
            bottom: 6 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FeedbackComposer(
            hint: 'Message ${state.thread.name.split(' ').first}…',
            enabled: !state.isSending,
            onSend: cubit.send,
          ),
        ),
      ],
    );
  }

  /// Walks the sorted message list and emits `DayHeader`s between
  /// consecutive messages on different days, with each bubble flagged
  /// `showAvatar` / `showTail` based on whether the next/prev message
  /// is from the same sender (groups consecutive messages visually).
  List<Widget> _buildTimeline(List<DirectMessage> messages) {
    if (messages.isEmpty) return const [];
    final out = <Widget>[];
    final parentName = widget.state.thread.name;
    final parentAvatar = widget.state.thread.avatarUrl;
    DateTime? prevDay;

    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      final day = DateTime(m.sentAt.year, m.sentAt.month, m.sentAt.day);
      if (prevDay == null || day != prevDay) {
        out.add(DayHeader(date: m.sentAt));
        prevDay = day;
      }

      final prev = i > 0 ? messages[i - 1] : null;
      final next = i < messages.length - 1 ? messages[i + 1] : null;

      // Group messages from the same sender back-to-back (<3 min gap).
      final startsRun = prev == null ||
          prev.fromTeacher != m.fromTeacher ||
          m.sentAt.difference(prev.sentAt).inMinutes >= 3 ||
          !_isSameDay(prev.sentAt, m.sentAt);
      final endsRun = next == null ||
          next.fromTeacher != m.fromTeacher ||
          next.sentAt.difference(m.sentAt).inMinutes >= 3 ||
          !_isSameDay(next.sentAt, m.sentAt);

      out.add(
        DirectMessageBubble(
          key: ValueKey(m.id),
          message: m,
          parentName: parentName,
          parentAvatarUrl: parentAvatar,
          showAvatar: endsRun,
          showTail: endsRun,
          showMeta: endsRun,
        ),
      );

      // Decorative — not used by widget but kept so startsRun is read
      // when editing. (dart analyzer flags unused locals otherwise.)
      // ignore: unused_local_variable
      final _ = startsRun;
    }
    return out;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Parent header strip (back button + avatar + name) ───────────────

class _ParentHeader extends StatelessWidget {
  const _ParentHeader({required this.thread});

  final ChatThread thread;

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
        border: Border(bottom: BorderSide(color: AppColors.divider)),
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
                size: 44,
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
                if (thread.isOnline)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Online',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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
