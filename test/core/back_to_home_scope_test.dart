import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/widgets/back_to_home_scope.dart';

void main() {
  late GoRouter router;

  Future<void> pump(WidgetTester tester) async {
    GoRoute tab(String path) => GoRoute(
      path: path,
      builder: (_, __) => Text('tab $path'),
      routes: [GoRoute(path: 'child', builder: (_, __) => Text('child $path'))],
    );
    router = GoRouter(
      initialLocation: '/a',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, __, shell) => BackToHomeScope(
            navigationShell: shell,
            child: Scaffold(body: shell),
          ),
          branches: [
            StatefulShellBranch(routes: [tab('/a')]),
            StatefulShellBranch(routes: [tab('/b')]),
          ],
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('back on another tab returns to the first tab', (tester) async {
    await pump(tester);
    router.go('/b');
    await tester.pumpAndSettle();
    expect(find.text('tab /b'), findsOneWidget);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('tab /a'), findsOneWidget);
  });

  testWidgets('back on the first tab leaves the app', (tester) async {
    await pump(tester);
    expect(await tester.binding.handlePopRoute(), isFalse);
  });

  testWidgets('a page pushed inside another tab pops before switching', (
    tester,
  ) async {
    await pump(tester);
    router.go('/b/child');
    await tester.pumpAndSettle();
    expect(find.text('child /b'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('tab /b'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('tab /a'), findsOneWidget);
  });
}
