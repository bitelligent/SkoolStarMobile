import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_model.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/models/institute_model.dart';
import 'package:skoolstar_teacher_module/data/models/notification_model.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/student_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/models/user_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/homework_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/institute_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/notifications_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/user_repository.dart';
import 'package:skoolstar_teacher_module/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:skoolstar_teacher_module/features/dashboard/cubit/dashboard_state.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_cubit.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';

Session _session({
  String id = 's1',
  DateTime? date,
  bool locked = false,
  String start = '00:00',
  String end = '23:59',
}) => Session(
  id: id,
  date: date ?? DateTime.now(),
  startTime: start,
  endTime: end,
  classIds: const ['23'],
  subjectIds: const ['18'],
  teacherId: '3',
  isLocked: locked,
  occurrenceId: 1,
  scheduleId: 2,
);

class _Sessions implements SessionRepository {
  _Sessions(this.sessions);

  List<Session> sessions;
  Object? error;
  final ranges = <(DateTime, DateTime)>[];

  @override
  Future<List<Session>> getBetween(
    DateTime from,
    DateTime to, {
    bool refresh = false,
  }) async {
    ranges.add((from, to));
    if (error != null) throw error!;
    return sessions;
  }

  @override
  Future<Session?> getById(String id) async =>
      sessions.where((s) => s.id == id).firstOrNull;
}

class _Institute implements InstituteRepository {
  @override
  Future<InstituteInfo> getCurrent() async =>
      const InstituteInfo(id: '8', name: 'ISL AC', type: 'TUITION CENTER');
}

class _Users implements UserRepository {
  @override
  Future<UserModel> getCurrentUser() async => const UserModel(
    id: '3',
    firstName: 'Tahir',
    lastName: 'Mughal',
    email: 't@x.com',
  );

  @override
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    String? currentPassword,
    String? newPassword,
  }) => throw UnimplementedError();
}

class _Classes implements ClassRepository {
  @override
  Future<List<ClassGroup>> getAll() async => const [
    ClassGroup(id: '23', name: 'Class 1'),
  ];
}

class _Subjects implements SubjectRepository {
  @override
  Future<List<Subject>> getAll() async => const [
    Subject(id: '18', name: 'Computer'),
  ];
}

class _Notifications implements NotificationsRepository {
  @override
  Future<NotificationsData> getNotifications() async =>
      throw StateError('mock notifications broke');
}

class _Attendance implements AttendanceRepository {
  Object? submitError;
  Completer<void>? gate;
  int submits = 0;

  @override
  Future<AttendanceSheet> getSheet(
    Session session,
    List<ClassGroup> classes,
  ) async => const AttendanceSheet(
    students: [
      Student(id: '2', firstName: 'A', lastName: 'B', classGroupId: '23'),
      Student(id: '3', firstName: 'C', lastName: 'D', classGroupId: '23'),
    ],
    statuses: {'2': 'present', '3': 'unmarked'},
  );

  @override
  Future<void> submit(Session session, Map<String, String> statuses) async {
    submits++;
    await gate?.future;
    if (submitError != null) throw submitError!;
  }
}

class _Homework implements HomeworkRepository {
  @override
  Uri? attachmentUrl(HomeworkAttachment attachment) => null;

  @override
  Future<Map<String, String>> attachmentHeaders() async => {};

  @override
  Future<List<Homework>> getForSession(Session session) async => const [];

  @override
  Future<Homework> create(Session session, Homework draft) async =>
      draft.copyWith(id: 'hw1');

  @override
  Future<HomeworkAttachment> uploadAttachment({
    required String fileName,
    required List<int> bytes,
  }) => throw const ValidationException('File is too large (max 15 MB).');
}

class _Feedback implements FeedbackRepository {
  bool historyFails = false;
  FeedbackSendResult? result;

  @override
  Future<List<FeedbackMessage>> getMessagesForSession(Session s) async {
    if (historyFails) throw const ServerException();
    return const [];
  }

  @override
  Future<List<AssignmentReview>> getReviews(
    Session session,
    List<Homework> homeworks,
  ) async => const [];

  @override
  Future<FeedbackSendResult> sendMessage(
    Session session,
    FeedbackMessage draft,
  ) async => result!;

  @override
  Future<AssignmentReview> saveReview(AssignmentReview review) =>
      throw const NetworkException();
}

