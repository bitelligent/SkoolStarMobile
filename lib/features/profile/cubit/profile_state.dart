import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/data/models/user_model.dart';

part 'profile_state.freezed.dart';

@freezed
sealed class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = ProfileInitial;
  const factory ProfileState.loading() = ProfileLoading;
  const factory ProfileState.loaded({
    required UserModel user,
    @Default(false) bool changePasswordEnabled,
    @Default(false) bool isSaving,
    @Default('') String firstNameDraft,
    @Default('') String lastNameDraft,
    @Default('') String currentPasswordDraft,
    @Default('') String newPasswordDraft,
    @Default('') String confirmPasswordDraft,
    String? errorMessage,
  }) = ProfileLoaded;
  const factory ProfileState.error(String message) = ProfileError;
}

extension ProfileLoadedX on ProfileLoaded {
  /// What the Save button needs before it is offered: a first name, and — when
  /// changing the password — both passwords, matching.
  bool get canSave =>
      !isSaving &&
      firstNameDraft.trim().isNotEmpty &&
      (!changePasswordEnabled ||
          (currentPasswordDraft.isNotEmpty &&
              newPasswordDraft.isNotEmpty &&
              newPasswordDraft == confirmPasswordDraft));
}
