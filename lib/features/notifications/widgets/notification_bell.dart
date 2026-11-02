import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/features/notifications/cubit/notifications_cubit.dart';
import 'package:skoolstar_teacher_module/features/notifications/notifications_context.dart';

/// The notifications bell with an unread-count badge ("99+" above 99).
class NotificationBell extends StatelessWidget {
  const NotificationBell({required this.onTap, this.size = 36, super.key});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cubit = context.notificationsOrNull;
    if (cubit == null) return _Bell(count: 0, onTap: onTap, size: size);
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      bloc: cubit,
      buildWhen: (a, b) => a.unreadCount != b.unreadCount,
      builder: (_, s) => _Bell(count: s.unreadCount, onTap: onTap, size: size),
    );
  }
}

class _Bell extends StatelessWidget {
  const _Bell({required this.count, required this.onTap, required this.size});

  final int count;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Semantics(
      button: true,
      label: count == 0 ? 'Notifications' : 'Notifications, $count unread',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  count == 0
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_rounded,
                  color: AppColors.textPrimary,
                  size: size * 0.55,
                ),
              ),
              if (count > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: AppColors.background,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
