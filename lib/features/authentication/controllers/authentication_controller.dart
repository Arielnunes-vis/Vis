import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../core/logger/app_logger.dart';
import '../models/auth_state.dart';
import '../providers/authentication_providers.dart';
import '../repositories/authentication_repository.dart';

/// Controller de autenticação (Riverpod Notifier) — PROMPT 02.
///
/// Concentra login, cadastro, logout e recuperação de senha, expondo
/// um [AuthState] imutável para a UI. Nunca acessa o Supabase direto:
/// sempre via [AuthenticationRepository], resolvido pelo Riverpod.
class AuthenticationController extends Notifier<AuthState> {
  AuthenticationRepository get _repository =>
      ref.read(authenticationRepositoryProvider);

  @override
  AuthState build() {
    final user = _repository.currentUser;
    return user != null
        ? AuthState.authenticated(user)
        : const AuthState.unauthenticated();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.login(email: email, password: password);
      state = AuthState.authenticated(user);
    } on AppException catch (e) {
      _fail(e.message);
    } catch (e, st) {
      AppLogger.e('[Auth] login inesperado', error: e, stackTrace: st);
      _fail('Não foi possível entrar. Tente novamente.');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.register(
        email: email,
        password: password,
        name: name,
      );
      if (user == null || !user.emailConfirmed) {
        state = const AuthState(status: AuthStatus.emailUnconfirmed);
        return;
      }
      state = AuthState.authenticated(user);
    } on AppException catch (e) {
      _fail(e.message);
    } catch (e, st) {
      AppLogger.e('[Auth] register inesperado', error: e, stackTrace: st);
      _fail('Não foi possível criar a conta. Tente novamente.');
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } on AppException catch (e) {
      AppLogger.w('[Auth] logout: ${e.message}');
    } finally {
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await _repository.forgotPassword(email);
      return true;
    } on AppException catch (e) {
      _fail(e.message);
      return false;
    }
  }

  Future<void> resendConfirmation(String email) async {
    try {
      await _repository.resendConfirmation(email);
    } on AppException catch (e) {
      _fail(e.message);
    }
  }

  /// Renova a sessão e reavalia o status de confirmação de e-mail.
  /// Usado pela tela de verificação ("Atualizar status").
  Future<void> reloadUser() async {
    try {
      final user = await _repository.refreshSession();
      if (user != null && user.emailConfirmed) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState(status: AuthStatus.emailUnconfirmed);
      }
    } on AppException catch (e) {
      _fail(e.message);
    }
  }

  void _fail(String message) => state = AuthState.error(message);
}
