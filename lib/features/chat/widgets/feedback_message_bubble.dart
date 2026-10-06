import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';

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
    super.key,
  });

  final FeedbackMessage message;
  final String parentName;
  final String parentAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final isTeacher = message.fromTeacher;
    final align = isTeacher ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubble = _Bubble(message: message, isTeacher: isTeacher);
    final meta = _Meta(message: message, isTeacher: isTeacher);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isTeacher ? MainAxisAlignment.end : MainAxisAlignment.start,
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
              children: [bubble, const SizedBox(height: 4), meta],
            ),
          ),
          if (isTeacher) const SizedBox(width: 6),
          if (isTeacher)
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded,
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
    final bg = isTeacher ? AppColors.primary : AppColors.surface;
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
  const _Meta({required this.message, required this.isTeacher});

  final FeedbackMessage message;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    final label = isTeacher ? 'You' : 'Parent';
    final time = DateFormat('MMM d, h:mm a').format(message.sentAt);
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
