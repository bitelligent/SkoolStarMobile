import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/core/widgets/institute_header.dart';
import 'package:skoolstar_teacher_module/data/models/institute_model.dart';
import 'package:skoolstar_teacher_module/data/models/user_model.dart';

/// Top bar used on the main tab screens: Institute pill centered, with the
/// notification bell + teacher avatar on the right (matching the web
/// product's header layout, adapted for mobile).
class MainTopBar extends StatelessWidget {
  const MainTopBar({
    required this.institute,
    required this.user,
    required this.onNotificationsTap,
    required this.onAvatarTap,
    super.key,
  });

  final InstituteInfo institute;
  final UserModel user;
  final VoidCallback onNotificationsTap;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(child: InstitutePill(institute: institute)),
          const SizedBox(width: AppSpacing.sm),
          _BellButton(
            hasUnread: user.hasUnreadNotifications,
            onTap: onNotificationsTap,
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onAvatarTap,
            child: AvatarCircle(
              imageUrl: user.avatarUrl,
              name: '${user.firstName} ${user.lastName}',
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.hasUnread, required this.onTap});

  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          shape: BoxShape.circle,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            if (hasUnread)
              Positioned(
                top: 4,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
