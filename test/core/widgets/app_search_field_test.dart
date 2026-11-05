import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_stat_tile.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('AppSearchField', () {
    testWidgets('is a comfortable touch target', (tester) async {
      await tester.pumpWidget(
        _wrap(AppSearchField(hint: 'Search', onChanged: (_) {})),
      );
      expect(
        tester.getSize(find.byType(AppSearchField)).height,
        greaterThanOrEqualTo(AppSearchField.height),
      );
    });

    testWidgets('clear button only while there is text, and it resets', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _wrap(AppSearchField(hint: 'Search', onChanged: changes.add)),
      );
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      await tester.enterText(find.byType(TextField), 'maths');
      await tester.pump();
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(changes, ['maths', '']);
      expect(find.text('maths'), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('clears an external controller too', (tester) async {
      final controller = TextEditingController(text: 'abc');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrap(
          AppSearchField(
            hint: 'Search',
            controller: controller,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(controller.text, isEmpty);
    });
  });

  group('AppStatTile', () {
    Future<BoxDecoration> decorationOf(
      WidgetTester tester, {
      required bool selected,
    }) async {
      await tester.pumpWidget(
        _wrap(
          AppStatTile(
            icon: Icons.check,
            value: '3',
            label: 'Present',
            color: Colors.green,
            selected: selected,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final box = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      return box.decoration! as BoxDecoration;
    }

    testWidgets('selected tile is outlined in its colour', (tester) async {
      final on = await decorationOf(tester, selected: true);
      final off = await decorationOf(tester, selected: false);
      expect((on.border! as Border).top.color, Colors.green);
      expect((on.border! as Border).top.width, greaterThan(1));
      expect((off.border! as Border).top.color, isNot(Colors.green));
    });
  });

  // The tab screens sit inside the shell's Scaffold, which already shrinks for
  // the keyboard. An inner Scaffold doing it again collapsed the content.
  testWidgets('nested tab Scaffold does not apply the keyboard inset twice', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1
      ..viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetViewInsets();
    });
    final body = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const SizedBox(height: 100),
              Expanded(
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: SizedBox.expand(key: body),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const SizedBox(height: 60),
        ),
      ),
    );
    // 800 − keyboard 300 − the 100 header.
    expect(tester.getSize(find.byKey(body)).height, 400);
  });
}
