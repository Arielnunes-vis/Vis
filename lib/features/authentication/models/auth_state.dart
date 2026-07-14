import 'package:equatable/equatable.dart';

import 'user_model.dart';

/// Estados possíveis do fluxo de autenticação (PROMPT 02).
enum AuthStatus {
  idle,
  loading,
  authenticated,
  unauthenticated,
  emailUnconfirmed,
  error,
}

/// Estado imutável exposto pelo AuthenticationController.
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.idle,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState.idle() : this();
  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.authenticated(UserModel user)
      : this(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
      : this(status: AuthStatus.unauthenticated);

  const AuthState.error(String message)
      : this(status: AuthStatus.error, errorMessage: message);

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
