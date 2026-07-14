import '../models/user_model.dart';

/// Contrato do repositório de autenticação (PROMPT 02).
///
/// A camada de apresentação nunca fala com o Supabase direto: sempre
/// via este repositório (Regra 5). A estrutura para exclusão de conta
/// fica prevista (`deleteAccount`) mesmo sem implementação nesta etapa.
abstract interface class AuthenticationRepository {
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

  /// Renova a sessão (refresh token) e retorna o usuário atualizado.
  Future<UserModel?> refreshSession();

  /// Atualiza dados básicos do usuário (nome, foto).
  Future<UserModel?> updateProfile({String? name, String? photoUrl});

  /// Estrutura preparada para o futuro (exclusão de conta).
  Future<void> deleteAccount();
}
