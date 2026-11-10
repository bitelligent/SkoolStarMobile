import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/data/mappers/homework_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_model.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/homework_repository.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_cubit.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';
import 'package:skoolstar_teacher_module/features/session_detail/view/homework_tab.dart'
    show HomeworkTile;
import 'package:skoolstar_teacher_module/features/session_detail/widgets/homework_actions.dart';
import 'package:skoolstar_teacher_module/features/session_detail/widgets/homework_detail_sheet.dart';

import '../helpers/detail_harness.dart';
import '../helpers/fakes.dart';
import '../helpers/test_fonts.dart';

Homework _hw(
  String id, {
  DateTime? createdAt,
  String title = 'Algebra',
  String description = 'Do it',
  int marks = 100,
  bool locked = false,
}) => Homework(
  id: id,
  sessionId: 's1',
  classId: '23',
  subjectId: '18',
  title: title,
  description: description,
  deadline: DateTime(2030),
  maxMarks: marks,
  assignedCount: 3,
  createdAt: createdAt,
  editLocked: locked,
);

ApiClient _api(MockClient c) => ApiClient(
  baseUrl: 'https://api.test',
  httpClient: c,
  timeout: const Duration(seconds: 2),
);

void main() {
  setUpAll(loadTestFonts);

  group('Homework.canEditAt (UTC calendar day)', () {
    final created = DateTime.utc(2026, 10, 13, 18);

    test('allowed the same UTC day, even at the last second', () {
      final h = _hw('1', createdAt: created);
      expect(h.canEditAt(DateTime.utc(2026, 10, 13, 18, 1)), isTrue);
      expect(h.canEditAt(DateTime.utc(2026, 10, 13, 23, 59, 59)), isTrue);
    });

    test('not allowed from UTC midnight on', () {
      final h = _hw('1', createdAt: created);
      expect(h.canEditAt(DateTime.utc(2026, 10, 14)), isFalse);
      expect(h.canEditAt(DateTime.utc(2026, 10, 20, 12)), isFalse);
    });

    test('the day is judged in UTC, not in the phone\'s time zone', () {
      // 23:30 local on Oct 13 in UTC+5 is 18:30Z the same UTC day, but
      // 01:00 local on Oct 14 in UTC+5 is 20:00Z Oct 13: still editable.
      final h = _hw('1', createdAt: DateTime.utc(2026, 10, 13, 20));
      final localOct14 = DateTime.parse('2026-10-14T01:00:00+05:00');
      expect(h.canEditAt(localOct14), isTrue);
      final nextUtcDay = DateTime.parse('2026-10-14T05:30:00+05:00'); // 00:30Z
      expect(h.canEditAt(nextUtcDay), isFalse);
    });

    test('unknown creation time keeps Edit available (server decides)', () {
      expect(_hw('1').canEditAt(DateTime.utc(2030)), isTrue);
    });

    test('a server refusal locks it regardless of the date', () {
      final h = _hw('1', createdAt: created, locked: true);
      expect(h.canEditAt(DateTime.utc(2026, 10, 13, 19)), isFalse);
    });
  });

  group('created timestamp mapping', () {
    Homework? map(Map<String, dynamic> extra) => homeworkFromJson(
      {'id': 5, 'title': 'T', ...extra},
      sessionId: 's',
      classId: '1',
      fallbackDeadline: DateTime(2026),
    );

    test(
      'reads created with Z, with an offset, and without a zone (as UTC)',
      () {
        expect(
          map({'created': '2026-10-13T18:00:00Z'})!.createdAt,
          DateTime.utc(2026, 10, 13, 18),
        );
        expect(
          map({'created': '2026-10-13T23:00:00+05:00'})!.createdAt,
          DateTime.utc(2026, 10, 13, 18),
        );
        expect(
          map({'created': '2026-10-13T18:00:00'})!.createdAt,
          DateTime.utc(2026, 10, 13, 18),
        );
      },
    );

    test('accepts alternate keys; garbage or missing is null', () {
      expect(map({'createdAt': '2026-10-13T18:00:00Z'})!.createdAt, isNotNull);
      expect(map({'created': 'not a date'})!.createdAt, isNull);
      expect(map({})!.createdAt, isNull);
    });
  });

  group('HomeworkRepository update / delete', () {
    late List<http.Request> requests;

    HomeworkRepositoryImpl repo(
      FutureOr<http.Response> Function(http.Request) h,
    ) {
      requests = [];
      return HomeworkRepositoryImpl(
        _api(
          MockClient((r) async {
            requests.add(r);
            return h(r);
          }),
        ),
      );
    }

    test('PUT sends only title, trimmed description and maxMarks', () async {
      final r = repo(
        (_) => jsonResponse({'message': 'Homework updated successfully.'}),
      );
      await r.update(
        '42',
        title: '  Algebra worksheet ',
        description: ' Complete questions 1-10. ',
        maxMarks: 50,
      );
      final req = requests.single;
      expect(req.method, 'PUT');
      expect(req.url.path, '/api/TeacherModule/homework/42');
      expect(jsonDecode(req.body), {
        'title': 'Algebra worksheet',
        'description': 'Complete questions 1-10.',
        'maxMarks': 50,
      });
      expect(req.headers['Content-Type'], 'application/json');
    });

    test('maxMarks is omitted when null or not above zero', () async {
      final r = repo((_) => jsonResponse({}));
      await r.update('1', title: 'T', description: '');
      await r.update('1', title: 'T', description: '', maxMarks: 0);
      for (final req in requests) {
        expect((jsonDecode(req.body) as Map).containsKey('maxMarks'), isFalse);
      }
    });

    test('an empty title never reaches the network', () async {
      final r = repo((_) => jsonResponse({}));
      await expectLater(
        r.update('1', title: '   ', description: 'x'),
        throwsA(isA<ValidationException>()),
      );
      expect(requests, isEmpty);
    });

    test('DELETE hits the id with no body', () async {
      final r = repo(
        (_) => jsonResponse({'message': 'Homework deleted successfully.'}),
      );
      await r.delete('42');
      expect(requests.single.method, 'DELETE');
      expect(requests.single.url.path, '/api/TeacherModule/homework/42');
      expect(requests.single.body, isEmpty);
    });

    test(
      'maps 400 / 404 / 401 / 500 to typed errors with the server text',
      () async {
        Future<Object?> run(int status, String message) async {
          final r = repo((_) => jsonResponse({'message': message}, status));
          try {
            await r.update('1', title: 'T', description: '');
          } on ApiException catch (e) {
            return e;
          }
          return null;
        }

        final closed = await run(
          400,
          'Homework can only be edited till the end of the day it was assigned.',
        );
        expect(closed, isA<ValidationException>());
        expect(
          (closed! as ApiException).message,
          contains('can only be edited'),
        );
        expect(
          await run(404, 'Homework assignment not found.'),
          isA<NotFoundException>(),
        );
        expect(await run(401, ''), isA<UnauthorizedException>());
        expect(await run(500, ''), isA<ServerException>());
      },
    );

    test('offline and timeouts surface as network errors', () async {
      final offline = HomeworkRepositoryImpl(
        _api(MockClient((_) async => throw const SocketException('x'))),
      );
      await expectLater(
        offline.delete('1'),
        throwsA(isA<NetworkException>()),
      );
      final slow = HomeworkRepositoryImpl(
        ApiClient(
          baseUrl: 'https://api.test',
          httpClient: MockClient((_) => Completer<http.Response>().future),
          timeout: const Duration(milliseconds: 30),
        ),
      );
      await expectLater(
        slow.update('1', title: 'T', description: ''),
        throwsA(isA<ApiTimeoutException>()),
      );
    });
  });

  group('SessionDetailCubit edit / delete', () {
    late RecordingHomeworkRepo repo;
    late SessionDetailCubit cubit;

    Future<SessionDetailCubit> make({List<Homework>? homeworks}) async {
      repo = RecordingHomeworkRepo(
        homeworks ?? [_hw('1'), _hw('2', title: 'Other')],
      );
      return buildDetailCubit(repo);
    }

    List<Homework> items() => (cubit.state as SessionDetailLoaded).homeworks;

    tearDown(() => cubit.close());

    test('edit updates the item in place', () async {
      cubit = await make();
      final out = await cubit.updateHomework(
        '1',
        title: '  New title ',
        description: ' New text ',
        maxMarks: 40,
      );
      expect(out.ok, isTrue);
      final h = items().firstWhere((x) => x.id == '1');
      expect(
        (h.title, h.description, h.maxMarks),
        ('New title', 'New text', 40),
      );
      expect(items().firstWhere((x) => x.id == '2').title, 'Other');
    });

    test('maxMarks 0/null leaves the current marks', () async {
      cubit = await make();
      await cubit.updateHomework('1', title: 'T', description: '', maxMarks: 0);
      expect(items().first.maxMarks, 100);
    });

    test('edit window closed → locked, with the server message', () async {
      cubit = await make();
      repo.updateError = const ValidationException(
        'Homework can only be edited till the end of the day it was assigned.',
        statusCode: 400,
      );
      final out = await cubit.updateHomework('1', title: 'T', description: '');
      expect(out.result, HomeworkActionResult.editWindowClosed);
      expect(out.message, contains('can only be edited'));
      expect(items().first.editLocked, isTrue);
      expect(items().first.canEditAt(DateTime.now()), isFalse);
      expect(items().first.title, 'Algebra'); // unchanged
    });

    test('other 400s are plain failures and do not lock', () async {
      cubit = await make();
      repo.updateError = const ValidationException(
        'Homework title is required.',
        statusCode: 400,
      );
      final out = await cubit.updateHomework('1', title: 'T', description: '');
      expect(out.result, HomeworkActionResult.failed);
      expect(out.message, 'Homework title is required.');
      expect(items().first.editLocked, isFalse);
    });

    test('edit of a homework deleted elsewhere removes it (404)', () async {
      cubit = await make();
      repo.updateError = const NotFoundException();
      final out = await cubit.updateHomework('1', title: 'T', description: '');
      expect(out.result, HomeworkActionResult.notFound);
      expect(items().map((h) => h.id), ['2']);
    });

    test(
      'network failure keeps the item and the typed text is not lost',
      () async {
        cubit = await make();
        repo.updateError = const NetworkException();
        final out = await cubit.updateHomework(
          '1',
          title: 'T',
          description: '',
        );
        expect(out.result, HomeworkActionResult.failed);
        expect(out.message, contains('internet'));
        expect(items().first.title, 'Algebra');
        // And it works again afterwards.
        repo.updateError = null;
        expect(
          (await cubit.updateHomework('1', title: 'T2', description: '')).ok,
          isTrue,
        );
      },
    );

    test('a second tap while the first request runs is ignored', () async {
      cubit = await make();
      repo.updateGate = Completer<void>();
      final first = cubit.updateHomework('1', title: 'A', description: '');
      final second = await cubit.updateHomework(
        '1',
        title: 'B',
        description: '',
      );
      expect(second.result, HomeworkActionResult.busy);
      expect(cubit.isHomeworkBusy('1'), isTrue);
      repo.updateGate!.complete();
      expect((await first).ok, isTrue);
      expect(repo.updateCalls, 1);
      expect(items().first.title, 'A');
      expect(cubit.isHomeworkBusy('1'), isFalse);
    });

    test('delete removes the item and its reviews', () async {
      cubit = await make();
      final loaded = cubit.state as SessionDetailLoaded;
      // reviews live in state; seed two for different homeworks
      (cubit as dynamic).emit(
        loaded.copyWith(
          assignmentReviews: const [
            AssignmentReview(
              id: 'r1',
              sessionId: 's1',
              homeworkId: '1',
              studentId: '2',
              marks: 5,
              reviewText: '',
            ),
            AssignmentReview(
              id: 'r2',
              sessionId: 's1',
              homeworkId: '2',
              studentId: '2',
              marks: 7,
              reviewText: '',
            ),
          ],
        ),
      );
      final out = await cubit.deleteHomework('1');
      expect(out.ok, isTrue);
      expect(items().map((h) => h.id), ['2']);
      expect(
        (cubit.state as SessionDetailLoaded).assignmentReviews.map(
          (r) => r.homeworkId,
        ),
        ['2'],
      );
    });

    test('delete of one already gone is treated as done (404)', () async {
      cubit = await make();
      repo.deleteError = const NotFoundException();
      final out = await cubit.deleteHomework('1');
      expect(out.result, HomeworkActionResult.notFound);
      expect(items().map((h) => h.id), ['2']);
    });

    test('delete failure keeps the item and reports why', () async {
      cubit = await make();
      repo.deleteError = const ServerException();
      final out = await cubit.deleteHomework('1');
      expect(out.result, HomeworkActionResult.failed);
      expect(items().map((h) => h.id), ['1', '2']);
    });

    test('delete is allowed after the edit window closed', () async {
      cubit = await make(
        homeworks: [
          _hw('1', createdAt: DateTime.utc(2020), locked: true),
        ],
      );
      expect((await cubit.deleteHomework('1')).ok, isTrue);
      expect(items(), isEmpty);
    });
  });

  group('detail sheet', () {
    Future<(RecordingHomeworkRepo, SessionDetailCubit)> open(
      WidgetTester tester, {
      required Homework homework,
    }) async {
      // A phone-sized window so the sheet's buttons are on screen.
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repo = RecordingHomeworkRepo([homework]);
      final cubit = await buildDetailCubit(repo);
      addTearDown(cubit.close);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showHomeworkDetail(
                    context,
                    homework: homework,
                    state: cubit.state as SessionDetailLoaded,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      return (repo, cubit);
    }

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
    }

    testWidgets('same-day homework offers Edit and Delete', (tester) async {
      await open(tester, homework: _hw('1', createdAt: DateTime.now().toUtc()));
      expect(find.text('Edit homework'), findsOneWidget);
      expect(find.text('Delete homework'), findsOneWidget);
    });

    testWidgets('after the day only Delete is offered, with a reason', (
      tester,
    ) async {
      await open(
        tester,
        homework: _hw('1', createdAt: DateTime.utc(2020, 1, 1)),
      );
      expect(find.text('Edit homework'), findsNothing);
      expect(
        find.textContaining('only be edited on the day it was assigned'),
        findsOneWidget,
      );
      expect(find.text('Delete homework'), findsOneWidget);
    });

    testWidgets('edit: validates, saves, and the sheet updates live', (
      tester,
    ) async {
      final (repo, _) = await open(tester, homework: _hw('1'));
      await tester.ensureVisible(find.text('Edit homework'));
      await tester.tap(find.text('Edit homework'));
      await settle(tester);

      // Save is disabled until something changes.
      PrimaryButtonFinder saveBtn() => PrimaryButtonFinder(tester);
      expect(saveBtn().enabled, isFalse);

      // Fields by position: matching on text breaks once the text changes.
      final title = find.byType(TextField).at(0);
      final marks = find.byType(TextField).at(2);
      await tester.enterText(title, '');
      await tester.pump();
      expect(saveBtn().enabled, isFalse); // empty title

      await tester.enterText(title, 'Geometry');
      await tester.pump();
      await tester.enterText(marks, '0');
      await tester.pump();
      expect(find.text('Marks must be greater than 0.'), findsOneWidget);
      expect(saveBtn().enabled, isFalse);

      await tester.enterText(marks, '60');
      await tester.pump();
      expect(saveBtn().enabled, isTrue);

      await tester.tap(find.text('Save changes'));
      await settle(tester);

      expect(repo.updateCalls, 1);
      expect(repo.lastUpdate, ('1', 'Geometry', 'Do it', 60));
      // Back on the detail sheet, showing the new values.
      expect(find.text('Geometry'), findsWidgets);
      expect(find.text('60 marks'), findsOneWidget);
      expect(find.text('Homework updated'), findsOneWidget);
    });

    testWidgets('edit: server failure keeps the form and shows the message', (
      tester,
    ) async {
      final (repo, _) = await open(tester, homework: _hw('1'));
      repo.updateError = const NetworkException();
      await tester.ensureVisible(find.text('Edit homework'));
      await tester.tap(find.text('Edit homework'));
      await settle(tester);

      await tester.enterText(find.widgetWithText(TextField, 'Algebra'), 'New');
      await tester.pump();
      await tester.tap(find.text('Save changes'));
      await settle(tester);

      expect(find.textContaining('internet'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget); // still open
      expect(find.widgetWithText(TextField, 'New'), findsOneWidget);
    });

    testWidgets('edit: window closed → sheet closes, Edit disappears', (
      tester,
    ) async {
      final (repo, _) = await open(tester, homework: _hw('1'));
      repo.updateError = const ValidationException(
        'Homework can only be edited till the end of the day it was assigned.',
        statusCode: 400,
      );
      await tester.ensureVisible(find.text('Edit homework'));
      await tester.tap(find.text('Edit homework'));
      await settle(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Algebra'), 'New');
      await tester.pump();
      await tester.tap(find.text('Save changes'));
      await settle(tester);

      expect(find.text('Edit homework'), findsNothing);
      expect(
        find.textContaining('only be edited on the day it was assigned'),
        findsWidgets,
      );
    });

    testWidgets('delete: cancel keeps it; confirm removes and closes', (
      tester,
    ) async {
      final (repo, cubit) = await open(tester, homework: _hw('1'));
      await tester.ensureVisible(find.text('Delete homework'));

      await tester.tap(find.text('Delete homework'));
      await settle(tester);
      expect(find.text('Delete homework?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect(repo.deleteCalls, 0);

      await tester.tap(find.text('Delete homework'));
      await settle(tester);
      await tester.tap(find.text('Delete'));
      await settle(tester);

      expect(repo.deleteCalls, 1);
      expect((cubit.state as SessionDetailLoaded).homeworks, isEmpty);
      expect(find.text('Algebra'), findsNothing); // sheet closed
      expect(find.text('Homework deleted'), findsOneWidget);
    });

    testWidgets('delete failure keeps the sheet and says why', (tester) async {
      final (repo, cubit) = await open(tester, homework: _hw('1'));
      repo.deleteError = const ServerException();
      await tester.ensureVisible(find.text('Delete homework'));
      await tester.tap(find.text('Delete homework'));
      await settle(tester);
      await tester.tap(find.text('Delete'));
      await settle(tester);

      expect((cubit.state as SessionDetailLoaded).homeworks, hasLength(1));
      expect(find.text('Algebra'), findsWidgets);
      expect(find.textContaining('Something went wrong'), findsOneWidget);
    });
  });
  group('actions on the homework card', () {
    Future<(RecordingHomeworkRepo, SessionDetailCubit)> pumpCard(
      WidgetTester tester, {
      required Homework homework,
      double width = 390,
    }) async {
      tester.view
        ..physicalSize = Size(width, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repo = RecordingHomeworkRepo([homework]);
      final cubit = await buildDetailCubit(repo);
      addTearDown(cubit.close);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: Scaffold(
              body: SingleChildScrollView(
                child: HomeworkTile(homework: homework, onTap: () {}),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      return (repo, cubit);
    }

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
    }

    testWidgets('same-day card shows Edit and Delete without opening it', (
      tester,
    ) async {
      await pumpCard(
        tester,
        homework: _hw('1', createdAt: DateTime.now().toUtc()),
      );
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('after the edit window only Delete is on the card', (
      tester,
    ) async {
      await pumpCard(
        tester,
        homework: _hw('1', createdAt: DateTime.utc(2020)),
      );
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('Edit on the card opens the form and saves', (tester) async {
      final (repo, cubit) = await pumpCard(tester, homework: _hw('1'));
      await tester.tap(find.text('Edit'));
      await settle(tester);
      expect(find.text('Edit homework'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'From the card');
      await tester.pump();
      await tester.tap(find.text('Save changes'));
      await settle(tester);

      expect(repo.updateCalls, 1);
      expect(repo.lastUpdate?.$2, 'From the card');
      expect(
        (cubit.state as SessionDetailLoaded).homeworks.single.title,
        'From the card',
      );
      expect(find.text('Homework updated'), findsOneWidget);
    });

    testWidgets('Delete on the card: cancel keeps, confirm removes', (
      tester,
    ) async {
      final (repo, cubit) = await pumpCard(tester, homework: _hw('1'));

      await tester.tap(find.text('Delete'));
      await settle(tester);
      expect(find.text('Delete homework?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect(repo.deleteCalls, 0);

      await tester.tap(find.text('Delete'));
      await settle(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
      await settle(tester);

      expect(repo.deleteCalls, 1);
      expect((cubit.state as SessionDetailLoaded).homeworks, isEmpty);
      expect(find.text('Homework deleted'), findsOneWidget);
    });

    testWidgets('a failed delete shows why and the card stays', (tester) async {
      final (repo, cubit) = await pumpCard(tester, homework: _hw('1'));
      repo.deleteError = const NetworkException();
      await tester.tap(find.text('Delete'));
      await settle(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
      await settle(tester);

      expect((cubit.state as SessionDetailLoaded).homeworks, hasLength(1));
      expect(find.textContaining('internet'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget); // usable again
    });

    testWidgets('the action row adds only a compact strip to the card', (
      tester,
    ) async {
      final hw = _hw('1', createdAt: DateTime.now().toUtc());
      await pumpCard(tester, homework: hw);
      final withActions = tester.getSize(find.byType(HomeworkTile)).height;
      final actions = tester.getSize(find.byType(HomeworkCardActions)).height;
      expect(actions, lessThanOrEqualTo(48));
      expect(withActions - actions, greaterThan(60)); // the card itself
    });

    for (final w in [260.0, 320.0, 390.0]) {
      testWidgets('card with actions does not overflow at ${w}px', (
        tester,
      ) async {
        await pumpCard(
          tester,
          homework: _hw(
            '1',
            title: 'A very long homework title that keeps going and going on',
            description: 'Write a to z in small letters, neatly, twice.',
          ),
          width: w,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });
    }
  });
}

/// Reads the state of the "Save changes" button.
class PrimaryButtonFinder {
  PrimaryButtonFinder(this.tester);
  final WidgetTester tester;

  bool get enabled {
    final inkwell = tester.widget<InkWell>(
      find
          .ancestor(
            of: find.text('Save changes'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    return inkwell.onTap != null;
  }
}
