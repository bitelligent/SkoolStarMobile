import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/features/chat/chat_perspective.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/data/models/direct_message.dart';
import 'package:skoolstar_teacher_module/data/models/message_status.dart';

/// Message bubble for the 1-to-1 parent chat.
///
/// Teacher messages are right-aligned with the primary tint; parent
/// messages are left-aligned with the parent's avatar. When several
/// consecutive messages come from the same sender, [showAvatar] /
/// [showTail] can be false to visually group them (less visual noise).
class DirectMessageBubble extends StatelessWidget {
  const DirectMessageBubble({
    required this.message,
    required this.parentName,
    required this.parentAvatarUrl,
    this.showAvatar = true,
    this.showTail = true,
    this.showMeta = true,
    this.onRetry,
    this.onDiscard,
    super.key,
  });

  final DirectMessage message;
  final String parentName;
  final String parentAvatarUrl;
  final bool showAvatar;
  final bool showTail;
  final bool showMeta;

  /// Offered on a message that failed to send.
  final VoidCallback? onRetry;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    final isTeacher = ChatPerspectiveScope.of(context).isMine(
      fromTeacher: message.fromTeacher,
    );

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppRadius.lg),
      topRight: const Radius.circular(AppRadius.lg),
      bottomLeft: Radius.circular(
        !isTeacher && showTail ? AppRadius.xs : AppRadius.lg,
      ),
      bottomRight: Radius.circular(
        isTeacher && showTail ? AppRadius.xs : AppRadius.lg,
      ),
    );

    final bubble = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      decoration: BoxDecoration(
        color: isTeacher ? context.brand.primary : AppColors.surface,
        border: isTeacher ? null : Border.all(color: AppColors.border),
        borderRadius: radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isTeacher ? Colors.white : AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('h:mm a').format(message.sentAt),
                style: AppTextStyles.labelSmall.copyWith(
                  color: isTeacher
                      ? Colors.white.withOpacity(0.78)
                      : AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
              if (isTeacher) ...[
                const SizedBox(width: 4),
                Icon(
                  switch (message.status) {
                    MessageStatus.sending => Icons.schedule_rounded,
                    MessageStatus.failed => Icons.error_outline_rounded,
                    MessageStatus.sent =>
                      message.isRead
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                  },
                  size: 12,
                  color: message.status == MessageStatus.failed
                      ? AppColors.dangerSoft
                      : Colors.white.withOpacity(message.isRead ? 1 : 0.7),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    final failed = isTeacher && message.status == MessageStatus.failed;
    final sending = isTeacher && message.status == MessageStatus.sending;

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: isTeacher
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!isTeacher)
          SizedBox(
            width: 32,
            child: showAvatar
                ? AvatarCircle(
                    imageUrl: parentAvatarUrl,
                    name: parentName,
                    size: 28,
                  )
                : null,
          ),
        if (!isTeacher) const SizedBox(width: 6),
        Flexible(
          child: Opacity(opacity: sending ? 0.7 : 1, child: bubble),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(bottom: showMeta ? 8 : 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          row,
          if (failed)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Not sent',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _InlineAction(label: 'Retry', onTap: onRetry),
                  const SizedBox(width: AppSpacing.sm),
                  _InlineAction(label: 'Delete', onTap: onDiscard),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InlineAction extends StatelessWidget {
  const _InlineAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: context.brand.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Centered day header shown between consecutive messages that fall on
/// different calendar days.
class DayHeader extends StatelessWidget {
  const DayHeader({required this.date, super.key});

  final DateTime date;

  String _label(DateTime d) {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(d);
    return DateFormat('MMM d, y').format(d);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            _label(date),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
