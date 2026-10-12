import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/config/attendance_status_config.dart';
import 'package:skoolstar_teacher_module/data/mappers/feedback_mapper.dart';
import 'package:skoolstar_teacher_module/data/mappers/homework_mapper.dart';
import 'package:skoolstar_teacher_module/data/mappers/people_mapper.dart';
import 'package:skoolstar_teacher_module/data/mappers/session_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/teacher_catalog.dart';

import '../../fixtures/fixtures.dart' as fx;

void main() {
  sessionPhaseTests();

  group('sessionsFromOccurrences', () {
    final sessions = sessionsFromOccurrences(fx.occurrencesOctober, staffId: 3);

    test('maps ids, times, classes and skips breaks', () {
      expect(sessions, hasLength(2)); // the break is dropped
      final s = sessions.first;
      expect(s.id, 'cc459182-a077-4a98-a55d-0b702091dfbf');
      expect(s.occurrenceId, 1019);
      expect(s.scheduleId, 1010);
      expect(s.date, DateTime(2026, 10));
      expect(s.startTime, '15:48');
      expect(s.endTime, '16:48');
      expect(s.classIds, ['23', '24']);
      expect(s.isLocked, isFalse);
      expect(s.teacherId, '3');
    });

    test("keeps only this teacher's subjects (deduplicated)", () {
      expect(sessions.first.subjectIds, ['18', '19', '17']);
      expect(sessions.last.subjectIds, ['18', '19']);
    });

    test('is sorted by date then time', () {
      expect(sessions.map((s) => s.occurrenceId), [1019, 1026]);
    });

    test('non-zero status means locked; malformed rows are skipped', () {
      final out = sessionsFromOccurrences(
        [
          {...fx.occurrencesOctober.first, 'status': 2},
          {'id': 5, 'sessionDate': 'garbage'},
          {'sessionDate': '2026-10-02'}, // no id at all
          'not a map',
        ],
        staffId: 3,
      );
      expect(out, hasLength(1));
      expect(out.single.isLocked, isTrue);
    });

    test('non-list payload gives an empty list', () {
      expect(sessionsFromOccurrences(null, staffId: 3), isEmpty);
      expect(sessionsFromOccurrences({'x': 1}, staffId: 3), isEmpty);
    });
  });

  group('Session.isLive', () {
    Session at(DateTime now, {String start = '00:00', String end = '23:59'}) =>
        Session(
          id: 'a',
          date: DateTime(now.year, now.month, now.day),
          startTime: start,
          endTime: end,
          classIds: const [],
          subjectIds: const [],
          teacherId: '3',
        );

    test('true inside the window, false for other days and when locked', () {
      final now = DateTime.now();
      expect(at(now).isLive, isTrue);
      expect(
        at(now.add(const Duration(days: 1))).isLive,
        isFalse,
      );
      expect(at(now).copyWith(isLocked: true).isLive, isFalse);
    });
  });

  group('buildCatalog', () {
    final catalog = buildCatalog(
      schedules: fx.teacherSchedules,
      myClasses: fx.myClasses,
      myStudents: fx.myStudents,
      staffId: 3,
    );

    test('classes are the union, with student counts', () {
      expect(catalog.classes.map((c) => c.name), ['Class 1', 'Class 2']);
      expect(catalog.classes.map((c) => c.studentCount), [1, 1]);
      expect(catalog.classes.map((c) => c.id), ['23', '24']);
    });

    test('subjects exclude other teachers and have stable colours', () {
      expect(catalog.subjects.map((s) => s.name), [
        'Computer',
        'English',
        'Math',
      ]);
      final again = buildCatalog(
        schedules: fx.teacherSchedules,
        myClasses: null,
        myStudents: null,
        staffId: 3,
      );
      expect(
        again.subjects.map((s) => s.colorHex),
        catalog.subjects.map((s) => s.colorHex),
      );
    });

    test('tolerates empty / wrong-shaped payloads', () {
      final empty = buildCatalog(
        schedules: null,
        myClasses: 'x',
        myStudents: <dynamic>[],
        staffId: 3,
      );
      expect(empty.classes, isEmpty);
      expect(empty.subjects, isEmpty);
    });
  });

  group('people', () {
    test('splitName', () {
      expect(splitName('Irha Shahzadi').first, 'Irha');
      expect(splitName('Irha Shahzadi').last, 'Shahzadi');
      expect(splitName('Ali Raza Khan').last, 'Raza Khan');
      expect(splitName('Cher').last, '');
      expect(splitName('  ').first, '');
    });
  });

  group('AttendanceStatusConfig', () {
    test('round trips and treats unknown ids as unmarked', () {
      for (final s in ['present', 'absent', 'late']) {
        expect(
          AttendanceStatusConfig.fromId(AttendanceStatusConfig.toId(s)),
          s,
        );
      }
      // Excused (4) exists on the backend but is intentionally unused.
      expect(AttendanceStatusConfig.fromId(4), 'unmarked');
      expect(AttendanceStatusConfig.toId('excused'), isNull);
      expect(AttendanceStatusConfig.fromId(null), 'unmarked');
      expect(AttendanceStatusConfig.fromId(42), 'unmarked');
      expect(AttendanceStatusConfig.toId('unmarked'), isNull);
    });
  });

  group('homeworkFromJson', () {
    final fallback = DateTime(2026, 10, 8);

    test('maps a typical row', () {
      final hw = homeworkFromJson(
        {
          'taskId': 1008,
          'title': 'Computer',
          'description': 'Do it',
          'deadline': '2026-10-08T21:10:00',
          'maxMarks': 50,
          'studentIds': [2, 3, 2],
          'attachments': ['files/a.pdf'],
        },
        sessionId: 's1',
        classId: '23',
        fallbackDeadline: fallback,
      )!;
      expect(hw.id, '1008');
      expect(hw.maxMarks, 50);
      expect(hw.assignedStudentIds, ['2', '3']);
      expect(hw.attachments.single.fileName, 'a.pdf');
      expect(hw.attachments.single.type, 'pdf');
      expect(hw.deadline, DateTime(2026, 10, 8, 21, 10));
    });

    test(
      'defaults for missing optional fields; skips rows without id/title',
      () {
        final hw = homeworkFromJson(
          {'id': 7, 'title': 'T'},
          sessionId: 's1',
          classId: '23',
          fallbackDeadline: fallback,
        )!;
        expect(hw.maxMarks, 100);
        expect(hw.deadline, fallback);
        expect(
          homeworkFromJson(
            {'title': 'no id'},
            sessionId: 's',
            classId: '1',
            fallbackDeadline: fallback,
          ),
          isNull,
        );
      },
    );
  });

  group('homework list (real UAT payload)', () {
    // Recorded from GET TeacherModule/homework/class/{id}: one homework made
    // on the web (server path) and one made on mobile before the fix (bare
    // file name).
    const rows = [
      {
        'id': 1011,
        'title': 'Counting form 1 to 60',
        'description': 'Write counting neatly.',
        'deadline': '2026-10-30T16:16:00',
        'maxMarks': 10,
        'submissionCount': 0,
        'totalAssigned': 1,
        'scheduleOccurrenceId': 1027,
        'attachments': [
          '/uploads/teacher-module/homework/20261009111657410-ff36694f9b47471ea0ce8c947081a937-Homeicon_Zenvoices.png',
        ],
      },
      {
        'id': 1010,
        'title': 'A to z',
        'description': 'Write a to z.',
        'deadline': '2026-10-23T16:15:00',
        'maxMarks': 99,
        'totalAssigned': 1,
        'attachments': ['Screenshot_20261006-155447.jpg'],
      },
    ];
    final list = [
      for (final r in rows)
        homeworkFromJson(
          r,
          sessionId: 's',
          classId: '23',
          fallbackDeadline: DateTime(2026),
        )!,
    ];

    test('counts come from totalAssigned when ids are absent', () {
      expect(list.first.assignedStudentIds, isEmpty);
      expect(list.first.studentTotal, 1);
    });

    test('web attachment has a location, legacy mobile one does not', () {
      final web = list.first.attachments.single;
      expect(web.hasLocation, isTrue);
      expect(web.isImage, isTrue);
      expect(web.fileName, 'Homeicon_Zenvoices.png'); // prefix hidden
      expect(
        web.reference,
        startsWith('/uploads/teacher-module/homework/2026'),
      );

      final legacy = list.last.attachments.single;
      expect(legacy.hasLocation, isFalse);
      expect(legacy.isImage, isTrue);
    });
  });

  group('feedback mappers', () {
    test('reviews only include graded students', () {
      final reviews = [
        for (final row in fx.taskStudents)
          reviewFromTaskStudent(row, sessionId: 's', taskId: '1008'),
      ].nonNulls.toList();
      expect(reviews, hasLength(1));
      expect(reviews.single.marks, 80);
      expect(reviews.single.reviewText, 'Good work');
    });

    test('conversation rows tolerate alternate keys and bad rows', () {
      final ok = feedbackFromConversation(
        {'id': 1, 'content': 'Great', 'studentId': 2, 'isPositive': false},
        sessionId: 's',
      )!;
      expect(ok.message, 'Great');
      expect(ok.isPositive, isFalse);
      expect(feedbackFromConversation({'id': 1}, sessionId: 's'), isNull);
    });
  });
}

