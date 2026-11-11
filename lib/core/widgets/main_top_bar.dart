import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/core/widgets/institute_header.dart';
import 'package:skoolstar_teacher_module/data/models/institute_model.dart';
import 'package:skoolstar_teacher_module/data/models/user_model.dart';
import 'package:skoolstar_teacher_module/features/notifications/widgets/notification_bell.dart';

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
          NotificationBell(onTap: onNotificationsTap),
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
