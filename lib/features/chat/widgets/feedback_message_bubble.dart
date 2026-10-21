import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/features/chat/chat_perspective.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/models/message_status.dart';

/// Single-row conversation bubble inside a feedback topic.
///
/// Teacher messages right-align with the primary tint; parent messages
/// left-align with a muted surface tint and the parent's avatar on the
/// left. Timestamps live on the opposite side of the author label so
/// alignment reads naturally for both sides.
class FeedbackMessageBubble extends StatelessWidget {
  const FeedbackMessageBubble({
    required this.message,
    required this.parentName,
    required this.parentAvatarUrl,
    this.onRetry,
    this.onDiscard,
    super.key,
  });

  final FeedbackMessage message;
  final String parentName;
  final String parentAvatarUrl;

  /// Offered on a reply that failed to send.
  final VoidCallback? onRetry;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    final isTeacher = ChatPerspectiveScope.of(context).isMine(
      fromTeacher: message.fromTeacher,
    );
    final align = isTeacher ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubble = _Bubble(message: message, isTeacher: isTeacher);
    final meta = _Meta(
      message: message,
      isTeacher: isTeacher,
      onRetry: onRetry,
      onDiscard: onDiscard,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isTeacher
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isTeacher) ...[
            AvatarCircle(
              imageUrl: parentAvatarUrl,
              name: parentName,
              size: 28,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                Opacity(
                  opacity: isTeacher && message.status == MessageStatus.sending
                      ? 0.7
                      : 1,
                  child: bubble,
                ),
                const SizedBox(height: 4),
                meta,
              ],
            ),
          ),
          if (isTeacher) const SizedBox(width: 6),
          if (isTeacher)
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.brand.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                ChatPerspectiveScope.of(context).isParent
                    ? Icons.person_rounded
                    : Icons.school_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.isTeacher});

  final FeedbackMessage message;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    final bg = isTeacher ? context.brand.primary : AppColors.surface;
    final fg = isTeacher ? Colors.white : AppColors.textPrimary;
    final border = isTeacher ? null : Border.all(color: AppColors.border);

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppRadius.lg),
      topRight: const Radius.circular(AppRadius.lg),
      bottomLeft: Radius.circular(isTeacher ? AppRadius.lg : AppRadius.xs),
      bottomRight: Radius.circular(isTeacher ? AppRadius.xs : AppRadius.lg),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: border,
      ),
      child: Text(
        message.content,
        style: AppTextStyles.bodyMedium.copyWith(color: fg, height: 1.35),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.message,
    required this.isTeacher,
    this.onRetry,
    this.onDiscard,
  });

  final FeedbackMessage message;
  final bool isTeacher;
  final VoidCallback? onRetry;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    // `isTeacher` means "sent by me" here (see ChatPerspective.isMine).
    final other = ChatPerspectiveScope.of(context).isParent
        ? 'Teacher'
        : 'Parent';
    final label = isTeacher
        ? 'You'
        : (message.senderName.isNotEmpty ? message.senderName : other);
    final time = DateFormat('MMM d, h:mm a').format(message.sentAt);

    if (isTeacher && message.status == MessageStatus.sending) {
      return Text(
        'Sending…',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textTertiary,
        ),
      );
    }
    if (isTeacher && message.status == MessageStatus.failed) {
      return Row(
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
          for (final action in [('Retry', onRetry), ('Delete', onDiscard)])
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: InkWell(
                onTap: action.$2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    action.$1,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: context.brand.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '  ·  $time',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
