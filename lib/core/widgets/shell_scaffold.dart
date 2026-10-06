import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_bottom_nav.dart';

/// Wraps the [StatefulNavigationShell] from go_router with the styled bottom
/// nav so each tab keeps its own navigation stack.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
