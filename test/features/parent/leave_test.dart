import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/parent/leave_request.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/leave_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/leave/parent_leave_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/leave/parent_leave_screen.dart';

import '../../fixtures/fixtures.dart' as fx;
import '../../helpers/fakes.dart';
import '../../helpers/test_fonts.dart';
import 'progress_fakes.dart';

LeaveRequest _req(
  String id, {
  String child = '3',
  LeaveStatus status = LeaveStatus.pending,
  String? decision,
  DateTime? start,
  DateTime? end,
}) => LeaveRequest(
  id: id,
  childId: child,
  childName: child == '3' ? 'Irha' : 'Jannat',
  startDate: start ?? DateTime(2026, 11, 4),
  endDate: end ?? DateTime(2026, 11, 6),
  durationDays: 3,
  reason: 'Family travel $id',
  status: status,
  decisionReason: decision,
  submittedAt: DateTime(2026, 11, 4, 9, 15),
);

class FakeLeaveRepo implements LeaveRepository {
  FakeLeaveRepo([List<LeaveRequest>? items]) : items = items ?? [];

  List<LeaveRequest> items;
  Object? listError;
  Object? createError;
  Object? cancelError;
  Completer<void>? gate;
  int pageCount = 1;
  final List<({String? childId, LeaveStatus? status, int page})> listCalls = [];
  final List<({DateTime start, DateTime end, String reason})> created = [];
  final List<String> cancelled = [];
  int _next = 100;

  @override
  Future<LeavePage> list({
    String? childId,
    LeaveStatus? status,
    int page = 1,
  }) async {
    listCalls.add((childId: childId, status: status, page: page));
    await gate?.future;
    if (listError != null) throw listError!;
    final rows = [
      for (final r in items)
        if ((childId == null || r.childId == childId) &&
            (status == null || r.status == status))
          r,
    ];
    return LeavePage(
      items: rows,
      pageNumber: page,
      totalCount: rows.length,
      hasNextPage: page < pageCount,
    );
  }

  @override
  Future<LeaveRequest> create({
    required String childId,
    required DateTime start,
    required DateTime end,
    required String reason,
  }) async {
    created.add((start: start, end: end, reason: reason));
    if (createError != null) throw createError!;
    final r = _req(
      '${_next++}',
      child: childId,
      start: start,
      end: end,
    ).copyWith(reason: reason);
    items = [r, ...items];
    return r;
  }

  @override
  Future<LeaveRequest> cancel(String id) async {
    cancelled.add(id);
    await gate?.future;
    if (cancelError != null) throw cancelError!;
    final updated = items
        .firstWhere((r) => r.id == id)
        .copyWith(status: LeaveStatus.cancelled);
    items = [for (final r in items) r.id == id ? updated : r];
    return updated;
  }
}

Future<ChildrenCubit> _children() async {
  final c = ChildrenCubit(
    repository: FakeKids(),
    store: InMemoryKeyValueStore(),
    auth: FakeAuthRepository(context: AuthContext.fromJson(fx.parentContext)),
  );
  await c.stream.firstWhere((s) => s is ChildrenLoaded);
  return c;
}

