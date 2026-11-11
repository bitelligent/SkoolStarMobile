import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/core/bloc/safe_cubit.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/core/utils/attachment_picker.dart';
import 'package:skoolstar_teacher_module/data/models/parent/assignment_submission.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/assignment_submission_repository.dart';

part 'hand_in_cubit.freezed.dart';

enum UploadStatus { waiting, uploading, uploaded, failed }

/// One chosen file and how far it got.
@freezed
abstract class HandInFile with _$HandInFile {
  const factory HandInFile({
    required int id,
    required PickedAttachment source,
    @Default(UploadStatus.waiting) UploadStatus status,

    /// Set once the server has stored it; kept across retries so a file is
    /// never uploaded twice.
    SubmissionFile? stored,

    /// Why the upload failed.
    String? error,
  }) = _HandInFile;
}

@freezed
abstract class HandInState with _$HandInState {
  const HandInState._();

  const factory HandInState({
    @Default(<HandInFile>[]) List<HandInFile> files,
    @Default(<String>[]) List<String> links,
    @Default('') String note,

    /// Uploading or submitting: nothing may change meanwhile.
    @Default(false) bool busy,

    /// Something the guardian should read, e.g. why a file was refused.
    String? error,

    /// Set once the server recorded the hand-in.
    DateTime? completedAt,
  }) = _HandInState;

  bool get done => completedAt != null;

  /// Nothing typed, attached or linked yet.
  bool get isBlank => note.trim().isEmpty && files.isEmpty && links.isEmpty;

  bool get canAddFile => files.length < SubmissionRules.maxFiles;
  bool get canAddLink => links.length < SubmissionRules.maxLinks;

  /// "Uploading 2 of 3…" while files go up, else a generic label.
  String get progressLabel {
    final total = files.length;
    final uploading = files.indexWhere(
      (f) => f.status == UploadStatus.uploading,
    );
    return uploading < 0
        ? 'Handing in…'
        : 'Uploading ${uploading + 1} of $total…';
  }
}

/// Collects the guardian's note, links and files for one assignment and hands
/// them in: every file is uploaded first and a single submit references them.
class HandInCubit extends SafeCubit<HandInState> {
  HandInCubit({
    required AssignmentSubmissionRepository repository,
    required AttachmentPicker picker,
    required this.childId,
    required this.taskId,
  }) : _repository = repository,
       _picker = picker,
       super(const HandInState());

  final AssignmentSubmissionRepository _repository;
  final AttachmentPicker _picker;
  final String childId;
  final String taskId;
  int _nextId = 0;

  // ─── editing ────────────────────────────────────────────────────────

  void setNote(String note) {
    if (state.busy) return;
    emit(state.copyWith(note: note));
  }

  void clearError() {
    if (state.error != null) emit(state.copyWith(error: null));
  }

  Future<void> pickFiles() => _pick(() => _picker.pickFiles());

  Future<void> pickPhotos() => _pick(
    () => _picker.pickPhotos(
      max: SubmissionRules.maxFiles - state.files.length,
    ),
  );

  Future<void> takePhoto() => _pick(() async {
    final photo = await _picker.takePhoto();
    return [?photo];
  });

  Future<void> _pick(Future<List<PickedAttachment>> Function() choose) async {
    if (state.busy) return;
    if (!state.canAddFile) {
      emit(
        state.copyWith(
          error: 'You can attach up to ${SubmissionRules.maxFiles} files.',
        ),
      );
      return;
    }
    try {
      add(await choose());
    } on AttachmentPickException catch (e) {
      emit(state.copyWith(error: e.message));
    } on Object catch (e, st) {
      emit(state.copyWith(error: errorMessage(e, st)));
    }
  }

  /// Adds what fits and explains what did not: unsupported or oversized
  /// files, files already chosen and anything beyond the limit.
  void add(List<PickedAttachment> picked) {
    final files = [...state.files];
    final problems = <String>[];
    var skippedForRoom = 0;
    for (final p in picked) {
      if (files.any((f) => f.source.sameAs(p))) continue;
      final problem = SubmissionRules.fileError(p.name, p.size);
      if (problem != null) {
        problems.add(problem);
      } else if (files.length >= SubmissionRules.maxFiles) {
        skippedForRoom++;
      } else {
        files.add(HandInFile(id: _nextId++, source: p));
      }
    }
    if (skippedForRoom > 0) {
      problems.add('Only ${SubmissionRules.maxFiles} files can be attached.');
    }
    emit(
      state.copyWith(
        files: files,
        error: problems.isEmpty ? null : problems.take(3).join('\n'),
      ),
    );
  }

  void removeFile(int id) {
    if (state.busy) return;
    emit(
      state.copyWith(
        files: [
          for (final f in state.files)
            if (f.id != id) f,
        ],
        error: null,
      ),
    );
  }

  /// Adds a link. Resolves why it was refused, or `null` when it was added.
  String? addLink(String raw) {
    if (state.busy) return null;
    if (!state.canAddLink) {
      return 'You can add up to ${SubmissionRules.maxLinks} links.';
    }
    final link = SubmissionRules.normalizeLink(raw);
    if (link == null) return 'Enter a valid web address.';
    if (state.links.any((l) => l.toLowerCase() == link.toLowerCase())) {
      return 'That link is already added.';
    }
    emit(state.copyWith(links: [...state.links, link], error: null));
    return null;
  }

  void removeLink(String link) {
    if (state.busy) return;
    emit(
      state.copyWith(
        links: [
          for (final l in state.links)
            if (l != link) l,
        ],
      ),
    );
  }

  // ─── hand in ────────────────────────────────────────────────────────

  /// Uploads the files, then submits once. If anything fails nothing is
  /// handed in; files already stored are reused on the next attempt.
  Future<void> submit() async {
    if (state.busy || state.done) return;
    emit(state.copyWith(busy: true, error: null));

    for (final file in state.files) {
      if (file.stored != null) continue;
      _patch(file.id, status: UploadStatus.uploading);
      final failure = await _upload(file);
      if (failure != null) {
        _patch(file.id, status: UploadStatus.failed, error: failure);
        emit(
          state.copyWith(
            busy: false,
            error:
                "Couldn't upload ${file.source.name}. $failure "
                'Nothing was handed in.',
          ),
        );
        return;
      }
    }

    try {
      final at = await _repository.submit(
        childId: childId,
        taskId: taskId,
        note: state.note,
        links: state.links,
        fileUrls: [for (final f in state.files) f.stored!.url],
      );
      emit(state.copyWith(busy: false, completedAt: at));
    } on Object catch (e, st) {
      emit(state.copyWith(busy: false, error: errorMessage(e, st)));
    }
  }

  /// Uploads [file]; resolves why it failed, or `null` when it is stored.
  Future<String?> _upload(HandInFile file) async {
    final List<int> bytes;
    try {
      bytes = await file.source.read();
    } on Object {
      return "The file couldn't be read.";
    }
    try {
      final stored = await _repository.uploadFile(
        fileName: file.source.name,
        bytes: bytes,
      );
      _patch(file.id, status: UploadStatus.uploaded, stored: stored);
      return null;
    } on Object catch (e, st) {
      return errorMessage(e, st);
    }
  }

  void _patch(
    int id, {
    required UploadStatus status,
    SubmissionFile? stored,
    String? error,
  }) {
    emit(
      state.copyWith(
        files: [
          for (final f in state.files)
            if (f.id == id)
              f.copyWith(
                status: status,
                stored: stored ?? f.stored,
                error: error,
              )
            else
              f,
        ],
      ),
    );
  }
}
