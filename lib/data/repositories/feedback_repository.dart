import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_model.dart';

abstract class FeedbackRepository {
  Future<List<FeedbackMessage>> getMessagesForSession(String sessionId);
  Future<List<AssignmentReview>> getReviewsForSession(String sessionId);
  Future<FeedbackMessage> sendMessage(FeedbackMessage message);
  Future<AssignmentReview> saveReview(AssignmentReview review);
}

class FeedbackRepositoryImpl implements FeedbackRepository {
  FeedbackRepositoryImpl(this._dataSource);

  final JsonDataSource _dataSource;
  final List<FeedbackMessage> _messages = [];
  final List<AssignmentReview> _reviews = [];
  bool _seeded = false;

  Future<void> _seed() async {
    if (_seeded) return;
    final data = await _dataSource.readJsonObject(
      'assets/json/feedbacks.json',
    );
    final messages = (data['messages'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(FeedbackMessage.fromJson)
        .toList();
    final reviews = (data['assignmentReviews'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(AssignmentReview.fromJson)
        .toList();
    _messages.addAll(messages);
    _reviews.addAll(reviews);
    _seeded = true;
  }

  @override
  Future<List<FeedbackMessage>> getMessagesForSession(String sessionId) async {
    await _seed();
    return _messages.where((m) => m.sessionId == sessionId).toList();
  }

  @override
  Future<List<AssignmentReview>> getReviewsForSession(String sessionId) async {
    await _seed();
    return _reviews.where((r) => r.sessionId == sessionId).toList();
  }

  @override
  Future<FeedbackMessage> sendMessage(FeedbackMessage message) async {
    await _seed();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final created = message.copyWith(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      sentAt: DateTime.now(),
    );
    _messages.add(created);
    return created;
  }

  @override
  Future<AssignmentReview> saveReview(AssignmentReview review) async {
    await _seed();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final created = review.copyWith(
      id: 'rv_${DateTime.now().millisecondsSinceEpoch}',
      reviewedAt: DateTime.now(),
    );
    _reviews.add(created);
    return created;
  }
}
