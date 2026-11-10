import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/data/mappers/feedback_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';

/// Subjects a teacher can attach to a feedback message.
abstract interface class FeedbackSubjectsRepository {
  /// Subjects this teacher teaches that every one of [studentIds] studies,
  /// sorted by name. Empty when no student is given. The backend takes one
  /// student per call, so several students are intersected here (same as the
  /// web app).
  Future<List<Subject>> commonFor(Iterable<String> studentIds);
}

class FeedbackSubjectsRepositoryImpl implements FeedbackSubjectsRepository {
  const FeedbackSubjectsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<Subject>> commonFor(Iterable<String> studentIds) async {
    final ids = studentIds.toSet();
    if (ids.isEmpty) return const [];
    final perStudent = await Future.wait([
      for (final id in ids)
        _api
            .get(ApiEndpoints.feedbackSubjects, query: {'studentId': id})
            .then(feedbackSubjectsFromJson),
    ]);
    return commonSubjects(perStudent);
  }
}
