import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_bottom_nav.dart';
import 'package:skoolstar_teacher_module/core/widgets/back_to_home_scope.dart';
import 'package:skoolstar_teacher_module/features/notifications/widgets/notification_bell.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_gate.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_switcher_header.dart';

/// Frame of the parent module: the always-visible child switcher on top, the
/// current tab in the middle and the bottom navigation.
///
/// The switcher lives here, above the tab navigator, so it stays put while
/// moving between tabs and every tab reacts to the selected child.
class ParentShell extends StatelessWidget {
  const ParentShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    return BackToHomeScope(
      navigationShell: navigationShell,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            ChildSwitcherHeader(
              trailing: NotificationBell(
                size: 40,
                onTap: () => context.push(AppRoutes.parentNotificationsPath),
              ),
            ),
            // The header already handled the status bar: screens below it (the
            // chat screen uses its own SafeArea) must not pad for it again.
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ChildGate(builder: (_) => navigationShell),
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
          items: AppBottomNav.parentItems,
        ),
      ),
    );
  }
}