void main() {
  group('DashboardCubit', () {
    DashboardCubit build(_Sessions sessions) => DashboardCubit(
      instituteRepository: _Institute(),
      userRepository: _Users(),
      sessionRepository: sessions,
      classRepository: _Classes(),
      subjectRepository: _Subjects(),
      notificationsRepository: _Notifications(),
    );

    test(
      'loads data; a broken notifications source does not fail it',
      () async {
        final sessions = _Sessions([_session()]);
        final cubit = build(sessions);
        await cubit.load();

        final s = cubit.state as DashboardLoaded;
        expect(s.institute.name, 'ISL AC');
        expect(s.user.firstName, 'Tahir');
        expect(s.user.hasUnreadNotifications, isFalse);
        expect(s.sessions, hasLength(1));
        expect(s.liveSession?.id, 's1'); // 00:00-23:59 today is live
        // previous, current and next month are requested
        final now = DateTime.now();
        expect(sessions.ranges.single.$1, DateTime(now.year, now.month - 1));
        expect(sessions.ranges.single.$2, DateTime(now.year, now.month + 2, 0));
      },
    );

    test('failure becomes a readable error state', () async {
      final sessions = _Sessions([])..error = const NetworkException();
      final cubit = build(sessions);
      await cubit.load();

      expect(cubit.state, isA<DashboardError>());
      expect(
        (cubit.state as DashboardError).message,
        contains('internet'),
      );

      sessions.error = StateError('boom');
      await cubit.load();
      expect(
        (cubit.state as DashboardError).message,
        'Something went wrong. Please try again.',
      );
    });

    test('refresh failure keeps the screen and returns the message', () async {
      final sessions = _Sessions([_session()]);
      final cubit = build(sessions);
      await cubit.load();
      sessions.error = const ServerException();

      final error = await cubit.refresh();

      expect(error, isNotNull);
      expect(cubit.state, isA<DashboardLoaded>());
      expect((cubit.state as DashboardLoaded).sessions, hasLength(1));
    });

    test(
      'paging beyond the loaded window fetches that month; inside does not',
      () async {
        final sessions = _Sessions([_session()]);
        final cubit = build(sessions);
        await cubit.load();
        expect(sessions.ranges, hasLength(1));

        await cubit.stepMonth(1); // inside prev..next window
        expect(sessions.ranges, hasLength(1));

        await cubit.stepMonth(1);
        await cubit.stepMonth(1); // +3 months: outside
        expect(sessions.ranges.length, greaterThan(1));
      },
    );

    test('a failing extra month is ignored, existing data stays', () async {
      final sessions = _Sessions([_session()]);
      final cubit = build(sessions);
      await cubit.load();
      sessions.error = const NetworkException();
      for (var i = 0; i < 4; i++) {
        await cubit.stepMonth(1);
      }
      expect(cubit.state, isA<DashboardLoaded>());
      expect((cubit.state as DashboardLoaded).sessions, hasLength(1));
    });
  });

  group('SessionDetailCubit', () {
    late _Attendance attendance;
    late _Feedback feedback;

    SessionDetailCubit build(_Sessions sessions) {
      attendance = _Attendance();
      feedback = _Feedback();
      return SessionDetailCubit(
        sessionId: 's1',
        sessionRepository: sessions,
        classRepository: _Classes(),
        subjectRepository: _Subjects(),
        attendanceRepository: attendance,
        homeworkRepository: _Homework(),
        feedbackRepository: feedback,
      );
    }

    test('loads roster with the saved attendance', () async {
      final cubit = build(_Sessions([_session()]));
      await cubit.load();

      final s = cubit.state as SessionDetailLoaded;
      expect(s.students, hasLength(2));
      expect(s.attendance, {'2': 'present', '3': 'unmarked'});
      expect(cubit.savedCount, 1);
    });

    test('unknown session is an error state', () async {
      final cubit = build(_Sessions([]));
      await cubit.load();
      expect((cubit.state as SessionDetailError).message, 'Session not found');
    });

    test('feedback history failing does not block the session', () async {
      final cubit = build(_Sessions([_session()]));
      feedback.historyFails = true;
      await cubit.load();
      expect(cubit.state, isA<SessionDetailLoaded>());
    });

    test('a locked session cannot submit attendance', () async {
      final cubit = build(_Sessions([_session(locked: true)]));
      await cubit.load();

      expect(await cubit.submitAttendance(), isFalse);
      expect(cubit.lastActionError, 'This session is locked.');
      expect(attendance.submits, 0);
    });

    test('submit failure reports why and re-enables the button', () async {
      final cubit = build(_Sessions([_session()]));
      await cubit.load();
      attendance.submitError = const NetworkException();

      expect(await cubit.submitAttendance(), isFalse);
      expect(cubit.lastActionError, contains('internet'));
      expect(
        (cubit.state as SessionDetailLoaded).attendanceSubmitting,
        isFalse,
      );
      // local marks survive the failure
      expect((cubit.state as SessionDetailLoaded).attendance['2'], 'present');
    });

    test('a second tap while submitting is ignored', () async {
      final cubit = build(_Sessions([_session()]));
      await cubit.load();
      attendance.gate = Completer<void>();

      final first = cubit.submitAttendance();
      final second = await cubit.submitAttendance();
      attendance.gate!.complete();

      expect(second, isFalse);
      expect(await first, isTrue);
      expect(attendance.submits, 1);
    });

    test(
      'partial feedback failure keeps sent ones and names failed students',
      () async {
        final cubit = build(_Sessions([_session()]));
        await cubit.load();
        feedback.result = FeedbackSendResult(
          sent: const [
            FeedbackMessage(
              id: 'm1',
              sessionId: 's1',
              studentIds: ['2'],
              message: 'Hi',
            ),
          ],
          failedStudentIds: const ['3'],
        );

        final ok = await cubit.sendFeedback(
          const FeedbackMessage(
            id: '',
            sessionId: 's1',
            studentIds: ['2', '3'],
            message: 'Hi',
          ),
        );

        expect(ok, isFalse);
        expect(cubit.lastFailedStudentIds, ['3']);
        expect(cubit.lastActionError, startsWith('Sent to 1 of 2'));
        expect(
          (cubit.state as SessionDetailLoaded).feedbackMessages,
          hasLength(1),
        );
      },
    );

    test('upload and review errors expose their messages', () async {
      final cubit = build(_Sessions([_session()]));
      await cubit.load();

      expect(await cubit.uploadAttachment(fileName: 'a', bytes: [1]), isNull);
      expect(cubit.lastActionError, contains('too large'));

      final ok = await cubit.saveReview(
        const AssignmentReview(
          id: '',
          sessionId: 's1',
          homeworkId: '1',
          studentId: '2',
          marks: 5,
          reviewText: '',
        ),
      );
      expect(ok, isFalse);
      expect(cubit.lastActionError, contains('internet'));
    });
  });
}
