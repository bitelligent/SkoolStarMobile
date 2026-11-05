import 'package:flutter/foundation.dart';
import 'package:skoolstar_teacher_module/core/bloc/safe_cubit.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_subjects_repository.dart';

@immutable
class FeedbackSubjectsState {
  const FeedbackSubjectsState({
    this.subjects = const [],
    this.loading = false,
    this.error,
  });

  final List<Subject> subjects;
  final bool loading;

  /// Why the list could not be loaded; the picker offers a retry.
  final String? error;

  bool get failed => error != null;
}

/// Subjects the teacher can tag a feedback with, for the chosen students.
class FeedbackSubjectsCubit extends SafeCubit<FeedbackSubjectsState> {
  FeedbackSubjectsCubit(this._repository)
    : super(const FeedbackSubjectsState());

  final FeedbackSubjectsRepository _repository;
  List<String> _studentIds = const [];
  int _generation = 0;

  Future<void> load(Iterable<String> studentIds) async {
    _studentIds = studentIds.toList();
    final ticket = ++_generation;
    if (_studentIds.isEmpty) {
      emit(const FeedbackSubjectsState());
      return;
    }
    emit(const FeedbackSubjectsState(loading: true));
    try {
      final subjects = await _repository.commonFor(_studentIds);
      if (ticket == _generation)
        emit(FeedbackSubjectsState(subjects: subjects));
    } on Object catch (e, st) {
      if (ticket == _generation) {
        emit(FeedbackSubjectsState(error: errorMessage(e, st)));
      }
    }
  }

  Future<void> retry() => load(_studentIds);
}
