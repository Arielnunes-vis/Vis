import 'package:supabase_flutter/supabase_flutter.dart';

import '../../logger/app_logger.dart';
import '../supabase_client.dart';
import '../supabase_exceptions.dart';

/// Interface do serviço de autenticação (baixo nível, sobre o SDK).
///
/// A feature `authentication` consome esta interface através do seu
/// repositório — nunca acessa o SDK diretamente.
abstract interface class IAuthService {
  Session? get currentSession;
  User? get currentUser;
  Stream<AuthState> get onAuthStateChange;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  });

  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> resendConfirmation(String email);
  Future<UserResponse> updateUser(UserAttributes attributes);

  /// Renova a sessão atual (refresh token).
  Future<Session?> refreshSession();
}

/// Implementação baseada no Supabase Auth.
final class SupabaseAuthService implements IAuthService {
  const SupabaseAuthService();

  GoTrueClient get _auth => VisSupabase.auth;

  @override
  Session? get currentSession => _auth.currentSession;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.d('[Auth] signInWithPassword: $email');
      return await _auth.signInWithPassword(email: email, password: password);
    } catch (e, st) {
      AppLogger.e('[Auth] signIn falhou', error: e, stackTrace: st);
      throw SupabaseErrorMapper.map(e, st);
    }
  }

  @override
  Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      AppLogger.d('[Auth] signUp: $email');
      return await _auth.signUp(email: email, password: password, data: data);
    } catch (e, st) {
      AppLogger.e('[Auth] signUp falhou', error: e, stackTrace: st);
      throw SupabaseErrorMapper.map(e, st);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      AppLogger.i('[Auth] signOut concluído');
    } catch (e, st) {
      throw SupabaseErrorMapper.map(e, st);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
      AppLogger.i('[Auth] link de recuperação enviado');
    } catch (e, st) {
      throw SupabaseErrorMapper.map(e, st);
    }
  }

  @override
  Future<void> resendConfirmation(String email) async {
    try {
      await _auth.resend(type: OtpType.signup, email: email);
    } catch (e, st) {
      throw SupabaseErrorMapper.map(e, st);
    }
  }

  @override
  Future<UserResponse> updateUser(UserAttributes attributes) async {
    try {
      return await _auth.updateUser(attributes);
    } catch (e, st) {
      throw SupabaseErrorMapper.map(e, st);
    }
  }

  @override
  Future<Session?> refreshSession() async {
    try {
      final response = await _auth.refreshSession();
      return response.session;
    } catch (e, st) {
      AppLogger.w('[Auth] refreshSession falhou', error: e, stackTrace: st);
      throw SupabaseErrorMapper.map(e, st);
    }
  }
}