void sessionPhaseTests() {
  group('Session.phaseAt', () {
    Session at(
      DateTime date,
      String start,
      String end, {
      bool locked = false,
    }) => Session(
      id: 'a',
      date: date,
      startTime: start,
      endTime: end,
      classIds: const [],
      subjectIds: const [],
      teacherId: '3',
      isLocked: locked,
    );

    final day = DateTime(2026, 10, 9);

    test('before, during and after the same-day window', () {
      final s = at(day, '14:40', '23:40');
      expect(s.phaseAt(DateTime(2026, 10, 9, 9)), SessionPhase.laterToday);
      expect(s.phaseAt(DateTime(2026, 10, 9, 14, 40)), SessionPhase.live);
      expect(s.phaseAt(DateTime(2026, 10, 9, 23, 39)), SessionPhase.live);
      expect(s.phaseAt(DateTime(2026, 10, 9, 23, 40)), SessionPhase.ended);
    });

    test('past days are ended, future days upcoming', () {
      final s = at(day, '09:00', '10:00');
      expect(s.phaseAt(DateTime(2026, 10, 10)), SessionPhase.ended);
      expect(s.phaseAt(DateTime(2026, 10, 8, 23)), SessionPhase.upcoming);
    });

    test('a session crossing midnight stays live until the next morning', () {
      final s = at(day, '22:00', '01:00');
      expect(s.phaseAt(DateTime(2026, 10, 10, 0, 30)), SessionPhase.live);
      expect(s.phaseAt(DateTime(2026, 10, 10, 1)), SessionPhase.ended);
    });

    test('cancelled wins over time', () {
      final s = at(day, '14:40', '23:40', locked: true);
      expect(s.phaseAt(DateTime(2026, 10, 9, 15)), SessionPhase.cancelled);
      expect(s.isLive, isFalse);
    });
  });
}
