import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/features/chat/widgets/feedback_composer.dart';
import 'package:skoolstar_teacher_module/features/chat/widgets/feedback_message_bubble.dart';

/// Expandable card showing one feedback topic. Collapsed: tone chip +
/// subject + collapsed-preview + relative timestamp + unread badge.
/// Expanded: full message thread + inline reply composer.
class FeedbackTopicTile extends StatelessWidget {
  const FeedbackTopicTile({
    required this.topic,
    required this.isExpanded,
    required this.isReplying,
    required this.parentName,
    required this.parentAvatarUrl,
    required this.onToggle,
    required this.onReply,
    required this.onToggleResolved,
    required this.onDelete,
    super.key,
  });

  final FeedbackTopic topic;
  final bool isExpanded;
  final bool isReplying;
  final String parentName;
  final String parentAvatarUrl;
  final VoidCallback onToggle;
  final Future<bool> Function(String content) onReply;
  final VoidCallback onToggleResolved;
  final VoidCallback onDelete;

  ({Color color, Color soft, IconData icon, String label}) _toneTheme() {
    switch (topic.tone) {
      case FeedbackTone.positive:
        return (
          color: AppColors.success,
          soft: AppColors.successSoft,
          icon: Icons.thumb_up_rounded,
          label: 'Positive',
        );
      case FeedbackTone.needsAttention:
        return (
          color: AppColors.warning,
          soft: AppColors.warningSoft,
          icon: Icons.priority_high_rounded,
          label: 'Needs attention',
        );
      case FeedbackTone.neutral:
        return (
          color: AppColors.accentIndigo,
          soft: AppColors.accentIndigoSoft,
          icon: Icons.notes_rounded,
          label: 'Note',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _toneTheme();
    final unread = topic.unreadFromParent;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: unread > 0 ? theme.color.withOpacity(0.35) : AppColors.border,
          width: unread > 0 ? 1.4 : 1,
        ),
        boxShadow: AppShadows.cardSoft,
      ),
      child: Column(
        children: [
          _Header(
            topic: topic,
            toneColor: theme.color,
            toneSoft: theme.soft,
            toneIcon: theme.icon,
            toneLabel: theme.label,
            isExpanded: isExpanded,
            unread: unread,
            onToggle: onToggle,
            onToggleResolved: onToggleResolved,
            onDelete: onDelete,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? _Body(
                    topic: topic,
                    parentName: parentName,
                    parentAvatarUrl: parentAvatarUrl,
                    isReplying: isReplying,
                    onReply: onReply,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ─── Collapsed header ─────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.topic,
    required this.toneColor,
    required this.toneSoft,
    required this.toneIcon,
    required this.toneLabel,
    required this.isExpanded,
    required this.unread,
    required this.onToggle,
    required this.onToggleResolved,
    required this.onDelete,
  });

  final FeedbackTopic topic;
  final Color toneColor;
  final Color toneSoft;
  final IconData toneIcon;
  final String toneLabel;
  final bool isExpanded;
  final int unread;
  final VoidCallback onToggle;
  final VoidCallback onToggleResolved;
  final VoidCallback onDelete;

  String _relativeTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 2) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(t);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          8,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppChip(
                  label: toneLabel,
                  icon: toneIcon,
                  color: toneColor,
                  dense: true,
                ),
                if (topic.isResolved) ...[
                  const SizedBox(width: 4),
                  const AppChip(
                    label: 'Resolved',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                    dense: true,
                  ),
                ],
                const Spacer(),
                _TopicMenu(
                  isResolved: topic.isResolved,
                  onToggleResolved: onToggleResolved,
                  onDelete: onDelete,
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 220),
                  turns: isExpanded ? 0.5 : 0,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.iconSubtle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    topic.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: toneColor,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '$unread',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (!isExpanded) ...[
              const SizedBox(height: 2),
              Text(
                topic.initialBody,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  _relativeTime(topic.lastActivityAt),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${topic.messages.length} message${topic.messages.length == 1 ? '' : 's'}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expanded body ────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.topic,
    required this.parentName,
    required this.parentAvatarUrl,
    required this.isReplying,
    required this.onReply,
  });

  final FeedbackTopic topic;
  final String parentName;
  final String parentAvatarUrl;
  final bool isReplying;
  final Future<bool> Function(String content) onReply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          ...topic.messages.map(
            (m) => FeedbackMessageBubble(
              message: m,
              parentName: parentName,
              parentAvatarUrl: parentAvatarUrl,
            ),
          ),
          const SizedBox(height: 4),
          if (topic.isResolved)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'This feedback is marked as resolved.',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            FeedbackComposer(
              onSend: onReply,
              enabled: !isReplying,
            ),
          if (isReplying) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Sending…',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TopicMenu extends StatelessWidget {
  const _TopicMenu({
    required this.isResolved,
    required this.onToggleResolved,
    required this.onDelete,
  });

  final bool isResolved;
  final VoidCallback onToggleResolved;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert_rounded,
        size: 18,
        color: AppColors.iconSubtle,
      ),
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      onSelected: (v) async {
        if (v == 'toggle') {
          onToggleResolved();
        } else if (v == 'delete') {
          final ok = await _confirmDelete(context);
          if (ok) onDelete();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                isResolved
                    ? Icons.restart_alt_rounded
                    : Icons.check_circle_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(isResolved ? 'Reopen' : 'Mark resolved'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 16,
                color: AppColors.danger,
              ),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: AppColors.danger)),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('Delete feedback?'),
        content: const Text(
          'This will remove the feedback and its reply thread. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return res ?? false;
  }
}
