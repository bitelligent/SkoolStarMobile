import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/utils/time_ago.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_top_bar.dart';
import 'package:skoolstar_teacher_module/core/widgets/icon_tile.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/models/app_notification.dart';
import 'package:skoolstar_teacher_module/features/notifications/cubit/notifications_cubit.dart';
import 'package:skoolstar_teacher_module/features/notifications/notification_navigation.dart';

/// All notifications for the signed-in role. Tapping one marks it read and
/// opens what it is about.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().load();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _refresh() async {
    final error = await context.read<NotificationsCubit>().refresh();
    if (error != null && mounted) _snack(error);
  }

  Future<void> _markAll() async {
    final error = await context.read<NotificationsCubit>().markAllRead();
    if (!mounted) return;
    _snack(error ?? 'All notifications marked as read.');
  }

  Future<void> _open(AppNotification n) async {
    final cubit = context.read<NotificationsCubit>();
    if (!n.isRead) {
      final ok = await cubit.markRead(n.id);
      if (!ok && mounted) _snack('Could not mark it as read.');
    }
    if (!mounted) return;
    await openNotification(context, n);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppTopBar(title: 'Notifications'),
        body: _body(state),
      ),
    );
  }

  Widget _body(NotificationsState state) {
    final loadingFirst =
        state.items.isEmpty &&
        (state.status == NotificationsStatus.loading ||
            state.status == NotificationsStatus.idle);
    if (loadingFirst) return const LoadingView();

    if (state.items.isEmpty && state.status == NotificationsStatus.error) {
      return ErrorView(
        message: state.error ?? 'Could not load notifications.',
        onRetry: () => context.read<NotificationsCubit>().load(),
      );
    }

    if (state.items.isEmpty) {
      return RefreshIndicator(
        color: context.brand.primary,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            AppEmptyState(
              icon: Icons.notifications_off_rounded,
              title: 'All caught up',
              subtitle: 'New messages and feedback will show up here.',
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final children = <Widget>[
      if (state.unreadCount > 0) ...[
        _Summary(unread: state.unreadCount, onMarkAll: _markAll),
        const SizedBox(height: AppSpacing.sm),
      ],
    ];
    String? bucket;
    for (final n in state.items) {
      final b = dayBucket(n.createdAt, now);
      if (b != bucket) {
        bucket = b;
        children.add(_SectionLabel(b));
      }
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _NotificationCard(
            key: ValueKey('notification_${n.id}'),
            item: n,
            now: now,
            onTap: () => _open(n),
          ),
        ),
      );
    }
    children.add(
      state.hasMore
          ? Center(
              child: TextButton(
                onPressed: context.read<NotificationsCubit>().loadMore,
                child: const Text('Show older'),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: Text(
                  state.items.length >= NotificationsCubit.maxTake
                      ? 'Showing the latest ${NotificationsCubit.maxTake}'
                      : "You're up to date",
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
    );

    return RefreshIndicator(
      color: context.brand.primary,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: children,
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.unread, required this.onMarkAll});

  final int unread;
  final VoidCallback onMarkAll;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          '$unread new notification${unread == 1 ? '' : 's'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      if (unread > 0)
        TextButton(
          onPressed: onMarkAll,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Mark all read'),
        ),
    ],
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 6),
    child: Text(
      label,
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

({IconData icon, Color color}) _styleFor(
  BuildContext context,
  NotificationType type,
) => switch (type) {
  NotificationType.chat => (
    icon: Icons.chat_bubble_rounded,
    color: AppColors.accentPurple,
  ),
  NotificationType.feedback => (
    icon: Icons.rate_review_rounded,
    color: context.brand.primary,
  ),
  NotificationType.leave => (
    icon: Icons.event_busy_rounded,
    color: AppColors.accentIndigo,
  ),
  NotificationType.other => (
    icon: Icons.notifications_rounded,
    color: AppColors.accentIndigo,
  ),
};

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    super.key,
    required this.item,
    required this.now,
    required this.onTap,
  });

  final AppNotification item;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(context, item.type);
    final accent = style.color;
    final time = timeAgo(item.createdAt, now);
    return Semantics(
      button: true,
      label:
          '${item.isRead ? '' : 'Unread. '}${item.title}. ${item.body}. $time',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: item.isRead
                ? AppColors.surface
                : accent.withValues(alpha: 0.05),
            border: Border.all(
              color: item.isRead
                  ? AppColors.border
                  : accent.withValues(alpha: 0.25),
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.cardSoft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(
                icon: style.icon,
                background: accent.withValues(alpha: 0.14),
                foreground: accent,
                size: 42,
                iconSize: 20,
                radius: AppRadius.md,
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
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          time,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (item.body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!item.isRead) ...[
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
