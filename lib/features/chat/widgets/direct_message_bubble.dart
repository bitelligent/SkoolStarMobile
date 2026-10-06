import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/data/models/direct_message.dart';

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
    super.key,
  });

  final DirectMessage message;
  final String parentName;
  final String parentAvatarUrl;
  final bool showAvatar;
  final bool showTail;
  final bool showMeta;

  @override
  Widget build(BuildContext context) {
    final isTeacher = message.fromTeacher;

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
        color: isTeacher ? AppColors.primary : AppColors.surface,
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
                  Icons.done_all_rounded,
                  size: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: showMeta ? 8 : 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isTeacher ? MainAxisAlignment.end : MainAxisAlignment.start,
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
          Flexible(child: bubble),
        ],
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
