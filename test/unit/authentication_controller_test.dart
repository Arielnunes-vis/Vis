import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/core/exceptions/app_exception.dart';
import 'package:vis/features/authentication/models/auth_state.dart';
import 'package:vis/features/authentication/models/user_model.dart';
import 'package:vis/features/authentication/providers/authentication_providers.dart';
import 'package:vis/features/authentication/repositories/authentication_repository.dart';

/// Repositório falso para testar o controller sem Supabase.
class FakeAuthRepository implements AuthenticationRepository {
  FakeAuthRepository({this.shouldFail = false});
  bool shouldFail;

  @override
  UserModel? currentUser;

  @override
  Stream<UserModel?> get userChanges => const Stream.empty();

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      throw const AuthException('E-mail ou senha incorretos.');
    }
    return UserModel(id: 'u1', email: email, emailConfirmed: true);
  }

  @override
  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
  }) async =>
      UserModel(id: 'u1', email: email, name: name, emailConfirmed: true);

  @override
  Future<void> logout() async {}

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resendConfirmation(String email) async {}

  @override
  Future<UserModel?> refreshSession() async => currentUser;

  @override
  Future<UserModel?> updateProfile({String? name, String? photoUrl}) async =>
      currentUser;

  @override
  Future<void> deleteAccount() async {}
}

ProviderContainer _containerWith(FakeAuthRepository repo) {
  return ProviderContainer(
    overrides: [
      authenticationRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

void main() {
  test('login com sucesso → authenticated', () async {
    final container = _containerWith(FakeAuthRepository());
    addTearDown(container.dispose);

    final controller =
        container.read(authenticationControllerProvider.notifier);
    await controller.login(email: 'gabi@vis.app', password: 'abcd1234');

    final state = container.read(authenticationControllerProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.user?.email, 'gabi@vis.app');
  });

  test('login com falha → error com mensagem amigável', () async {
    final container = _containerWith(FakeAuthRepository(shouldFail: true));
    addTearDown(container.dispose);

    final controller =
        container.read(authenticationControllerProvider.notifier);
    await controller.login(email: 'gabi@vis.app', password: 'errada12');

    final state = container.read(authenticationControllerProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'E-mail ou senha incorretos.');
  });
}
