import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skoolstar_teacher_module/data/models/parent/assignment_submission.dart';

/// A file the user chose but has not uploaded yet. The bytes are only read
/// when needed, so several large files are never held in memory together.
class PickedAttachment {
  const PickedAttachment({
    required this.name,
    required this.size,
    required this.read,
  });

  final String name;
  final int size;
  final Future<List<int>> Function() read;

  /// Two picks of the same file (same name and size) are the same file.
  bool sameAs(PickedAttachment other) =>
      other.name == name && other.size == size;
}

/// The device could not provide a file; [message] is fit to show.
class AttachmentPickException implements Exception {
  const AttachmentPickException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Where hand-in files come from. Behind an interface so the flow can be
/// tested without a camera or a file browser.
abstract interface class AttachmentPicker {
  /// Documents and images from the file browser. Empty when cancelled.
  Future<List<PickedAttachment>> pickFiles();

  /// Photos from the library. Empty when cancelled.
  Future<List<PickedAttachment>> pickPhotos({required int max});

  /// A new photo from the camera, or `null` when cancelled.
  Future<PickedAttachment?> takePhoto();
}

class DeviceAttachmentPicker implements AttachmentPicker {
  DeviceAttachmentPicker({ImagePicker? imagePicker})
    : _images = imagePicker ?? ImagePicker();

  final ImagePicker _images;

  // Phone photos are several MB; this keeps pages readable and well under the
  // 15 MB limit.
  static const _maxSide = 2400.0;
  static const _quality = 85;

  @override
  Future<List<PickedAttachment>> pickFiles() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: SubmissionRules.allowedExtensions,
    );
    return [
      for (final f in picked)
        PickedAttachment(
          name: f.name,
          size: await f.length() ?? 0,
          read: f.readAsBytes,
        ),
    ];
  }

  @override
  Future<List<PickedAttachment>> pickPhotos({required int max}) async {
    if (max <= 0) return const [];
    try {
      final photos = await _images.pickMultiImage(
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
        limit: max,
      );
      return [for (final p in photos) await _fromXFile(p)];
    } on PlatformException catch (e) {
      throw _explain(e, 'photos');
    }
  }

  @override
  Future<PickedAttachment?> takePhoto() async {
    try {
      final photo = await _images.pickImage(
        source: ImageSource.camera,
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
      );
      if (photo == null) return null;
      final stamp = DateTime.now().millisecondsSinceEpoch;
      return _fromXFile(photo, name: 'photo-$stamp.jpg');
    } on PlatformException catch (e) {
      throw _explain(e, 'camera');
    }
  }

  Future<PickedAttachment> _fromXFile(XFile file, {String? name}) async =>
      PickedAttachment(
        name: name ?? file.name,
        size: await file.length(),
        read: file.readAsBytes,
      );

  AttachmentPickException _explain(PlatformException e, String what) {
    final denied = e.code.contains('access_denied');
    if (denied) {
      return AttachmentPickException(
        what == 'camera'
            ? 'Allow camera access in Settings to take a photo.'
            : 'Allow photo access in Settings to choose a photo.',
      );
    }
    return AttachmentPickException(
      what == 'camera'
          ? "The camera isn't available on this device."
          : "Couldn't open your photos. Please try again.",
    );
  }
}
