import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/core/theme/app_theme.dart';
import 'package:vis/features/authentication/models/user_model.dart';
import 'package:vis/features/authentication/presentation/login_screen.dart';
import 'package:vis/features/authentication/providers/authentication_providers.dart';
import 'package:vis/features/authentication/repositories/authentication_repository.dart';

/// Repositório falso (sem Supabase) para renderizar a tela isolada.
class _FakeAuthRepository implements AuthenticationRepository {
  @override
  UserModel? get currentUser => null;
  @override
  Stream<UserModel?> get userChanges => const Stream.empty();
  @override
  Future<UserModel> login({required String email, required String password}) async =>
      UserModel(id: 'u', email: email, emailConfirmed: true);
  @override
  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
  }) async =>
      null;
  @override
  Future<void> logout() async {}
  @override
  Future<void> forgotPassword(String email) async {}
  @override
  Future<void> resendConfirmation(String email) async {}
  @override
  Future<UserModel?> refreshSession() async => null;
  @override
  Future<UserModel?> updateProfile({String? name, String? photoUrl}) async => null;
  @override
  Future<void> deleteAccount() async {}
}

void main() {
  testWidgets('LoginScreen renderiza campos e ações principais', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authenticationRepositoryProvider
              .overrideWithValue(_FakeAuthRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.text('Entrar com Google'), findsOneWidget);
  });
}
