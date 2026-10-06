import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_model.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/models/student_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/homework_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/student_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';

class SessionDetailCubit extends Cubit<SessionDetailState> {
  SessionDetailCubit({
    required this.sessionId,
    required SessionRepository sessionRepository,
    required ClassRepository classRepository,
    required SubjectRepository subjectRepository,
    required StudentRepository studentRepository,
    required AttendanceRepository attendanceRepository,
    required HomeworkRepository homeworkRepository,
    required FeedbackRepository feedbackRepository,
  })  : _sessionRepository = sessionRepository,
        _classRepository = classRepository,
        _subjectRepository = subjectRepository,
        _studentRepository = studentRepository,
        _attendanceRepository = attendanceRepository,
        _homeworkRepository = homeworkRepository,
        _feedbackRepository = feedbackRepository,
        super(const SessionDetailState.initial());

  final String sessionId;
  final SessionRepository _sessionRepository;
  final ClassRepository _classRepository;
  final SubjectRepository _subjectRepository;
  final StudentRepository _studentRepository;
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
      final students =
          await _studentRepository.getByClassIds(session.classIds);
      final attendance =
          await _attendanceRepository.getForSession(sessionId);
      final homeworks = await _homeworkRepository.getForSession(sessionId);
      final messages =
          await _feedbackRepository.getMessagesForSession(sessionId);
      final reviews =
          await _feedbackRepository.getReviewsForSession(sessionId);

      emit(
        SessionDetailState.loaded(
          session: session,
          classes: classes,
          subjects: subjects,
          students: students,
          attendance: {for (final s in students) s.id: attendance[s.id] ?? 'unmarked'},
          homeworks: homeworks,
          feedbackMessages: messages,
          assignmentReviews: reviews,
        ),
      );
    } on Exception catch (e) {
      emit(SessionDetailState.error(e.toString()));
    }
  }

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
    if (s is! SessionDetailLoaded) return false;
    emit(s.copyWith(attendanceSubmitting: true));
    try {
      await _attendanceRepository.submit(
        sessionId: sessionId,
        studentIdToStatus: s.attendance,
      );
      emit(s.copyWith(attendanceSubmitting: false));
      return true;
    } on Exception {
      emit(s.copyWith(attendanceSubmitting: false));
      return false;
    }
  }

  Future<bool> createHomework(Homework draft) async {
    final s = state;
    if (s is! SessionDetailLoaded) return false;
    try {
      final created = await _homeworkRepository.create(draft);
      final updated = List<Homework>.from(s.homeworks)..add(created);
      emit(s.copyWith(homeworks: updated));
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> sendFeedback(FeedbackMessage draft) async {
    final s = state;
    if (s is! SessionDetailLoaded) return false;
    try {
      final sent = await _feedbackRepository.sendMessage(draft);
      final updated = List<FeedbackMessage>.from(s.feedbackMessages)..add(sent);
      emit(s.copyWith(feedbackMessages: updated));
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> saveReview(AssignmentReview draft) async {
    final s = state;
    if (s is! SessionDetailLoaded) return false;
    try {
      final saved = await _feedbackRepository.saveReview(draft);
      final updated = List<AssignmentReview>.from(s.assignmentReviews)
        ..add(saved);
      emit(s.copyWith(assignmentReviews: updated));
      return true;
    } on Exception {
      return false;
    }
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
            (st) => '${st.firstName} ${st.lastName}'
                .toLowerCase()
                .contains(q),
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
