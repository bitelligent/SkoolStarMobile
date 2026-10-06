import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';

/// Single row inside a chat list — avatar + online dot, name + role,
/// last-message preview with an outgoing arrow when applicable, relative
/// timestamp, and a trailing unread count badge or pin indicator.
class ChatThreadTile extends StatelessWidget {
  const ChatThreadTile({
    required this.thread,
    required this.onTap,
    super.key,
  });

  final ChatThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = thread.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.cardSoft,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _AvatarWithStatus(thread: thread),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _NameAndPreview(thread: thread)),
            const SizedBox(width: AppSpacing.sm),
            _TrailingMeta(thread: thread, hasUnread: hasUnread),
          ],
        ),
      ),
    );
  }
}

class _AvatarWithStatus extends StatelessWidget {
  const _AvatarWithStatus({required this.thread});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AvatarCircle(
            imageUrl: thread.avatarUrl,
            name: thread.name,
            size: 48,
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
    );
  }
}

class _NameAndPreview extends StatelessWidget {
  const _NameAndPreview({required this.thread});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    final hasUnread = thread.unreadCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                thread.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (thread.role.isNotEmpty) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '· ${thread.role}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        _MessagePreview(thread: thread, bold: hasUnread),
      ],
    );
  }
}

class _MessagePreview extends StatelessWidget {
  const _MessagePreview({required this.thread, required this.bold});

  final ChatThread thread;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    if (thread.isTyping) {
      return Row(
        children: [
          const Icon(
            Icons.more_horiz_rounded,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            'typing…',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.success,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        if (thread.outgoingLast) ...[
          const Icon(
            Icons.done_all_rounded,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            thread.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: bold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrailingMeta extends StatelessWidget {
  const _TrailingMeta({required this.thread, required this.hasUnread});

  final ChatThread thread;
  final bool hasUnread;

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 2) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${t.day}/${t.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(thread.lastMessageAt),
          style: AppTextStyles.labelSmall.copyWith(
            color: hasUnread ? AppColors.primary : AppColors.textTertiary,
            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        if (hasUnread)
          Container(
            constraints: const BoxConstraints(minWidth: 20),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              thread.unreadCount > 99 ? '99+' : '${thread.unreadCount}',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          )
        else if (thread.isPinned)
          Icon(
            Icons.push_pin_rounded,
            size: 12,
            color: AppColors.textTertiary.withOpacity(0.9),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }
}
