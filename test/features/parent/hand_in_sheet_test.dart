import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/attachment_picker.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/assignment_submission_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/hand_in/hand_in_sheet.dart';

import '../../helpers/test_fonts.dart';
import 'hand_in_fakes.dart';

final _assignment = ChildAssignment(
  id: '90',
  childId: '42',
  title: 'Fractions worksheet',
  deadline: DateTime(2026, 11, 10),
);

void main() {
  setUpAll(loadTestFonts);

  late FakeSubmissionRepo repo;
  late FakePicker picker;
  late List<DateTime?> results;

  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repo = FakeSubmissionRepo();
    picker = FakePicker();
    results = [];
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AssignmentSubmissionRepository>.value(value: repo),
          RepositoryProvider<AttachmentPicker>.value(value: picker),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async => results.add(
                    await showHandInSheet(context, assignment: _assignment),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> pickFiles(WidgetTester tester, List<PickedAttachment> f) async {
    picker.files = f;
    await tester.tap(find.text('Files'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the homework and the three ways to add files', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Hand in homework'), findsOneWidget);
    expect(find.text('Fractions worksheet'), findsOneWidget);
    expect(find.text('Note (optional)'), findsOneWidget);
    expect(find.text('Links (optional)'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('Files'), findsOneWidget);
    expect(find.text('0/5'), findsNWidgets(2));
    expect(find.text("You can't change it after handing in."), findsOneWidget);
  });

  testWidgets('hands in with a note, a link and a file', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField).first, 'Done!');
    await tester.enterText(find.byType(TextField).at(1), 'example.com/work');
    await tester.tap(find.byTooltip('Add link'));
    await tester.pump();
    expect(find.text('https://example.com/work'), findsOneWidget);
    await pickFiles(tester, [file('answers.pdf', size: 2048)]);
    expect(find.text('answers.pdf'), findsOneWidget);
    expect(find.text('2 KB'), findsOneWidget);

    await tester.tap(find.text('Hand in'));
    await tester.pumpAndSettle();
    // Confirmation explains it is final.
    expect(find.text('Hand in this homework?'), findsOneWidget);
    expect(find.textContaining("can't change it afterwards"), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Hand in'));
    await tester.pumpAndSettle();

    expect(repo.uploads, ['answers.pdf']);
    expect(repo.submits.single.note, 'Done!');
    expect(repo.submits.single.links, ['https://example.com/work']);
    expect(repo.submits.single.fileUrls, ['/uploads/answers.pdf']);
    expect(results, [repo.completedAt]);
    expect(find.text('Hand in homework'), findsNothing); // sheet closed
  });

  testWidgets('"Not yet" in the confirmation sends nothing', (tester) async {
    await open(tester);
    await tester.tap(find.text('Hand in'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('without a note, links or files'),
      findsOneWidget,
    );
    await tester.tap(find.text('Not yet'));
    await tester.pumpAndSettle();
    expect(repo.submits, isEmpty);
    expect(find.text('Hand in homework'), findsOneWidget);
  });

  testWidgets('a bare hand-in is possible', (tester) async {
    await open(tester);
    await tester.tap(find.text('Hand in'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Hand in'));
    await tester.pumpAndSettle();
    expect(repo.submits, hasLength(1));
    expect(results.single, isNotNull);
  });

  testWidgets('link problems are shown on the field and cleared on typing', (
    tester,
  ) async {
    await open(tester);
    final field = find.byType(TextField).at(1);
    await tester.enterText(field, 'not a link');
    await tester.tap(find.byTooltip('Add link'));
    await tester.pump();
    expect(find.text('Enter a valid web address.'), findsOneWidget);
    await tester.enterText(field, 'example.com');
    await tester.pump();
    expect(find.text('Enter a valid web address.'), findsNothing);

    // Keyboard "done" adds it too; the same link twice is refused.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('https://example.com'), findsOneWidget);
    // The box is emptied, ready for the next link.
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    await tester.enterText(field, 'example.com');
    await tester.tap(find.byTooltip('Add link'));
    await tester.pump();
    expect(find.text('That link is already added.'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove link'));
    await tester.pump();
    expect(find.text('https://example.com'), findsNothing);
  });

  testWidgets('refused files are explained; good ones can be removed', (
    tester,
  ) async {
    await open(tester);
    await pickFiles(tester, [file('a.pdf'), file('movie.mp4')]);
    expect(find.text('a.pdf'), findsOneWidget);
    expect(find.textContaining('movie.mp4 is not a supported'), findsOneWidget);
    expect(find.text('1/5'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove file'));
    await tester.pump();
    expect(find.text('a.pdf'), findsNothing);
    expect(find.text('0/5'), findsNWidgets(2));
    expect(find.textContaining('movie.mp4'), findsNothing);
  });

  testWidgets('at five files the add buttons are disabled', (tester) async {
    await open(tester);
    await pickFiles(tester, [for (var i = 0; i < 5; i++) file('f$i.pdf')]);
    expect(find.text('5/5'), findsOneWidget);
    final camera = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Take photo'),
    );
    expect(camera.onPressed, isNull);
  });

  testWidgets('camera permission problem is shown', (tester) async {
    await open(tester);
    picker.error = const AttachmentPickException(
      'Allow camera access in Settings to take a photo.',
    );
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    expect(
      find.text('Allow camera access in Settings to take a photo.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'an upload failure keeps the sheet open and says nothing went in',
    (tester) async {
      await open(tester);
      await pickFiles(tester, [file('a.pdf')]);
      repo.uploadErrors['a.pdf'] = const NetworkException();
      await tester.tap(find.text('Hand in'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Hand in'));
      await tester.pumpAndSettle();

      expect(find.textContaining("Couldn't upload a.pdf"), findsOneWidget);
      expect(find.textContaining('Nothing was handed in.'), findsOneWidget);
      expect(repo.submits, isEmpty);
      expect(results, isEmpty);

      // Fix and retry.
      repo.uploadErrors.clear();
      await tester.tap(find.text('Hand in'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Hand in'));
      await tester.pumpAndSettle();
      expect(repo.submits, hasLength(1));
    },
  );

  testWidgets('the server message is shown when the submit is refused', (
    tester,
  ) async {
    await open(tester);
    repo.submitError = const ValidationException(
      'This assignment is not assigned to you.',
      statusCode: 400,
    );
    await tester.tap(find.text('Hand in'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Hand in'));
    await tester.pumpAndSettle();
    expect(
      find.text('This assignment is not assigned to you.'),
      findsOneWidget,
    );
  });

  testWidgets('while sending: progress is shown and the sheet cannot be left', (
    tester,
  ) async {
    await open(tester);
    await pickFiles(tester, [file('a.pdf'), file('b.pdf')]);
    repo.gate = Completer<void>();
    await tester.tap(find.text('Hand in'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Hand in'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Uploading 1 of 2…'), findsOneWidget);
    // Back / close do nothing while sending.
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump();
    expect(find.text('Hand in homework'), findsOneWidget);
    expect(find.textContaining('Discard'), findsNothing);

    repo.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Hand in homework'), findsNothing);
    expect(results, [repo.completedAt]);
  });

  testWidgets('leaving an empty sheet needs no question', (tester) async {
    await open(tester);
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Hand in homework'), findsNothing);
    expect(results, [null]);
  });

  testWidgets('leaving with something added asks first; Keep editing stays', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(TextField).first, 'half written');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Discard this hand-in?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Hand in homework'), findsOneWidget);
    expect(find.text('half written'), findsOneWidget);

    // The system back button asks too; Discard closes without handing in.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard this hand-in?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Hand in homework'), findsNothing);
    expect(results, [null]);
    expect(repo.submits, isEmpty);
  });

  testWidgets('with the keyboard up the form stays usable (no overflow)', (
    tester,
  ) async {
    await open(tester, size: const Size(390, 844));
    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Still room for the form: the note box is on screen above the keyboard.
    final note = tester.getRect(find.byType(TextField).first);
    expect(note.bottom, lessThan(844 - 336));
    expect(note.height, greaterThan(50));
  });

  for (final size in [const Size(320, 568), const Size(768, 1024)]) {
    testWidgets('no layout errors at ${size.width.toInt()} with a full form', (
      tester,
    ) async {
      await open(tester, size: size);
      await tester.enterText(find.byType(TextField).first, 'n' * 400);
      for (var i = 0; i < 5; i++) {
        await tester.enterText(
          find.byType(TextField).at(1),
          'https://very-long-domain-name-example-$i.com/${'path/' * 12}',
        );
        await tester.tap(find.byTooltip('Add link'));
        await tester.pump();
      }
      await pickFiles(tester, [
        file('a-really-long-file-name-that-keeps-going-and-going-$size.pdf'),
        file('movie.mp4'),
        for (var i = 0; i < 4; i++) file('f$i.png', size: 3 * 1024 * 1024),
      ]);
      repo.uploadErrors['f1.png'] = const ValidationException(
        'Unsupported file type (.png). Allowed: PDF, Word, Excel, '
        'PowerPoint, TXT, JPG, PNG, ZIP.',
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -900),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
