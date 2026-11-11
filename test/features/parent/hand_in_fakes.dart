import 'dart:async';

import 'package:skoolstar_teacher_module/core/utils/attachment_picker.dart';
import 'package:skoolstar_teacher_module/data/models/parent/assignment_submission.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/assignment_submission_repository.dart';

PickedAttachment file(String name, {int size = 1000, bool readFails = false}) =>
    PickedAttachment(
      name: name,
      size: size,
      read: () async {
        if (readFails) throw Exception('gone');
        return List.filled(size.clamp(0, 16), 1);
      },
    );

class FakeSubmissionRepo implements AssignmentSubmissionRepository {
  final StreamController<String> _submitted = StreamController.broadcast();
  final List<String> uploads = [];
  final List<
    ({
      String childId,
      String taskId,
      String? note,
      List<String> links,
      List<String> fileUrls,
    })
  >
  submits = [];

  /// Per file name: what its upload throws.
  final Map<String, Object> uploadErrors = {};
  Object? submitError;

  /// Holds every call until completed.
  Completer<void>? gate;
  final DateTime completedAt = DateTime(2026, 11, 10, 19, 15);

  @override
  Stream<String> get submitted => _submitted.stream;

  void emitSubmitted(String childId) => _submitted.add(childId);

  @override
  Future<SubmissionFile> uploadFile({
    required String fileName,
    required List<int> bytes,
  }) async {
    uploads.add(fileName);
    await gate?.future;
    final error = uploadErrors[fileName];
    if (error != null) throw error;
    return SubmissionFile(url: '/uploads/$fileName', name: fileName);
  }

  @override
  Future<DateTime> submit({
    required String childId,
    required String taskId,
    String? note,
    List<String> links = const [],
    List<String> fileUrls = const [],
  }) async {
    await gate?.future;
    if (submitError != null) throw submitError!;
    submits.add((
      childId: childId,
      taskId: taskId,
      note: note,
      links: links,
      fileUrls: fileUrls,
    ));
    return completedAt;
  }
}

class FakePicker implements AttachmentPicker {
  List<PickedAttachment> files = [];
  List<PickedAttachment> photos = [];
  PickedAttachment? camera;
  Object? error;
  int? lastPhotoMax;

  @override
  Future<List<PickedAttachment>> pickFiles() async {
    if (error != null) throw error!;
    return files;
  }

  @override
  Future<List<PickedAttachment>> pickPhotos({required int max}) async {
    lastPhotoMax = max;
    if (error != null) throw error!;
    return photos;
  }

  @override
  Future<PickedAttachment?> takePhoto() async {
    if (error != null) throw error!;
    return camera;
  }
}
