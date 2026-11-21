
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/auth/model/app_user.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/auth/viewmodel/login_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState());

  final AuthRepository _authRepository;

  static const String _genericError = 'Something went wrong. Please try again.';

  Future<void> login({required String email, required String password}) {
    return _run(
      LoginMethod.email,
      () => _authRepository.signIn(email: email, password: password),
    );
  }

  Future<void> loginWithGoogle() {
    return _run(LoginMethod.google, _authRepository.signInWithGoogle);
  }

  Future<void> _run(
    LoginMethod method,
    Future<AppUser?> Function() action,
  ) async {
    if (state.isLoading) return; 
    emit(LoginState(status: LoginStatus.loading, method: method));
    try {
      final user = await action();
      if (isClosed) return; 
      if (user == null) {
        emit(const LoginState()); 
        return;
      }
      emit(LoginState(status: LoginStatus.success, method: method));
    } on AuthFailure catch (e) {
      if (isClosed) return;
      emit(LoginState(
        status: LoginStatus.failure,
        method: method,
        errorMessage: e.message,
      ));
    } catch (e) {
      debugPrint('Login failed with unexpected error: $e');
      if (isClosed) return;
      emit(LoginState(
        status: LoginStatus.failure,
        method: method,
        errorMessage: _genericError,
      ));
    }
  }
}