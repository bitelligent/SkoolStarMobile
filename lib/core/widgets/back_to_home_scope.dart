import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Back on any tab but the first returns to the first tab; only back on the
/// first tab leaves the app. Pages pushed inside a tab still pop first.
class BackToHomeScope extends StatelessWidget {
  const BackToHomeScope({
    required this.navigationShell,
    required this.child,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: child,
    );
  }
}
