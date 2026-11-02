import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/features/chat/chat_perspective.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_pill_tabs.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/chat_cubit.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/chat_state.dart';
import 'package:skoolstar_teacher_module/features/chat/widgets/chat_thread_tile.dart';
import 'package:skoolstar_teacher_module/features/chat/widgets/connection_banner.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(context.read<ChatRepository>())..load(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    _tabs.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    final cat = _tabs.index == 0
        ? ChatCategory.feedback
        : ChatCategory.oneToOne;
    final cubit = context.read<ChatCubit>();
    final s = cubit.state;
    if (s is ChatLoaded && s.activeTab != cat) cubit.setActiveTab(cat);
  }

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The tab shell already resizes for the keyboard; doing it again here
      // would apply the inset twice and collapse the content.
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            return switch (state) {
              ChatInitial() || ChatLoading() => const LoadingView(),
              ChatError(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<ChatCubit>().load(),
              ),
              ChatLoaded() => _Loaded(
                state: state,
                tabs: _tabs,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.state,
    required this.tabs,
  });

  final ChatLoaded state;
  final TabController tabs;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    final threads = cubit.visibleThreads();
    final totalUnread = cubit.unreadCountFor(state.activeTab);

    return Column(
      children: [
        // ── Header ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chat', style: AppTextStyles.displayMedium),
                    const SizedBox(height: 2),
                    Text(
                      totalUnread == 0
                          ? 'You\'re all caught up'
                          : '$totalUnread unread in ${state.activeTab == ChatCategory.feedback ? 'Feedback' : '1-to-1'}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (!state.isLive) const ConnectionBanner(),

        // ── Search ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppSearchField(
            hint: 'Search chats',
            onChanged: cubit.setQuery,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Pill tabs ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppPillTabs(
            controller: tabs,
            layout: AppPillTabsLayout.equal,
            items: [
              AppPillTab(
                label: _tabLabel(
                  'Feedback',
                  cubit.unreadCountFor(ChatCategory.feedback),
                ),
                icon: Icons.reviews_rounded,
              ),
              AppPillTab(
                label: _tabLabel(
                  '1 to 1',
                  cubit.unreadCountFor(ChatCategory.oneToOne),
                ),
                icon: Icons.chat_bubble_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Thread list ──────────────────────────────────────────────
        Expanded(
          child: threads.isEmpty
              ? _EmptyChats(
                  activeTab: state.activeTab,
                  isSearching: state.query.isNotEmpty,
                )
              : RefreshIndicator(
                  color: context.brand.primary,
                  onRefresh: context.read<ChatCubit>().load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    itemCount: threads.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final t = threads[i];
                      return ChatThreadTile(
                        thread: t,
                        onTap: () {
                          final perspective = ChatPerspectiveScope.of(context);
                          final route = t.category == ChatCategory.feedback
                              ? perspective.feedbackRouteName
                              : perspective.directRouteName;
                          context.pushNamed(
                            route,
                            pathParameters: {'id': t.id},
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  String _tabLabel(String base, int unread) =>
      unread == 0 ? base : '$base  •$unread';
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats({required this.activeTab, required this.isSearching});

  final ChatCategory activeTab;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return const AppEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matches',
        subtitle: 'Try a different name or keyword.',
      );
    }
    final parent = ChatPerspectiveScope.of(context).isParent;
    return AppEmptyState(
      icon: activeTab == ChatCategory.feedback
          ? Icons.reviews_outlined
          : Icons.chat_bubble_outline_rounded,
      title: activeTab == ChatCategory.feedback
          ? (parent ? 'No teacher feedback yet' : 'No parent feedback yet')
          : 'No conversations yet',
      subtitle: activeTab == ChatCategory.feedback
          ? (parent
                ? "Feedback from your child's teachers will appear here."
                : 'Feedback threads from parents will appear here.')
          : (parent
                ? 'Messages with teachers will appear here.'
                : 'Start a chat with a colleague or admin.'),
    );
  }
}
