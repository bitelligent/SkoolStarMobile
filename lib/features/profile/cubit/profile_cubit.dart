import 'package:flutter_bloc/flutter_bloc.dart';
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
    } on Exception catch (e) {
      emit(ProfileState.error(e.toString()));
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
    if (s is! ProfileLoaded) return false;
    emit(s.copyWith(isSaving: true, errorMessage: null));
    try {
      final updated = await _repo.updateProfile(
        firstName: s.firstNameDraft.trim(),
        lastName: s.lastNameDraft.trim(),
      );
      if (s.changePasswordEnabled) {
        if (s.newPasswordDraft != s.confirmPasswordDraft) {
          emit(s.copyWith(
            isSaving: false,
            errorMessage: 'Passwords do not match.',
          ));
          return false;
        }
        await _repo.changePassword(
          currentPassword: s.currentPasswordDraft,
          newPassword: s.newPasswordDraft,
        );
      }
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
    } on Exception catch (e) {
      emit(s.copyWith(isSaving: false, errorMessage: e.toString()));
      return false;
    }
  }
}
