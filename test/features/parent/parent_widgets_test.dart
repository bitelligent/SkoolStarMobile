import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/config/app_config.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/children_repository.dart';
import 'package:skoolstar_teacher_module/features/auth/view/role_selection_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_gate.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_switcher_header.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';

import '../../fixtures/fixtures.dart' as fx;
import '../../helpers/fakes.dart';
import '../../helpers/test_fonts.dart';

class _Children implements ChildrenRepository {
  _Children(this.items, {this.error});
  List<Child> items;
  Object? error;

  @override
  Future<List<Child>> getChildren({bool refresh = false}) async {
    if (error != null) throw error!;
    return items;
  }
}

AuthContext _ctx(Map<String, dynamic> j) => AuthContext.fromJson(j);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(loadTestFonts);

  group('RoleSelectionScreen', () {
    Future<(FakeAuthRepository, List<Uri>, GoRouter)> pump(
      WidgetTester tester, {
      required List<AuthContext> contexts,
      AuthContext? active,
      bool openSucceeds = true,
    }) async {
      final auth = FakeAuthRepository(
        context: active ?? contexts.first,
        contexts: contexts,
      );
      // Signed in with no role chosen yet.
      if (active == null) auth.signInWithoutRole(contexts);
      final opened = <Uri>[];
      final router = GoRouter(
        initialLocation: '/select-role',
        routes: [
          GoRoute(
            path: '/select-role',
            builder: (_, __) => RoleSelectionScreen(
              openUrl: (u) async {
                opened.add(u);
                return openSucceeds;
              },
            ),
          ),
          GoRoute(
            path: '/parent/home',
            builder: (_, __) => const Scaffold(body: Text('PARENT HOME')),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const Scaffold(body: Text('TEACHER HOME')),
          ),
        ],
      );
      await tester.pumpWidget(
        RepositoryProvider<AuthRepository>.value(
          value: auth,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await _settle(tester);
      return (auth, opened, router);
    }

    testWidgets('lists every role; supported ones enter their module', (
      tester,
    ) async {
      final admin = _ctx(fx.adminContext);
      final parent = _ctx(fx.parentContext);
      final (auth, opened, _) = await pump(
        tester,
        contexts: [admin, parent],
        active: null,
      );
      expect(find.text('Client Admin'), findsOneWidget);
      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('ISL AC'), findsOneWidget);
      // Grouped by where each role can be used.
      expect(find.text('AVAILABLE IN THIS APP'), findsOneWidget);
      expect(find.text('USE ON THE WEB APP'), findsOneWidget);
      expect(find.text('Web'), findsOneWidget);

      await tester.tap(find.text('Parent'));
      await _settle(tester);

      expect(auth.selected, ['Parent:8']);
      expect(find.text('PARENT HOME'), findsOneWidget);
      expect(opened, isEmpty);
    });

    testWidgets('an unsupported role opens the web app link', (tester) async {
      final (auth, opened, _) = await pump(
        tester,
        contexts: [_ctx(fx.adminContext), _ctx(fx.parentContext)],
      );
      await tester.tap(find.text('Client Admin'));
      await _settle(tester);

      expect(opened.single.toString(), AppConfig.webAppUrl);
      expect(opened.single.toString(), 'http://194.164.89.239:85');
      expect(auth.selected, isEmpty); // no token exchange for web roles
    });

    testWidgets('failing to open the link tells the user', (tester) async {
      await pump(
        tester,
        contexts: [_ctx(fx.adminContext)],
        openSucceeds: false,
      );
      await tester.tap(find.text('Client Admin'));
      await _settle(tester);
      expect(find.textContaining("Couldn't open the web app"), findsOneWidget);
    });

    testWidgets('teacher + parent: choosing teacher goes to teacher home', (
      tester,
    ) async {
      final (auth, _, _) = await pump(
        tester,
        contexts: [_ctx(fx.teacherContext), _ctx(fx.parentContext)],
        active: _ctx(fx.parentContext), // opened via Switch role
      );
      expect(find.text('Current'), findsOneWidget);
      await tester.tap(find.text('Teacher'));
      await _settle(tester);
      expect(auth.selected, ['Teacher:3']);
      expect(find.text('TEACHER HOME'), findsOneWidget);
    });

    testWidgets(
      'Switch role shows a back button and highlights the current role',
      (tester) async {
        await pump(
          tester,
          contexts: [_ctx(fx.teacherContext), _ctx(fx.parentContext)],
          active: _ctx(fx.parentContext),
        );
        expect(find.text('Switch role'), findsOneWidget); // header title
        expect(find.text('Current'), findsOneWidget);
        expect(find.byTooltip('Back'), findsOneWidget);
      },
    );

    testWidgets('only unsupported roles → web message, Sign out available', (
      tester,
    ) async {
      final (auth, _, _) = await pump(
        tester,
        contexts: [_ctx(fx.adminContext)],
        active: _ctx(fx.adminContext),
      );
      expect(find.text('USE ON THE WEB APP'), findsOneWidget);
      expect(find.text('AVAILABLE IN THIS APP'), findsNothing);
      expect(
        find.textContaining('managed on the SkoolStar web app'),
        findsOneWidget,
      );
      await tester.tap(find.text('Sign out'));
      await _settle(tester);
      expect(auth.isSignedIn, isFalse);
    });
  });

  group('child switcher + gate', () {
    Future<ChildrenCubit> pump(
      WidgetTester tester, {
      required _Children repo,
      Widget? content,
    }) async {
      final auth = FakeAuthRepository(
        context: _ctx(fx.parentContext),
      );
      final cubit = ChildrenCubit(
        repository: repo,
        store: InMemoryKeyValueStore(),
        auth: auth,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: Scaffold(
              body: Column(
                children: [
                  const ChildSwitcherHeader(),
                  Expanded(
                    child: ChildGate(
                      builder: (_) =>
                          content ?? const Center(child: Text('CONTENT')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      addTearDown(cubit.close);
      return cubit;
    }

    const irha = Child(id: '3', name: 'Irha Shahzadi', className: 'Class 2');
    const jannat = Child(
      id: '2',
      name: 'Jannat Shahzadi',
      className: 'Class 1',
    );

    testWidgets('shows the selected child and switches from the sheet', (
      tester,
    ) async {
      final cubit = await pump(tester, repo: _Children([irha, jannat]));
      expect(find.text('Irha Shahzadi'), findsOneWidget);
      expect(find.text('CONTENT'), findsOneWidget);

      await tester.tap(find.text('Irha Shahzadi'));
      await _settle(tester);
      expect(find.text('Switch child'), findsOneWidget);

      await tester.tap(find.text('Jannat Shahzadi').last);
      await _settle(tester);

      expect(cubit.state.selectedChild?.id, '2');
      expect(find.text('Jannat Shahzadi'), findsWidgets);
    });

    testWidgets('the child card spans the full width on wide screens', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(768, 1024)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pump(tester, repo: _Children([irha, jannat]));

      final card = tester.getRect(
        find
            .ancestor(
              of: find.text('Irha Shahzadi'),
              matching: find.byType(Container),
            )
            .first,
      );
      // 16px page gutter on each side; the card must use the room, not
      // shrink-wrap its content and leave a gap on the right.
      expect(card.width, greaterThan(768 - 32 - 80));
      // The chevron sits at the right edge of the card.
      final chevron = tester.getRect(
        find.byIcon(Icons.keyboard_arrow_down_rounded),
      );
      expect(card.right - chevron.right, lessThan(24));
    });

    testWidgets('a single child has no switcher sheet', (tester) async {
      await pump(tester, repo: _Children([irha]));
      await tester.tap(find.text('Irha Shahzadi'));
      await _settle(tester);
      expect(find.text('Switch child'), findsNothing);
    });

    testWidgets('no children linked → explanation instead of content', (
      tester,
    ) async {
      await pump(tester, repo: _Children([]));
      expect(find.text('No children linked yet'), findsOneWidget);
      expect(find.text('CONTENT'), findsNothing);
      expect(find.text('Check again'), findsOneWidget);
    });

    testWidgets('failure → error with retry that recovers', (tester) async {
      final repo = _Children([irha], error: StateError('x'));
      final cubit = await pump(tester, repo: repo);
      expect(find.text('Retry'), findsWidgets);

      repo.error = null;
      await tester.tap(find.text('Retry').last);
      await _settle(tester);
      expect(cubit.state, isA<ChildrenLoaded>());
      expect(find.text('CONTENT'), findsOneWidget);
    });
  });
}