void main() {
  setUpAll(loadTestFonts);

  group('ParentLeaveCubit', () {
    late ChildrenCubit children;
    late FakeLeaveRepo repo;
    late ParentLeaveCubit cubit;

    ParentLeaveLoaded loaded() => cubit.state as ParentLeaveLoaded;

    setUp(() async {
      children = await _children();
      repo = FakeLeaveRepo([
        _req('1'),
        _req('2', status: LeaveStatus.approved),
        _req('3', child: '2'),
      ]);
      cubit = ParentLeaveCubit(children: children, repository: repo);
    });

    tearDown(() async {
      await cubit.close();
      await children.close();
    });

    test('loads the selected child only', () async {
      await cubit.load();
      expect(loaded().child.id, '3');
      expect(loaded().items.map((r) => r.id), ['1', '2']);
      expect(repo.listCalls.single.childId, '3');
    });

    test('a failed load is an error with the real message', () async {
      repo.listError = const NetworkException();
      await cubit.load();
      expect(cubit.state, isA<ParentLeaveError>());
    });

    test(
      'filter reloads from the server and tapping it again clears',
      () async {
        await cubit.load();
        await cubit.setFilter(LeaveStatus.approved);
        expect(repo.listCalls.last.status, LeaveStatus.approved);
        expect(loaded().items.map((r) => r.id), ['2']);
        await cubit.setFilter(LeaveStatus.approved);
        expect(loaded().filter, isNull);
        expect(loaded().items, hasLength(2));
      },
    );

    test('switching child reloads for the new one', () async {
      await cubit.load();
      await children.select(
        children.state.selectedChild == null
            ? throw StateError('none')
            : (children.state as ChildrenLoaded).children.last,
      );
      await Future<void>.delayed(Duration.zero);
      expect(repo.listCalls.last.childId, '2');
      expect(loaded().items.map((r) => r.id), ['3']);
    });

    test('a slow answer for the old child is dropped', () async {
      final gate = repo.gate = Completer<void>();
      final first = cubit.load(); // child 3, held
      await Future<void>.delayed(Duration.zero);
      repo.gate = null;
      await children.select((children.state as ChildrenLoaded).children.last);
      await Future<void>.delayed(Duration.zero);
      expect(loaded().child.id, '2');
      gate.complete();
      await first;
      expect(loaded().child.id, '2', reason: 'stale response ignored');
      expect(loaded().items.map((r) => r.id), ['3']);
    });

    test('loads the next page and does not duplicate rows', () async {
      repo.pageCount = 2;
      await cubit.load();
      expect(loaded().hasMore, isTrue);
      await cubit.loadMore();
      expect(repo.listCalls.last.page, 2);
      expect(
        loaded().items.map((r) => r.id),
        ['1', '2'],
        reason: 'same rows came back, none repeated',
      );
      expect(loaded().hasMore, isFalse);
      await cubit.loadMore(); // nothing more: no call
      expect(repo.listCalls.where((c) => c.page == 3), isEmpty);
    });

    test('a failed next page keeps the list', () async {
      repo.pageCount = 2;
      await cubit.load();
      repo.listError = const NetworkException();
      await cubit.loadMore();
      expect(loaded().items, hasLength(2));
      expect(loaded().loadingMore, isFalse);
      expect(loaded().hasMore, isTrue, reason: 'can try again');
    });

    test('submit adds the new pending request on top', () async {
      await cubit.load();
      final error = await cubit.submit(
        start: DateTime(2026, 11, 10),
        end: DateTime(2026, 11, 11),
        reason: 'Wedding',
      );
      expect(error, isNull);
      expect(loaded().items.first.reason, 'Wedding');
      expect(loaded().items.first.status, LeaveStatus.pending);
      expect(repo.created.single.reason, 'Wedding');
    });

    test('submit is not shown under a filter it does not match', () async {
      await cubit.load();
      await cubit.setFilter(LeaveStatus.approved);
      await cubit.submit(
        start: DateTime(2026, 11, 10),
        end: DateTime(2026, 11, 10),
        reason: 'x',
      );
      expect(loaded().items.map((r) => r.id), ['2']);
    });

    test('a refused request returns the server\'s reason', () async {
      await cubit.load();
      repo.createError = const ValidationException(
        'This student already has a pending or approved leave request for '
        'those dates.',
        statusCode: 400,
      );
      final error = await cubit.submit(
        start: DateTime(2026, 11, 4),
        end: DateTime(2026, 11, 4),
        reason: 'x',
      );
      expect(error, contains('already has a pending'));
      expect(loaded().items, hasLength(2), reason: 'nothing added');
    });

    test('cancel swaps the row for the cancelled copy', () async {
      await cubit.load();
      final error = await cubit.cancel('1');
      expect(error, isNull);
      expect(loaded().items.first.status, LeaveStatus.cancelled);
      expect(loaded().items.first.canCancel, isFalse);
      expect(loaded().cancelling, isEmpty);
    });

    test('cancelling under the Pending filter removes the row', () async {
      await cubit.load();
      await cubit.setFilter(LeaveStatus.pending);
      await cubit.cancel('1');
      expect(loaded().items, isEmpty);
    });

    test('cancel is guarded against a double tap', () async {
      await cubit.load();
      repo.gate = Completer<void>();
      final a = cubit.cancel('1');
      final b = cubit.cancel('1');
      expect(loaded().cancelling, {'1'});
      repo.gate!.complete();
      await Future.wait([a, b]);
      expect(repo.cancelled, ['1']);
    });

    test('a failed cancel leaves the request pending and says why', () async {
      await cubit.load();
      repo.cancelError = const ValidationException(
        'Only a pending request can be cancelled.',
        statusCode: 400,
      );
      final error = await cubit.cancel('1');
      expect(error, 'Only a pending request can be cancelled.');
      expect(loaded().items.first.status, LeaveStatus.pending);
      expect(loaded().cancelling, isEmpty);
    });

    test('refresh keeps the filter', () async {
      await cubit.load();
      await cubit.setFilter(LeaveStatus.approved);
      expect(await cubit.refresh(), isNull);
      expect(repo.listCalls.last.status, LeaveStatus.approved);
    });
  });

  group('ParentLeaveScreen', () {
    late ChildrenCubit children;
    late FakeLeaveRepo repo;
    late ParentLeaveCubit cubit;

    Future<void> pump(WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(390, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: children),
              BlocProvider.value(value: cubit),
            ],
            child: const ParentLeaveScreen(),
          ),
        ),
      );
      await tester.pump();
      await cubit.load();
      await tester.pumpAndSettle();
    }

    setUp(() async {
      children = await _children();
      repo = FakeLeaveRepo([
        _req('1'),
        _req('2', status: LeaveStatus.approved, decision: 'Enjoy the trip'),
        _req('4', status: LeaveStatus.rejected),
      ]);
      cubit = ParentLeaveCubit(children: children, repository: repo);
    });

    tearDown(() async {
      await cubit.close();
      await children.close();
    });

    testWidgets(
      'shows requests, school\'s answer, and cancel only on pending',
      (
        tester,
      ) async {
        await pump(tester);
        expect(find.text('Leave requests'), findsOneWidget);
        expect(find.text('Pending'), findsWidgets);
        expect(find.text('Family travel 1'), findsOneWidget);
        expect(find.text('School: Enjoy the trip'), findsOneWidget);
        expect(
          find.text('Cancel request'),
          findsOneWidget,
          reason: 'only the pending request offers it',
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('empty list explains itself and still offers the button', (
      tester,
    ) async {
      repo.items = [];
      await pump(tester);
      expect(find.text('No leave requests yet'), findsOneWidget);
      expect(find.text('Request leave'), findsOneWidget);
    });

    testWidgets('an empty filter says which one', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Cancelled'));
      await tester.pumpAndSettle();
      expect(find.text('No cancelled requests'), findsOneWidget);
    });

    testWidgets('cancelling asks first, and Keep does nothing', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Cancel request'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel this request?'), findsOneWidget);
      await tester.tap(find.text('Keep'));
      await tester.pumpAndSettle();
      expect(repo.cancelled, isEmpty);
    });

    testWidgets('confirming cancels and updates the card', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Cancel request'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Cancel request'),
        ),
      );
      await tester.pumpAndSettle();
      expect(repo.cancelled, ['1']);
      expect(find.text('Leave request cancelled'), findsOneWidget);
      expect(find.text('Cancelled'), findsWidgets);
      expect(find.text('Cancel request'), findsNothing);
    });

    testWidgets('the form needs a reason and shows the server\'s refusal', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('Request leave'));
      await tester.pumpAndSettle();

      PrimaryButton button() => tester.widget<PrimaryButton>(
        find.widgetWithText(PrimaryButton, 'Submit request'),
      );
      expect(button().onPressed, isNull, reason: 'reason is empty');
      expect(find.text('1 day'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(button().onPressed, isNull, reason: 'whitespace is empty');

      repo.createError = const ValidationException(
        'This student already has a pending or approved leave request for '
        'those dates.',
        statusCode: 400,
      );
      await tester.enterText(find.byType(TextField), 'Family travel');
      await tester.pump();
      expect(button().onPressed, isNotNull);
      await tester.tap(find.widgetWithText(PrimaryButton, 'Submit request'));
      await tester.pumpAndSettle();
      expect(find.textContaining('already has a pending'), findsOneWidget);
      expect(
        find.text('Submit request'),
        findsOneWidget,
        reason: 'sheet stays open so the parent can change the dates',
      );

      repo.createError = null;
      await tester.tap(find.widgetWithText(PrimaryButton, 'Submit request'));
      await tester.pumpAndSettle();
      expect(find.text('Leave request sent'), findsOneWidget);
      expect(find.text('Submit request'), findsNothing);
      expect(find.text('Family travel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow on a small phone with large text', (tester) async {
      tester.view
        ..physicalSize = const Size(320, 568)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.1)),
            child: child!,
          ),
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: children),
              BlocProvider.value(value: cubit),
            ],
            child: const ParentLeaveScreen(),
          ),
        ),
      );
      await tester.pump();
      await cubit.load();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Request leave'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('range label', () {
    test('one day, same year, across years', () {
      expect(
        _req(
          '1',
          start: DateTime(2026, 11, 4),
          end: DateTime(2026, 11, 4),
        ).copyWith(durationDays: 1).rangeLabel,
        '4 Nov 2026',
      );
      expect(_req('1').rangeLabel, '4 Nov – 6 Nov 2026');
      expect(
        _req(
          '1',
          start: DateTime(2026, 12, 30),
          end: DateTime(2027, 1, 2),
        ).rangeLabel,
        '30 Dec 2026 – 2 Jan 2027',
      );
    });
  });
}
