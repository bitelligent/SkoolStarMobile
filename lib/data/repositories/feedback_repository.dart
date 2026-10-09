import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/mappers/feedback_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_model.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';

/// Outcome of sending one feedback message to several students (the backend
/// takes one student per request, so some can succeed while others fail).
class FeedbackSendResult {
  const FeedbackSendResult({
    required this.sent,
    required this.failedStudentIds,
  });

  final List<FeedbackMessage> sent;
  final List<String> failedStudentIds;

  bool get allSent => failedStudentIds.isEmpty;
}

abstract interface class FeedbackRepository {
  Future<List<FeedbackMessage>> getMessagesForSession(Session session);

  /// Reviews already given for the session's [homeworks].
  Future<List<AssignmentReview>> getReviews(
    Session session,
    List<Homework> homeworks,
  );

  Future<FeedbackSendResult> sendMessage(
    Session session,
    FeedbackMessage draft,
  );

  Future<AssignmentReview> saveReview(AssignmentReview review);
}

class FeedbackRepositoryImpl implements FeedbackRepository {
  const FeedbackRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<FeedbackMessage>> getMessagesForSession(Session session) async {
    final json = await _api.get(
      ApiEndpoints.feedbackConversations,
      query: {
        'scheduleOccurrencePublicId': session.id,
        'scheduleOccurrenceId': session.occurrenceId,
        'scheduleId': session.scheduleId,
        'sessionDate': dateOnly(session.date),
      },
    );
    return [
      for (final row in asObjects(json))
        ?feedbackFromConversation(row, sessionId: session.id),
    ];
  }

  @override
  Future<List<AssignmentReview>> getReviews(
    Session session,
    List<Homework> homeworks,
  ) async {
    final responses = await Future.wait([
      for (final hw in homeworks)
        _api
            .get(ApiEndpoints.feedbackTaskStudents(hw.id))
            .then((json) => (hw.id, json)),
    ]);
    return [
      for (final (taskId, json) in responses)
        for (final row in asObjects(json))
          ?reviewFromTaskStudent(row, sessionId: session.id, taskId: taskId),
    ];
  }

  @override
  Future<FeedbackSendResult> sendMessage(
    Session session,
    FeedbackMessage draft,
  ) async {
    final sent = <FeedbackMessage>[];
    final failed = <String>[];
    ApiException? firstError;

    for (final studentId in draft.studentIds) {
      try {
        final json = await _api.post(
          ApiEndpoints.sendFeedback,
          body: {
            'studentId': int.tryParse(studentId),
            'content': draft.message.trim(),
            'isPositive': draft.isPositive,
            'scheduleOccurrenceId': session.occurrenceId,
            'scheduleOccurrencePublicId': session.id,
            'scheduleId': session.scheduleId,
            'sessionDate': dateOnly(session.date),
          },
        );
        final id = json is Json
            ? json.strOrNull('feedbackId') ?? json.strOrNull('id')
            : null;
        sent.add(
          draft.copyWith(
            id: id ?? '${DateTime.now().microsecondsSinceEpoch}_$studentId',
            sessionId: session.id,
            studentIds: [studentId],
            message: draft.message.trim(),
            sentAt: DateTime.now(),
          ),
        );
      } on UnauthorizedException {
        rethrow; // Session is gone; stop and let the app sign out.
      } on ApiException catch (e) {
        failed.add(studentId);
        firstError ??= e;
      }
    }

    // Nothing got through: surface the real reason instead of "0 of N".
    if (sent.isEmpty && firstError != null) throw firstError;
    return FeedbackSendResult(sent: sent, failedStudentIds: failed);
  }

  @override
  Future<AssignmentReview> saveReview(AssignmentReview review) async {
    await _api.post(
      ApiEndpoints.reviewSubmission(review.homeworkId),
      body: {
        'studentId': int.tryParse(review.studentId),
        'marks': review.marks,
        'review': review.reviewText.trim(),
      },
    );
    return review.copyWith(
      id: '${review.homeworkId}_${review.studentId}',
      reviewedAt: DateTime.now(),
    );
  }
}
