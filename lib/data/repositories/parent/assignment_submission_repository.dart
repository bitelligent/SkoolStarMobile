import 'dart:async';

import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/mappers/chat_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/parent/assignment_submission.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';

/// A guardian handing in homework for a child: files are uploaded first, then
/// one submit references them.
abstract interface class AssignmentSubmissionRepository {
  /// Ids of the children whose homework was just handed in, so every screen
  /// showing it can refresh.
  Stream<String> get submitted;

  /// Stores one file. Throws [ValidationException] for a file the server
  /// would refuse anyway.
  Future<SubmissionFile> uploadFile({
    required String fileName,
    required List<int> bytes,
  });

  /// Hands the task in and resolves the time it was recorded.
  Future<DateTime> submit({
    required String childId,
    required String taskId,
    String? note,
    List<String> links = const [],
    List<String> fileUrls = const [],
  });
}

class AssignmentSubmissionRepositoryImpl
    implements AssignmentSubmissionRepository {
  AssignmentSubmissionRepositoryImpl({
    required ApiClient apiClient,
    required ChildAssignmentsRepository assignments,
  }) : _api = apiClient,
       _assignments = assignments;

  final ApiClient _api;
  final ChildAssignmentsRepository _assignments;
  final StreamController<String> _submitted = StreamController.broadcast();

  @override
  Stream<String> get submitted => _submitted.stream;

  @override
  Future<SubmissionFile> uploadFile({
    required String fileName,
    required List<int> bytes,
  }) async {
    final problem = SubmissionRules.fileError(fileName, bytes.length);
    if (problem != null) throw ValidationException(problem);

    final json = await _api.postMultipart(
      ApiEndpoints.uploadSubmissionFile,
      files: [UploadFile(field: 'file', filename: fileName, bytes: bytes)],
    );
    final url = json is Json ? json.strOrNull('fileUrl') : null;
    if (url == null) throw const ParseException();
    return SubmissionFile(
      url: url,
      name: (json as Json).str('fileName', fileName),
    );
  }

  @override
  Future<DateTime> submit({
    required String childId,
    required String taskId,
    String? note,
    List<String> links = const [],
    List<String> fileUrls = const [],
  }) async {
    final studentId = int.tryParse(childId);
    if (studentId == null) {
      throw const ValidationException('Please select a child first.');
    }
    final trimmed = note?.trim();
    final json = await _api.post(
      ApiEndpoints.submitAssignment(taskId),
      body: {
        'studentId': studentId,
        'feedback': trimmed == null || trimmed.isEmpty ? null : trimmed,
        'links': links,
        'files': fileUrls,
      },
    );
    final at = parseServerTime(
      json is Json ? json['completedAt'] : null,
      fallback: DateTime.now(),
    );

    // Bring the cached list in line with the server (best effort: the
    // submit itself already succeeded).
    try {
      await _assignments.getForChild(childId, refresh: true);
    } on Object {
      // The screens patch the row themselves.
    }
    if (!_submitted.isClosed) _submitted.add(childId);
    return at;
  }
}
