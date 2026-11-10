import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/mappers/parent_mappers.dart';
import 'package:skoolstar_teacher_module/data/mappers/session_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/auth/app_role.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';

import '../../fixtures/fixtures.dart' as fx;

void main() {
  group('AppRole', () {
    AuthContext c(String role, {int? staffId, int? guardianId}) =>
        AuthContext.fromJson({
          'contextKey': 'k',
          'role': role,
          'staffId': staffId,
          'guardianId': guardianId,
        });

    test('teacher needs a staff id; parent needs nothing extra', () {
      expect(c('Teacher', staffId: 3).appRole, AppRole.teacher);
      expect(c('teacher').appRole, AppRole.unsupported); // no staff id
      expect(c('Parent', guardianId: 2).appRole, AppRole.parent);
      expect(c('PARENT').appRole, AppRole.parent);
    });

    test('anything else is unsupported on mobile', () {
      for (final r in ['ClientAdmin', 'InstituteAdmin', 'Student', '', 'x']) {
        expect(c(r).appRole, AppRole.unsupported, reason: r);
        expect(c(r).isSupported, isFalse);
      }
    });

    test('title falls back to role + institute', () {
      final ctx = AuthContext.fromJson({
        'contextKey': 'k',
        'role': 'Parent',
        'instituteName': 'ISL AC',
      });
      expect(ctx.title, 'Parent — ISL AC');
      expect(AuthContext.fromJson(fx.parentContext).title, 'Parent — ISL AC');
    });
  });

  group('children', () {
    test('maps rows and derives initials / class label', () {
      final list = childrenFromJson(fx.myChildren);
      expect(list.map((c) => c.id), ['3', '2']);
      expect(list.first.initials, 'IS');
      expect(list.first.classLabel, 'Class 2');
    });

    test('skips rows without a student id; tolerates wrong shapes', () {
      expect(
        childrenFromJson([
          {'studentName': 'No id'},
          {'studentId': 7, 'studentName': 'Ok'},
          'junk',
        ]),
        hasLength(1),
      );
      expect(childrenFromJson(null), isEmpty);
      expect(childrenFromJson({'a': 1}), isEmpty);
    });
  });

  group('attendance', () {
    final list = attendanceFromJson(fx.childAttendance);

    test('maps statuses with the shared config and sorts newest first', () {
      expect(list.map((r) => r.status), ['late', 'present', 'present']);
      expect(list.first.date, DateTime(2026, 10, 9));
      expect(list.first.startTime, '14:40');
      expect(list.last.remarks, 'On time');
    });

    test('unknown status ids are not guessed', () {
      final r = attendanceFromJson([
        {'studentId': 2, 'sessionDate': '2026-10-01', 'statusId': 9},
        {'studentId': 2, 'sessionDate': '2026-10-02', 'statusId': null},
        {'studentId': 2}, // no date → skipped
      ]);
      expect(r, hasLength(2));
      expect(r.every((x) => x.status == 'unmarked'), isTrue);
    });

    test('the school\'s Excused mark (4) is kept for parents', () {
      final r = attendanceFromJson([
        {'studentId': 2, 'sessionDate': '2026-10-01', 'statusId': 4},
      ]);
      expect(r.single.status, 'excused');
    });
  });

  group('assignments', () {
    final list = assignmentsFromJson(fx.childAssignments);

    test('maps fields, sorted by latest deadline', () {
      expect(list.map((a) => a.id), ['1009', '1006']);
      expect(list.first.marks, 89);
      expect(list.first.feedback, 'weldone');
      expect(list.first.isGraded, isTrue);
      expect(list.last.isGraded, isFalse);
    });

    test('status follows the web: completed flag, else overdue/pending', () {
      // deadline 2026-10-10 15:41, not completed; graded by the teacher.
      final graded = list.first;
      expect(graded.statusAt(DateTime(2026, 10, 11)), AssignmentStatus.graded);
      expect(graded.isOpen, isFalse);

      final a = graded.copyWith(marks: null);
      expect(a.statusAt(DateTime(2026, 10, 9)), AssignmentStatus.pending);
      expect(a.statusAt(DateTime(2026, 10, 11)), AssignmentStatus.overdue);
      expect(
        a.copyWith(isCompleted: true).statusAt(DateTime(2026, 10, 11)),
        AssignmentStatus.completed,
      );
    });

    test('rows missing an id, title or deadline are skipped', () {
      expect(
        assignmentsFromJson([
          {'studentId': 2, 'title': 't'},
          {'studentId': 2, 'taskId': 1, 'deadline': '2026-10-01T10:00:00'},
        ]),
        isEmpty,
      );
    });
  });

  group('guardian', () {
    test('matches the login e-mail', () {
      final g = guardianFromJson(
        fx.contactPersons,
        email: 'ZealMughal@gmail.com',
      );
      expect(g.name, 'Muhammad Amir');
      expect(g.relationship, 'Father');
      expect(g.initials, 'MA');
    });

    test('falls back to the primary guardian, then to the e-mail only', () {
      expect(
        guardianFromJson(fx.contactPersons, email: 'other@x.com').name,
        'Muhammad Amir',
      );
      final none = guardianFromJson(<Object>[], email: 'a@b.com');
      expect(none.name, '');
      expect(none.initials, 'A');
    });
  });

  group('student occurrences → sessions', () {
    final sessions = sessionsFromOccurrences(fx.studentOccurrences);

    test('keeps every teacher and subject of the slot', () {
      expect(sessions.first.subjectIds, ['18', '19']);
      final teachers = sessions.first.teachers;
      expect(teachers.map((t) => t.name), ['Adnan Ilyas', 'Tahir Mughal']);
      expect(teachers.last.subjectIds, ['18', '19']);
    });

    test('uses the pupil\'s single class, not every class of the slot', () {
      expect(sessions.first.classIds, ['23']);
    });

    test('teacher mapping is unchanged (own subjects only, no teachers)', () {
      final mine = sessionsFromOccurrences(fx.studentOccurrences, staffId: 3);
      expect(mine.first.teachers, isEmpty);
      expect(mine.first.classIds, ['23', '24']);
      expect(mine.first.teacherId, '3');
    });
  });
}
