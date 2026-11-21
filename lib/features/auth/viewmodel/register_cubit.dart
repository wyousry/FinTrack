import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/auth/model/app_user.dart';
import 'package:fintrack/features/auth/model/password_strength.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/auth/viewmodel/register_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const RegisterState());

  final AuthRepository _authRepository;

  static const String _genericError = 'Something went wrong. Please try again.';

  void passwordChanged(String password) {
    emit(state.copyWith(
      passwordStrength: PasswordStrength.fromPassword(password),
    ));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      RegisterMethod.email,
      () => _authRepository.register(name: name, email: email, password: password),
    );
  }

  Future<void> registerWithGoogle() {
    return _run(RegisterMethod.google, _authRepository.signInWithGoogle);
  }

  Future<void> _run(
    RegisterMethod method,
    Future<AppUser?> Function() action,
  ) async {
    if (state.isLoading) return; 

    emit(state.copyWith(status: RegisterStatus.loading, method: method));
    try {
      final user = await action();
      if (isClosed) return;
      if (user == null) {
        emit(state.copyWith(status: RegisterStatus.initial)); 
        return;
      }
      emit(state.copyWith(status: RegisterStatus.success));
    } on AuthFailure catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      debugPrint('Register failed with unexpected error: $e');
      if (isClosed) return;
      emit(state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: _genericError,
      ));
    }
  }
}