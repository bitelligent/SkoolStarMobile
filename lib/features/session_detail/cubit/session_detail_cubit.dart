import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/config/attendance_status_config.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_model.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/models/student_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/homework_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';

class SessionDetailCubit extends Cubit<SessionDetailState> {
  SessionDetailCubit({
    required this.sessionId,
    required SessionRepository sessionRepository,
    required ClassRepository classRepository,
    required SubjectRepository subjectRepository,
    required AttendanceRepository attendanceRepository,
    required HomeworkRepository homeworkRepository,
    required FeedbackRepository feedbackRepository,
  }) : _sessionRepository = sessionRepository,
       _classRepository = classRepository,
       _subjectRepository = subjectRepository,
       _attendanceRepository = attendanceRepository,
       _homeworkRepository = homeworkRepository,
       _feedbackRepository = feedbackRepository,
       super(const SessionDetailState.initial());

  final String sessionId;
  final SessionRepository _sessionRepository;
  final ClassRepository _classRepository;
  final SubjectRepository _subjectRepository;
  final AttendanceRepository _attendanceRepository;
  final HomeworkRepository _homeworkRepository;
  final FeedbackRepository _feedbackRepository;

  Future<void> load() async {
    emit(const SessionDetailState.loading());
    try {
      final session = await _sessionRepository.getById(sessionId);
      if (session == null) {
        emit(const SessionDetailState.error('Session not found'));
        return;
      }
      final classes = await _classRepository.getAll();
      final subjects = await _subjectRepository.getAll();
      final sheet = await _attendanceRepository.getSheet(session, classes);
      final homeworks = await _homeworkRepository.getForSession(session);

      // History is secondary: if it fails the session is still usable.
      final messages = await _guarded(
        () => _feedbackRepository.getMessagesForSession(session),
        const <FeedbackMessage>[],
      );
      final reviews = await _guarded(
        () => _feedbackRepository.getReviews(session, homeworks),
        const <AssignmentReview>[],
      );

      emit(
        SessionDetailState.loaded(
          session: session,
          classes: classes,
          subjects: subjects,
          students: sheet.students,
          attendance: {
            for (final st in sheet.students)
              st.id: sheet.statuses[st.id] ?? AttendanceStatusConfig.unmarked,
          },
          homeworks: homeworks,
          feedbackMessages: messages,
          assignmentReviews: reviews,
        ),
      );
    } on Object catch (e, st) {
      emit(SessionDetailState.error(errorMessage(e, st)));
    }
  }

  Future<T> _guarded<T>(Future<T> Function() run, T fallback) async {
    try {
      return await run();
    } on Object {
      return fallback;
    }
  }

  /// Reason for the most recent failed action (`false` return value), shown
  /// by the tabs in their snackbar.
  String lastActionError = 'Failed';

  /// Students that did not receive the last feedback send (partial failure).
  List<String> lastFailedStudentIds = const [];

  void setStudentSearch(String q) {
    final s = state;
    if (s is SessionDetailLoaded) emit(s.copyWith(studentSearch: q));
  }

  void setClassFilter(String classId) {
    final s = state;
    if (s is SessionDetailLoaded) emit(s.copyWith(activeClassFilter: classId));
  }

  void setStatus(String studentId, String status) {
    final s = state;
    if (s is SessionDetailLoaded) {
      final map = Map<String, String>.from(s.attendance);
      map[studentId] = status;
      emit(s.copyWith(attendance: map));
    }
  }

  void markAllPresent() {
    final s = state;
    if (s is SessionDetailLoaded) {
      final map = <String, String>{
        for (final st in s.students) st.id: 'present',
      };
      emit(s.copyWith(attendance: map));
    }
  }

  void clearAttendance() {
    final s = state;
    if (s is SessionDetailLoaded) {
      final map = <String, String>{
        for (final st in s.students) st.id: 'unmarked',
      };
      emit(s.copyWith(attendance: map));
    }
  }

