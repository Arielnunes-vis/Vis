import '../models/user_model.dart';
import '../repositories/authentication_repository.dart';
import '../services/authentication_service.dart';

/// Implementação do [AuthenticationRepository].
///
/// Delega ao [AuthenticationService]. No futuro, também orquestrará a
/// leitura/gravação do perfil estendido (tabela `users`) e a exclusão
/// de conta via Edge Function.
final class AuthenticationRepositoryImpl implements AuthenticationRepository {
  const AuthenticationRepositoryImpl(this._service);

  final AuthenticationService _service;

  @override
  UserModel? get currentUser => _service.currentUser;

  @override
  Stream<UserModel?> get userChanges => _service.userChanges;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) =>
      _service.login(email: email, password: password);

  @override
  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
  }) =>
      _service.register(email: email, password: password, name: name);

  @override
  Future<void> logout() => _service.logout();

  @override
  Future<void> forgotPassword(String email) => _service.forgotPassword(email);

  @override
  Future<void> resendConfirmation(String email) =>
      _service.resendConfirmation(email);

  @override
  Future<UserModel?> refreshSession() => _service.refreshSession();

  @override
  Future<UserModel?> updateProfile({String? name, String? photoUrl}) =>
      _service.updateProfile(name: name, photoUrl: photoUrl);

  @override
  Future<void> deleteAccount() async {
    // Estrutura preparada (PROMPT 02). Implementação futura via Edge
    // Function segura — nunca excluir dados fisicamente sem confirmação.
    throw UnimplementedError('Exclusão de conta será implementada adiante.');
  }
}
