import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/repositories/user_repository.dart';
import 'package:skoolstar_teacher_module/features/profile/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo) : super(const ProfileState.initial());

  final UserRepository _repo;

  Future<void> load() async {
    emit(const ProfileState.loading());
    try {
      final user = await _repo.getCurrentUser();
      emit(
        ProfileState.loaded(
          user: user,
          firstNameDraft: user.firstName,
          lastNameDraft: user.lastName,
        ),
      );
    } on Object catch (e, st) {
      emit(ProfileState.error(errorMessage(e, st)));
    }
  }

  void setFirstName(String v) {
    final s = state;
    if (s is ProfileLoaded) emit(s.copyWith(firstNameDraft: v));
  }

  void setLastName(String v) {
    final s = state;
    if (s is ProfileLoaded) emit(s.copyWith(lastNameDraft: v));
  }

  void toggleChangePassword(bool v) {
    final s = state;
    if (s is ProfileLoaded) {
      emit(
        s.copyWith(
          changePasswordEnabled: v,
          currentPasswordDraft: '',
          newPasswordDraft: '',
          confirmPasswordDraft: '',
          errorMessage: null,
        ),
      );
    }
  }

  void setCurrentPassword(String v) {
    final s = state;
    if (s is ProfileLoaded) emit(s.copyWith(currentPasswordDraft: v));
  }

  void setNewPassword(String v) {
    final s = state;
    if (s is ProfileLoaded) emit(s.copyWith(newPasswordDraft: v));
  }

  void setConfirmPassword(String v) {
    final s = state;
    if (s is ProfileLoaded) emit(s.copyWith(confirmPasswordDraft: v));
  }

  Future<bool> save() async {
    final s = state;
    if (s is! ProfileLoaded || s.isSaving) return false;

    final firstName = s.firstNameDraft.trim();
    final lastName = s.lastNameDraft.trim();
    if (firstName.isEmpty) {
      emit(s.copyWith(errorMessage: 'First name is required.'));
      return false;
    }
    if (s.changePasswordEnabled) {
      if (s.currentPasswordDraft.isEmpty || s.newPasswordDraft.isEmpty) {
        emit(
          s.copyWith(errorMessage: 'Enter your current and new password.'),
        );
        return false;
      }
      if (s.newPasswordDraft != s.confirmPasswordDraft) {
        emit(s.copyWith(errorMessage: 'Passwords do not match.'));
        return false;
      }
    }

    emit(s.copyWith(isSaving: true, errorMessage: null));
    try {
      final updated = await _repo.updateProfile(
        firstName: firstName,
        lastName: lastName,
        currentPassword: s.changePasswordEnabled
            ? s.currentPasswordDraft
            : null,
        newPassword: s.changePasswordEnabled ? s.newPasswordDraft : null,
      );
      emit(
        s.copyWith(
          user: updated,
          isSaving: false,
          changePasswordEnabled: false,
          currentPasswordDraft: '',
          newPasswordDraft: '',
          confirmPasswordDraft: '',
        ),
      );
      return true;
    } on Object catch (e, st) {
      emit(s.copyWith(isSaving: false, errorMessage: errorMessage(e, st)));
      return false;
    }
  }
}
