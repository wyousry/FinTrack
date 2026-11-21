import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

enum LoginMethod { email, google }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.method,
    this.errorMessage,
  });

  final LoginStatus status;
  final LoginMethod? method;
  final String? errorMessage;

  bool get isLoading => status == LoginStatus.loading;
  bool isLoadingWith(LoginMethod m) => isLoading && method == m;

  @override
  List<Object?> get props => [status, method, errorMessage];
}