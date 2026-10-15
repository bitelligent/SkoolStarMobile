import 'dart:async';

import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_model.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/homework_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_cubit.dart';

import 'repo_fakes.dart';

/// Builds a loaded [SessionDetailCubit] around [repo] for widget tests.
Future<SessionDetailCubit> buildDetailCubit(RecordingHomeworkRepo repo) async {
  final now = DateTime.now();
  final cubit = SessionDetailCubit(
    sessionId: 's1',
    sessionRepository: _OneSession(
      Session(
        id: 's1',
        date: DateTime(now.year, now.month, now.day),
        startTime: '09:00',
        endTime: '10:00',
        classIds: const ['23'],
        subjectIds: const ['18'],
        teacherId: '3',
        occurrenceId: 1,
        scheduleId: 1,
      ),
    ),
    classRepository: _Classes(),
    subjectRepository: _Subjects(),
    attendanceRepository: FakeAttendanceRepo(),
    homeworkRepository: repo,
    feedbackRepository: _NoFeedback(),
  );
  await cubit.load();
  return cubit;
}

class _OneSession implements SessionRepository {
  _OneSession(this.session);
  final Session session;

  @override
  Future<List<Session>> getBetween(
    DateTime from,
    DateTime to, {
    bool refresh = false,
  }) async => [session];

  @override
  Future<Session?> getById(String id) async => session;
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

class _NoFeedback implements FeedbackRepository {
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

/// In-memory homework repository that records edit / delete calls and can be
/// told to fail or to wait.
class RecordingHomeworkRepo implements HomeworkRepository {
  RecordingHomeworkRepo(this.items);
  final List<Homework> items;

  Object? updateError;
  Object? deleteError;
  Completer<void>? updateGate;
  int updateCalls = 0;
  int deleteCalls = 0;
  (String, String, String, int?)? lastUpdate;

  @override
  Future<List<Homework>> getForSession(Session session) async => items;

  @override
  Future<void> update(
    String id, {
    required String title,
    required String description,
    int? maxMarks,
  }) async {
    updateCalls++;
    lastUpdate = (id, title.trim(), description.trim(), maxMarks);
    await updateGate?.future;
    if (updateError != null) throw updateError!;
  }

  @override
  Future<void> delete(String id) async {
    deleteCalls++;
    if (deleteError != null) throw deleteError!;
  }

  @override
  Future<Homework> create(Session session, Homework draft) async => draft;

  @override
  Uri? attachmentUrl(HomeworkAttachment attachment) => null;

  @override
  Future<Map<String, String>> attachmentHeaders() async => {};

  @override
  Future<HomeworkAttachment> uploadAttachment({
    required String fileName,
    required List<int> bytes,
  }) => throw UnimplementedError();
}
