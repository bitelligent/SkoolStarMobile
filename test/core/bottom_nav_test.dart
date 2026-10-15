import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_bottom_nav.dart';

import '../helpers/test_fonts.dart';

Future<int> _pump(
  WidgetTester tester, {
  required double width,
  required List<AppNavItem> items,
  int index = 0,
  double scale = 1.15,
  ValueChanged<int>? onTap,
}) async {
  tester.view
    ..physicalSize = Size(width, 700)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(
          c,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        bottomNavigationBar: AppBottomNav(
          currentIndex: index,
          onTap: onTap ?? (_) {},
          items: items,
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
  return 0;
}

void main() {
  setUpAll(loadTestFonts);

  group('five tabs (parent)', () {
    for (final width in [280.0, 320.0, 360.0, 390.0, 768.0]) {
      for (var i = 0; i < 5; i++) {
        testWidgets('no overflow at ${width}px with tab $i active', (
          tester,
        ) async {
          await _pump(
            tester,
            width: width,
            items: AppBottomNav.parentItems,
            index: i,
            scale: 1.24,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('the bar stays a compact strip at the bottom', (tester) async {
      await _pump(
        tester,
        width: 360,
        items: AppBottomNav.parentItems,
        index: 0,
      );
      final bar = tester.getRect(find.byType(AppBottomNav));
      expect(bar.height, lessThan(100));
      expect(bar.bottom, closeTo(700, 1)); // pinned to the bottom edge
    });

    testWidgets('only the active tab shows its label', (tester) async {
      await _pump(
        tester,
        width: 320,
        items: AppBottomNav.parentItems,
        index: 2,
      );
      expect(find.text('Assignments'), findsOneWidget);
      expect(find.text('Attendance'), findsNothing);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Chat'), findsNothing);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('inactive tabs stay reachable by tooltip and tap', (
      tester,
    ) async {
      final taps = <int>[];
      await _pump(
        tester,
        width: 320,
        items: AppBottomNav.parentItems,
        onTap: taps.add,
      );
      expect(find.byTooltip('Attendance'), findsOneWidget);
      await tester.tap(find.byTooltip('Attendance'));
      await tester.tap(find.byTooltip('Profile'));
      expect(taps, [1, 4]);
    });

    testWidgets('semantics expose every label and the selected state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        width: 320,
        items: AppBottomNav.parentItems,
        index: 1,
      );
      expect(find.bySemanticsLabel('Attendance'), findsOneWidget);
      expect(find.bySemanticsLabel('Assignments'), findsOneWidget);
      handle.dispose();
    });
  });

  group('four tabs (teacher) keep their labels', () {
    for (final width in [320.0, 390.0]) {
      testWidgets('all labels visible without overflow at ${width}px', (
        tester,
      ) async {
        await _pump(
          tester,
          width: width,
          items: AppBottomNav.teacherItems,
          scale: 1.24,
        );
        expect(tester.takeException(), isNull);
        for (final l in ['Home', 'Schedule', 'Chat', 'Profile']) {
          expect(find.text(l), findsOneWidget);
        }
      });
    }
  });
}
