import 'package:flutter/foundation.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/mappers/homework_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';

/// Largest attachment accepted before uploading.
const maxAttachmentBytes = 15 * 1024 * 1024;

abstract interface class HomeworkRepository {
  Future<List<Homework>> getForSession(Session session);

  /// Creates [draft] for [session]. Attachments must already be uploaded
  /// (see [uploadAttachment]); their `reference` is sent to the server.
  Future<Homework> create(Session session, Homework draft);

  /// Full URL of an attachment, or `null` when the server gave no usable
  /// reference.
  Uri? attachmentUrl(HomeworkAttachment attachment);

  /// Auth headers for fetching an attachment that needs the session token.
  Future<Map<String, String>> attachmentHeaders();

  /// Uploads a file and returns it with its server `reference` filled in.
  Future<HomeworkAttachment> uploadAttachment({
    required String fileName,
    required List<int> bytes,
  });
}

class HomeworkRepositoryImpl implements HomeworkRepository {
  const HomeworkRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Uri? attachmentUrl(HomeworkAttachment attachment) =>
      _api.resolveFileUrl(attachment.reference);

  @override
  Future<Map<String, String>> attachmentHeaders() => _api.authHeaders();

  @override
  Future<List<Homework>> getForSession(Session session) async {
    final responses = await Future.wait([
      for (final classId in session.classIds.map(int.tryParse).whereType<int>())
        _api
            .get(
              ApiEndpoints.homeworkForClass(classId),
              query: {
                'scheduleOccurrencePublicId': session.id,
                'scheduleOccurrenceId': session.occurrenceId,
                'scheduleId': session.scheduleId,
                'sessionDate': dateOnly(session.date),
              },
            )
            .then((json) => (classId, json)),
    ]);

    final byId = <String, Homework>{};
    for (final (classId, json) in responses) {
      for (final row in asObjects(json)) {
        final hw = homeworkFromJson(
          row,
          sessionId: session.id,
          classId: '$classId',
          fallbackDeadline: session.date,
        );
        if (hw != null) byId.putIfAbsent(hw.id, () => hw);
      }
    }
    return byId.values.toList()
      ..sort((a, b) => b.deadline.compareTo(a.deadline));
  }

  @override
  Future<Homework> create(Session session, Homework draft) async {
    final json = await _api.post(
      ApiEndpoints.homework,
      body: {
        'classId': int.tryParse(draft.classId),
        'subjectId': int.tryParse(draft.subjectId),
        'sectionId': session.sectionId,
        'title': draft.title.trim(),
        'description': draft.description.trim(),
        'deadline': draft.deadline.toIso8601String(),
        'maxMarks': draft.maxMarks,
        'studentIds': draft.assignedStudentIds
            .map(int.tryParse)
            .whereType<int>()
            .toList(),
        'attachments': [
          for (final a in draft.attachments)
            if (a.reference.isNotEmpty) a.reference,
        ],
        'links': <String>[],
        'scheduleOccurrenceId': session.occurrenceId,
        'scheduleOccurrencePublicId': session.id,
        'scheduleId': session.scheduleId,
        'sessionDate': dateOnly(session.date),
      },
    );

    // The response body is undocumented. Use its id when present, otherwise
    // re-read the list so the UI shows the server's version.
    final id = json is Json
        ? json.strOrNull('taskId') ?? json.strOrNull('id')
        : null;
    if (id != null) return draft.copyWith(id: id, sessionId: session.id);

    final fresh = await getForSession(session);
    final match = fresh.where((h) => h.title == draft.title.trim()).firstOrNull;
    return match ?? draft.copyWith(sessionId: session.id);
  }

  @override
  Future<HomeworkAttachment> uploadAttachment({
    required String fileName,
    required List<int> bytes,
  }) async {
    if (bytes.length > maxAttachmentBytes) {
      throw const ValidationException('File is too large (max 15 MB).');
    }
    final json = await _api.postMultipart(
      ApiEndpoints.uploadHomeworkAttachment,
      files: [UploadFile(field: 'file', filename: fileName, bytes: bytes)],
    );

    final parsed = parseUploadResponse(json);
    if (parsed == null) {
      // The file may be stored, but without its location the homework could
      // never show it. Fail now instead of saving a dead reference.
      throw const ParseException(
        "The file was uploaded but the server didn't say where it is stored. "
        'Please try again.',
      );
    }

    return HomeworkAttachment(
      fileName: parsed.fileName ?? fileName,
      sizeKb: (bytes.length / 1024).ceil(),
      type: fileName.contains('.')
          ? fileName.split('.').last.toLowerCase()
          : '',
      reference: parsed.location,
    );
  }
}

/// Keys the upload endpoint may use for the stored file's location, best
/// first. The live server returns `{"fileUrl": "/uploads/...", "fileName":
/// "<original name>"}`.
const _locationKeys = [
  'fileUrl',
  'url',
  'filePath',
  'path',
  'location',
  'link',
];

/// Extracts the stored location (and display name) from an upload response.
/// Returns `null` when no location can be found. The original `fileName` is
/// never used as a location: it is not a place the file can be fetched from.
@visibleForTesting
({String location, String? fileName})? parseUploadResponse(Object? json) {
  if (json is String) {
    final location = json.trim();
    return location.isEmpty ? null : (location: location, fileName: null);
  }
  if (json is! Json) return null;

  for (final key in _locationKeys) {
    final value = json.strOrNull(key);
    if (value != null) {
      return (location: value, fileName: json.strOrNull('fileName'));
    }
  }
  // Unknown key: accept a value that clearly looks like a server path.
  for (final entry in json.entries) {
    final value = entry.value;
    if (value is String &&
        (value.startsWith('/') ||
            value.contains('://') ||
            value.contains('/uploads/'))) {
      return (location: value, fileName: json.strOrNull('fileName'));
    }
  }
  return null;
}