  Future<bool> submitAttendance() async {
    final s = state;
    if (s is! SessionDetailLoaded || s.attendanceSubmitting) return false;
    if (s.session.isLocked) {
      lastActionError = 'This session is locked.';
      return false;
    }
    emit(s.copyWith(attendanceSubmitting: true));
    try {
      await _attendanceRepository.submit(s.session, s.attendance);
      _emitIfLoaded((cur) => cur.copyWith(attendanceSubmitting: false));
      return true;
    } on Object catch (e, st) {
      lastActionError = errorMessage(e, st);
      _emitIfLoaded((cur) => cur.copyWith(attendanceSubmitting: false));
      return false;
    }
  }

  Future<bool> createHomework(Homework draft) async {
    final s = state;
    if (s is! SessionDetailLoaded) return false;
    try {
      final created = await _homeworkRepository.create(s.session, draft);
      _emitIfLoaded(
        (cur) => cur.copyWith(homeworks: [...cur.homeworks, created]),
      );
      return true;
    } on Object catch (e, st) {
      lastActionError = errorMessage(e, st);
      return false;
    }
  }

  Future<HomeworkAttachment?> uploadAttachment({
    required String fileName,
    required List<int> bytes,
  }) async {
    try {
      return await _homeworkRepository.uploadAttachment(
        fileName: fileName,
        bytes: bytes,
      );
    } on Object catch (e, st) {
      lastActionError = errorMessage(e, st);
      return null;
    }
  }

  /// Sends [draft] to each selected student. Returns `true` only when every
  /// send succeeded; on partial failure [lastActionError] names the count.
  Future<bool> sendFeedback(FeedbackMessage draft) async {
    final s = state;
    if (s is! SessionDetailLoaded) return false;
    try {
      lastFailedStudentIds = const [];
      final result = await _feedbackRepository.sendMessage(s.session, draft);
      _emitIfLoaded(
        (cur) => cur.copyWith(
          feedbackMessages: [...cur.feedbackMessages, ...result.sent],
        ),
      );
      if (!result.allSent) {
        lastFailedStudentIds = result.failedStudentIds;
        lastActionError =
            'Sent to ${result.sent.length} of ${draft.studentIds.length}. '
            "${result.failedStudentIds.length} failed - try again for those.";
      }
      return result.allSent;
    } on Object catch (e, st) {
      lastActionError = errorMessage(e, st);
      return false;
    }
  }

  Future<bool> saveReview(AssignmentReview draft) async {
    final s = state;
    if (s is! SessionDetailLoaded) return false;
    try {
      final saved = await _feedbackRepository.saveReview(draft);
      _emitIfLoaded(
        (cur) => cur.copyWith(
          assignmentReviews: [
            ...cur.assignmentReviews.where(
              (r) =>
                  !(r.homeworkId == saved.homeworkId &&
                      r.studentId == saved.studentId),
            ),
            saved,
          ],
        ),
      );
      return true;
    } on Object catch (e, st) {
      lastActionError = errorMessage(e, st);
      return false;
    }
  }

  /// Re-reads the latest state after an `await`, so a result is never applied
  /// on top of a stale snapshot (or after the screen was closed).
  void _emitIfLoaded(
    SessionDetailLoaded Function(SessionDetailLoaded) update,
  ) {
    if (isClosed) return;
    final cur = state;
    if (cur is SessionDetailLoaded) emit(update(cur));
  }

  List<Student> filteredStudents() {
    final s = state;
    if (s is! SessionDetailLoaded) return const [];
    var list = List<Student>.from(s.students);
    if (s.activeClassFilter.isNotEmpty) {
      list = list
          .where((st) => st.classGroupId == s.activeClassFilter)
          .toList();
    }
    if (s.studentSearch.trim().isNotEmpty) {
      final q = s.studentSearch.toLowerCase();
      list = list
          .where(
            (st) => '${st.firstName} ${st.lastName}'.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  int get savedCount {
    final s = state;
    if (s is! SessionDetailLoaded) return 0;
    return s.attendance.values.where((v) => v != 'unmarked').length;
  }
}
