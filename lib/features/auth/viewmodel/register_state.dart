import 'package:equatable/equatable.dart';
import 'package:fintrack/features/auth/model/password_strength.dart';

enum RegisterStatus { initial, loading, success, failure }
enum RegisterMethod { email, google }

class RegisterState extends Equatable {
  const RegisterState({
    this.status = RegisterStatus.initial,
    this.method,
    this.errorMessage,
    this.passwordStrength = PasswordStrength.none,
  });

  final RegisterStatus status;
  final RegisterMethod? method;
  final String? errorMessage;
  final PasswordStrength passwordStrength;

  bool get isLoading => status == RegisterStatus.loading;
  bool isLoadingWith(RegisterMethod m) => isLoading && method == m;

  RegisterState copyWith({
    RegisterStatus? status,
    RegisterMethod? method,
    String? errorMessage,
    PasswordStrength? passwordStrength,
  }) {
    return RegisterState(
      status: status ?? this.status,
      method: method ?? this.method,
      errorMessage: errorMessage,
      passwordStrength: passwordStrength ?? this.passwordStrength,
    );
  }

  @override
  List<Object?> get props => [status, method, errorMessage, passwordStrength];
}