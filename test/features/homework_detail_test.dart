import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/student_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/homework_repository.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';
import 'package:skoolstar_teacher_module/features/session_detail/view/homework_tab.dart'
    show HomeworkTile;
import 'package:skoolstar_teacher_module/features/session_detail/widgets/homework_detail_sheet.dart';

ApiClient _api({String base = 'http://host:86'}) => ApiClient(
  baseUrl: base,
  httpClient: MockClient((_) async => http.Response('', 200)),
  accessToken: () => 'tok',
);

void main() {
  _homeworkTileLayoutTests();

  group('file url resolution', () {
    test('absolute, rooted and relative references', () {
      final api = _api();
      expect(
        api.resolveFileUrl('https://cdn.x/a.pdf').toString(),
        'https://cdn.x/a.pdf',
      );
      expect(
        api.resolveFileUrl('/uploads/a.pdf').toString(),
        'http://host:86/uploads/a.pdf',
      );
      expect(
        api.resolveFileUrl('uploads/a.pdf').toString(),
        'http://host:86/uploads/a.pdf',
      );
      expect(
        api.resolveFileUrl(r'uploads\a b.pdf').toString(),
        'http://host:86/uploads/a%20b.pdf',
      );
    });

    test('trailing slash on the base and empty references', () {
      expect(
        _api(base: 'http://host:86/').resolveFileUrl('/a.png').toString(),
        'http://host:86/a.png',
      );
      expect(_api().resolveFileUrl('  '), isNull);
    });

    test('auth headers carry the bearer token', () async {
      expect(await _api().authHeaders(), {'Authorization': 'Bearer tok'});
    });
  });

  group('HomeworkAttachment', () {
    test('classifies by type or file name', () {
      expect(
        const HomeworkAttachment(
          fileName: 'a.JPG',
          sizeKb: 1,
          type: '',
        ).isImage,
        isTrue,
      );
      expect(
        const HomeworkAttachment(fileName: 'x', sizeKb: 1, type: 'png').isImage,
        isTrue,
      );
      expect(
        const HomeworkAttachment(
          fileName: 'a.pdf',
          sizeKb: 1,
          type: 'pdf',
        ).isPdf,
        isTrue,
      );
      expect(
        const HomeworkAttachment(
          fileName: 'a.zip',
          sizeKb: 1,
          type: 'zip',
        ).isImage,
        isFalse,
      );
    });
  });

  testWidgets('detail sheet shows full homework and its attachments', (
    tester,
  ) async {
    final hw = Homework(
      id: '1',
      sessionId: 's',
      classId: '23',
      subjectId: '18',
      title: 'Chapter 3 worksheet',
      description: 'Solve all questions.',
      deadline: DateTime(2020, 1, 2, 9),
      maxMarks: 50,
      assignedStudentIds: const ['2', '99'],
      attachments: const [
        HomeworkAttachment(
          fileName: 'sheet.pdf',
          sizeKb: 120,
          type: 'pdf',
          reference: 'uploads/sheet.pdf',
        ),
        HomeworkAttachment(
          fileName: 'diagram.png',
          sizeKb: 0,
          type: 'png',
          reference: 'uploads/diagram.png',
        ),
      ],
    );
    final state =
        SessionDetailState.loaded(
              session: Session(
                id: 's',
                date: DateTime(2026, 10, 8),
                startTime: '10:00',
                endTime: '11:00',
                classIds: const ['23'],
                subjectIds: const ['18'],
                teacherId: '3',
              ),
              classes: const [ClassGroup(id: '23', name: 'Class 1')],
              subjects: const [Subject(id: '18', name: 'Computer')],
              students: const [
                Student(
                  id: '2',
                  firstName: 'Jannat',
                  lastName: 'Shahzadi',
                  classGroupId: '23',
                ),
              ],
              attendance: const {},
              homeworks: [hw],
              feedbackMessages: const [],
              assignmentReviews: const [],
            )
            as SessionDetailLoaded;

    await tester.pumpWidget(
      RepositoryProvider<HomeworkRepository>.value(
        value: HomeworkRepositoryImpl(_api()),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    showHomeworkDetail(context, homework: hw, state: state),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Chapter 3 worksheet'), findsOneWidget);
    expect(find.text('50 marks'), findsOneWidget);
    expect(find.text('Class 1'), findsOneWidget);
    expect(find.text('Computer'), findsOneWidget);
    expect(find.text('Past due'), findsOneWidget);
    expect(find.text('Solve all questions.'), findsOneWidget);
    expect(find.text('Attachments (2)'), findsOneWidget);
    expect(find.text('sheet.pdf'), findsOneWidget);
    expect(find.text('diagram.png'), findsOneWidget);
    expect(find.text('Jannat Shahzadi'), findsOneWidget);
    expect(find.text('Student #99'), findsOneWidget); // unknown student id
  });
}

void _homeworkTileLayoutTests() {
  for (final width in [260.0, 320.0, 390.0]) {
    testWidgets('homework card does not overflow at ${width}px, 1.15x text', (
      tester,
    ) async {
      final hw = Homework(
        id: '1',
        sessionId: 's',
        classId: '23',
        subjectId: '18',
        title: 'A very long homework title that keeps going and going',
        description: 'Write a to z in small letters, neatly, twice.',
        deadline: DateTime(2026, 10, 23, 16, 15),
        maxMarks: 100,
        assignedCount: 12,
        attachments: const [
          HomeworkAttachment(fileName: 'a.pdf', sizeKb: 1, type: 'pdf'),
          HomeworkAttachment(fileName: 'b.png', sizeKb: 1, type: 'png'),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 800),
              textScaler: const TextScaler.linear(1.15),
            ),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: HomeworkTile(homework: hw, onTap: () {}),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('12 students'), findsOneWidget);
    });
  }

  testWidgets('singular student label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeworkTile(
            homework: Homework(
              id: '1',
              sessionId: 's',
              classId: '23',
              subjectId: '18',
              title: 'T',
              description: '',
              deadline: DateTime(2026),
              assignedCount: 1,
            ),
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('1 student'), findsOneWidget);
  });
}
