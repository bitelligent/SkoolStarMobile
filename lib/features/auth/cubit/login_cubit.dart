import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/features/auth/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repo) : super(const LoginState.initial());

  final AuthRepository _repo;

  Future<void> submit({
    required String email,
    required String password,
    String? contextKey,
  }) async {
    if (state is LoginLoading) return;
    emit(const LoginState.loading());
    try {
      final res = await _repo.login(
        email: email,
        password: password,
        contextKey: contextKey,
      );
      if (res.requiresContextSelection) {
        final teacherContexts = res.availableContexts
            .where((c) => c.role.toLowerCase() == 'teacher')
            .toList();
        emit(
          teacherContexts.isEmpty
              ? const LoginState.failure(
                  'This app is for teachers. Please sign in with a teacher account.',
                )
              : LoginState.contextSelection(teacherContexts),
        );
      } else {
        emit(const LoginState.success());
      }
    } on UnauthorizedException {
      emit(const LoginState.failure('Incorrect email or password.'));
    } on ApiException catch (e) {
      emit(LoginState.failure(e.message));
    } on Object catch (e, st) {
      emit(LoginState.failure(errorMessage(e, st)));
    }
  }
}
