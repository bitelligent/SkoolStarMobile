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

/// Deliberately awkward data (long names, many items) so layout tests catch
/// text that doesn't fit.
final stressClasses = [
  for (var i = 1; i <= 4; i++)
    ClassGroup(
      id: '$i',
      name: 'Grade ${i + 6} - Section Alpha (Evening Batch)',
      studentCount: i,
    ),
];

const stressSubjects = [
  Subject(id: '1', name: 'Computer Science & Programming'),
  Subject(id: '2', name: 'English Literature'),
  Subject(id: '3', name: 'Mathematics'),
];

Session stressSession(String id, DateTime date, {String start = '09:00'}) =>
    Session(
      id: id,
      date: DateTime(date.year, date.month, date.day),
      startTime: start,
      endTime: '23:59',
      classIds: const ['1', '2', '3', '4'],
      subjectIds: const ['1', '2', '3'],
      teacherId: '3',
      occurrenceId: 1,
      scheduleId: 1,
    );

final stressStudents = [
  for (var i = 0; i < 12; i++)
    Student(
      id: '$i',
      firstName: 'Muhammad Abdul-Rahman$i',
      lastName: 'Al-Farsi Bin Abdullah',
      classGroupId: '${i % 4 + 1}',
    ),
];

class FakeInstitutes implements InstituteRepository {
  @override
  Future<InstituteInfo> getCurrent() async => const InstituteInfo(
    id: '8',
    name: 'International School of Languages & Academic Centre',
    type: 'TUITION CENTER',
  );
}

class FakeUsers implements UserRepository {
  @override
  Future<UserModel> getCurrentUser() async => const UserModel(
    id: '3',
    firstName: 'Muhammad Abdul-Rahman',
    lastName: 'Al-Farsi Bin Abdullah',
    email: 'a.very.long.teacher.email.address@some-long-school-domain.edu.pk',
  );

  @override
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    String? currentPassword,
    String? newPassword,
  }) async => throw UnimplementedError();
}

class FakeSessionsRepo implements SessionRepository {
  FakeSessionsRepo(this.items);
  final List<Session> items;

  @override
  Future<List<Session>> getBetween(
    DateTime from,
    DateTime to, {
    bool refresh = false,
  }) async => items;

  @override
  Future<Session?> getById(String id) async =>
      items.where((s) => s.id == id).firstOrNull;
}

class FakeClassesRepo implements ClassRepository {
  @override
  Future<List<ClassGroup>> getAll() async => stressClasses;
}

class FakeSubjectsRepo implements SubjectRepository {
  @override
  Future<List<Subject>> getAll() async => stressSubjects;
}

class FakeNotificationsRepo implements NotificationsRepository {
  @override
  Future<NotificationsData> getNotifications() async =>
      const NotificationsData(items: []);
}

class FakeAttendanceRepo implements AttendanceRepository {
  @override
  Future<AttendanceSheet> getSheet(
    Session session,
    List<ClassGroup> classes,
  ) async => AttendanceSheet(
    students: stressStudents,
    statuses: {for (final s in stressStudents) s.id: 'unmarked'},
  );

  @override
  Future<void> submit(Session session, Map<String, String> statuses) async {}
}

class FakeHomeworkRepo implements HomeworkRepository {
  @override
  Uri? attachmentUrl(HomeworkAttachment attachment) => null;

  @override
  Future<Map<String, String>> attachmentHeaders() async => {};

  @override
  Future<List<Homework>> getForSession(Session session) async => [
    Homework(
      id: '1',
      sessionId: session.id,
      classId: '1',
      subjectId: '1',
      title: 'Chapter 3 - Algorithms and Flowcharts: practice worksheet',
      description:
          'Solve every question in the worksheet and upload a clear photo '
          'of your work before the deadline. Late work loses marks.',
      deadline: DateTime(2026, 12, 31, 23, 59),
      maxMarks: 100,
      assignedCount: 128,
      attachments: const [
        HomeworkAttachment(
          fileName: 'a-really-long-worksheet-file-name-final-v2.pdf',
          sizeKb: 2048,
          type: 'pdf',
          reference: '/uploads/x.pdf',
        ),
      ],
    ),
  ];

  @override
  Future<Homework> create(Session session, Homework draft) async => draft;

  @override
  Future<HomeworkAttachment> uploadAttachment({
    required String fileName,
    required List<int> bytes,
  }) => throw UnimplementedError();
}

class FakeFeedbackRepo implements FeedbackRepository {
  @override
  Future<List<FeedbackMessage>> getMessagesForSession(Session s) async => [];

  @override
  Future<List<AssignmentReview>> getReviews(
    Session session,
    List<Homework> homeworks,
  ) async => [];

  @override
  Future<FeedbackSendResult> sendMessage(
    Session session,
    FeedbackMessage draft,
  ) => throw UnimplementedError();

  @override
  Future<AssignmentReview> saveReview(AssignmentReview review) =>
      throw UnimplementedError();
}
