import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/supabase/services/auth_service.dart';
import '../models/user_model.dart';

/// Serviço de autenticação da feature (mapeia SDK → domínio).
abstract interface class AuthenticationService {
  UserModel? get currentUser;
  Stream<UserModel?> get userChanges;

  Future<UserModel> login({required String email, required String password});
  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<void> resendConfirmation(String email);

  /// Renova a sessão e retorna o usuário atualizado (ou null).
  Future<UserModel?> refreshSession();

  /// Atualiza dados básicos do usuário (nome, foto) nos metadados Auth.
  Future<UserModel?> updateProfile({String? name, String? photoUrl});
}

/// Implementação sobre o [IAuthService] do core (Supabase).
final class SupabaseAuthenticationService implements AuthenticationService {
  const SupabaseAuthenticationService(this._auth);

  final IAuthService _auth;

  @override
  UserModel? get currentUser => _mapUser(_auth.currentUser);

  @override
  Stream<UserModel?> get userChanges =>
      _auth.onAuthStateChange.map((state) => _mapUser(state.session?.user));

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = _mapUser(response.user);
    if (user == null) {
      throw const _MissingUser();
    }
    return user;
  }

  @override
  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _auth.signUpWithPassword(
      email: email,
      password: password,
      data: {'name': name},
    );
    return _mapUser(response.user);
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<void> forgotPassword(String email) => _auth.resetPassword(email);

  @override
  Future<void> resendConfirmation(String email) =>
      _auth.resendConfirmation(email);

  @override
  Future<UserModel?> refreshSession() async {
    final session = await _auth.refreshSession();
    return _mapUser(session?.user);
  }

  @override
  Future<UserModel?> updateProfile({String? name, String? photoUrl}) async {
    final data = <String, dynamic>{
      if (name != null) 'name': name,
      if (photoUrl != null) 'photo_url': photoUrl,
    };
    final response = await _auth.updateUser(sb.UserAttributes(data: data));
    return _mapUser(response.user);
  }

  UserModel? _mapUser(sb.User? user) {
    if (user == null) return null;
    return UserModel.fromAuth(
      id: user.id,
      email: user.email ?? '',
      metadata: user.userMetadata,
      emailConfirmed: user.emailConfirmedAt != null,
    );
  }
}

class _MissingUser implements Exception {
  const _MissingUser();
}
