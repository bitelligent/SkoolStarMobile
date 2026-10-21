import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/children_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/parent_progress_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_report.dart';

import '../../fixtures/fixtures.dart' as fx;
import '../../helpers/fakes.dart';
import '../chat/chat_fakes.dart';

final progressNow = DateTime(2026, 10, 20, 12);

class FakeKids implements ChildrenRepository {
  @override
  Future<List<Child>> getChildren({bool refresh = false}) async => const [
    Child(id: '3', name: 'Irha', className: 'Class 2'),
    Child(id: '2', name: 'Jannat', className: 'Class 1'),
  ];
}

class FakeAtt implements ChildAttendanceRepository {
  Object? error;

  /// Replaces the default records when set.
  List<ChildAttendanceRecord>? records;
  final List<String> requested = [];

  @override
  Future<List<ChildAttendanceRecord>> getForChild(
    String childId, {
    bool refresh = false,
  }) async {
    requested.add(childId);
    if (error != null) throw error!;
    if (records != null) return records!;
    return [
      for (var i = 1; i <= 4; i++)
        ChildAttendanceRecord(
          childId: childId,
          date: progressNow.subtract(Duration(days: i)),
          status: i == 1 ? 'absent' : 'present',
        ),
    ];
  }
}

class FakeHw implements ChildAssignmentsRepository {
  Object? error;

  /// Replaces the default assignments when set.
  List<ChildAssignment>? items;

  @override
  Future<List<ChildAssignment>> getForChild(
    String childId, {
    bool refresh = false,
  }) async {
    if (error != null) throw error!;
    if (items != null) return items!;
    return [
      ChildAssignment(
        id: 'a',
        childId: childId,
        title: 'Fractions',
        deadline: progressNow.subtract(const Duration(days: 2)),
        isCompleted: true,
        marks: 8,
        maxMarks: 10,
        subjectName: 'Math',
      ),
    ];
  }
}

/// Chat double that serves feedback threads/topics for student 3 only.
class FakeFeedbackChat extends FakeChatRepository {
  Object? error;
  bool noFeedback = false;
  final List<String> topicRequests = [];

  @override
  Future<List<ChatThread>> getByCategory(ChatCategory category) async {
    if (error != null) throw error!;
    if (noFeedback) return [];
    return [
      ChatThread(
        id: 'fb_3_Tahir',
        name: 'Tahir',
        category: ChatCategory.feedback,
        lastMessageAt: progressNow,
      ),
      ChatThread(
        id: 'fb_2_Tahir',
        name: 'Tahir',
        category: ChatCategory.feedback,
        lastMessageAt: progressNow,
      ),
    ];
  }

  @override
  Future<List<FeedbackTopic>> getFeedbackTopicsFor(String threadId) async {
    topicRequests.add(threadId);
    return [
      FeedbackTopic(
        id: threadId,
        threadId: threadId,
        subject: 'For $threadId',
        tone: FeedbackTone.positive,
        createdAt: progressNow.subtract(const Duration(days: 3)),
        messages: [
          FeedbackMessage(
            id: 'm',
            fromTeacher: true,
            content: 'Good',
            sentAt: progressNow.subtract(const Duration(days: 1)),
            isRead: false,
            senderName: 'Tahir',
          ),
        ],
      ),
    ];
  }
}
