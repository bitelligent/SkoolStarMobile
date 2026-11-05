/// Every backend path lives here so call sites never hand-build URLs.
class ApiEndpoints {
  ApiEndpoints._();

  static const String _users = '/api/Users';
  static const String _teacher = '/api/TeacherModule';
  static const String _schedules = '/api/Schedules';
  static const String _schools = '/api/Schools';

  // Auth / account
  static const String enhancedLogin = '$_users/enhanced-login';
  static const String myContexts = '$_users/my-contexts';
  static const String selectContext = '$_users/select-context';
  static const String myProfile = '$_users/me/profile';

  static const String manageInfo = '$_users/manage/info';
  static const String myChildren = '$_users/my-children';

  // Parent module
  static const String childAttendance = '$_teacher/children/attendance';
  static const String childAssignments = '$_teacher/children/assignments';
  static const String childProgress = '$_teacher/children/progress';
  static const String childResults = '$_teacher/children/results';

  /// Parent leave requests. Admin routes (list / decide) are web-only.
  static const String leaveMine = '/api/LeaveApplications/mine';
  static const String leaveApplications = '/api/LeaveApplications';
  static String leaveCancel(String id) => '/api/LeaveApplications/$id/cancel';
  static String studentOccurrences(String studentId) =>
      '$_schedules/occurrences/student/$studentId';
  static String studentContactPersons(String studentId) =>
      '/api/StudentContactPersons/by-student/$studentId';

  // Institute branding (white label)
  static String instituteBranding(int instituteId) =>
      '$_schools/$instituteId/branding';

  // Staff
  static String staff(int id) => '/api/Staff/$id';

  // Schedules
  static String teacherSchedules(int staffId) => '$_schedules/teacher/$staffId';
  static String teacherOccurrences(int staffId) =>
      '$_schedules/occurrences/teacher/$staffId';
  static String occurrenceByPublicId(String publicId) =>
      '$_schedules/occurrences/guid/$publicId';

  // Teacher module
  static const String myClasses = '$_teacher/my-classes';
  static const String myStudents = '$_teacher/my-students';
  static String attendanceForClass(int classId) =>
      '$_teacher/attendance/class/$classId';
  static const String markAttendance = '$_teacher/attendance/mark';
  static const String homework = '$_teacher/homework';
  static const String uploadHomeworkAttachment =
      '$_teacher/homework/upload-attachment';

  /// `PUT` edits (title / description / max marks), `DELETE` removes.
  static String homeworkById(String id) => '$_teacher/homework/$id';
  static String homeworkForClass(int classId) =>
      '$_teacher/homework/class/$classId';
  static String reviewSubmission(String taskId) =>
      '$_teacher/homework/$taskId/review';
  static String feedbackTaskStudents(String taskId) =>
      '$_teacher/feedback/task/$taskId/students';
  static const String feedbackConversations =
      '$_teacher/feedback/conversations';
  static const String sendFeedback = '$_teacher/feedback/send';

  /// Subjects the teacher teaches a student's class (picker for feedback).
  static const String feedbackSubjects =
      '$_teacher/weekly-feedback-report/subjects';
  static const String feedbackHistory = '$_teacher/feedback/history';

  /// `PUT` edits, `DELETE` soft-deletes.
  static String feedbackById(String id) => '$_teacher/feedback/$id';
  static String feedbackMessages(String id) =>
      '$_teacher/feedback/$id/messages';
  static String feedbackReply(String id) => '$_teacher/feedback/$id/reply';
  static String feedbackResolve(String id) => '$_teacher/feedback/$id/resolve';
  static String feedbackUnresolve(String id) =>
      '$_teacher/feedback/$id/unresolve';
  static String feedbackRead(String id) => '$_teacher/feedback/$id/read';

  // In-app notifications
  static const String notifications = '/api/Notifications';
  static const String notificationsUnreadCount =
      '/api/Notifications/unread-count';
  static const String notificationsReadAll = '/api/Notifications/read-all';
  static String notificationRead(String id) => '/api/Notifications/$id/read';

  // Direct (1-to-1) chat
  static const String chatThreads = '/api/Chat/threads';
  static String chatMessages(int threadId) =>
      '/api/Chat/threads/$threadId/messages';
  static String chatRead(int threadId) => '/api/Chat/threads/$threadId/read';
}
