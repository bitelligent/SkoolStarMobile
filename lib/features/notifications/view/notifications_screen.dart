import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_top_bar.dart';
import 'package:skoolstar_teacher_module/core/widgets/icon_tile.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/data/models/notification_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/notifications_repository.dart';

part 'notifications_screen_cubit.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          _NotificationsCubit(context.read<NotificationsRepository>())..load(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  ({IconData icon, Color color}) _styleFor(String type) {
    switch (type) {
      case 'submission':
        return (icon: Icons.assignment_turned_in_rounded, color: AppColors.success);
      case 'reminder':
        return (icon: Icons.event_rounded, color: AppColors.primary);
      case 'message':
        return (icon: Icons.chat_bubble_rounded, color: AppColors.accentPurple);
      case 'attendance':
        return (icon: Icons.rule_rounded, color: AppColors.warning);
      default:
        return (icon: Icons.notifications_rounded, color: AppColors.accentIndigo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Notifications'),
      body: BlocBuilder<_NotificationsCubit, _NState>(
        builder: (context, state) {
          if (state.data == null) return const LoadingView();
          final items = state.data!.items;
          if (items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.notifications_off_rounded,
              title: 'All caught up',
              subtitle: 'You have no notifications right now.',
            );
          }
          final unread = items.where((n) => !n.isRead).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              Row(
                children: [
                  Text(
                    unread == 0
                        ? 'No new notifications'
                        : '$unread new notification${unread == 1 ? '' : 's'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '$unread',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ...items.map((n) {
                final style = _styleFor(n.type);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _NotificationCard(
                    icon: style.icon,
                    accent: style.color,
                    item: n,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.accent,
    required this.item,
  });

  final IconData icon;
  final Color accent;
  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: item.isRead ? AppColors.surface : accent.withOpacity(0.05),
        border: Border.all(
          color: item.isRead ? AppColors.border : accent.withOpacity(0.25),
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.cardSoft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(
            icon: icon,
            background: accent.withOpacity(0.14),
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
                      child: Text(item.title, style: AppTextStyles.titleSmall),
                    ),
                    Text(
                      item.timeAgo,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!item.isRead) ...[
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          ],
        ],
      ),
    );
  }
}
