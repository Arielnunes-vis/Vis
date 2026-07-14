import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Armazenamento seguro para dados sensíveis não gerenciados pelo
/// Supabase (PROMPT 01 / Regra 12).
///
/// IMPORTANTE: tokens de sessão são gerenciados pelo próprio Supabase
/// Auth — NÃO devem ser salvos aqui manualmente. Este serviço é para
/// flags e preferências sensíveis (ex.: lembrar sessão, PIN futuro).
abstract interface class ISecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

final class SecureStorageService implements ISecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clear() => _storage.deleteAll();
}

/// Chaves conhecidas do armazenamento seguro.
abstract final class SecureKeys {
  const SecureKeys._();
  static const String rememberSession = 'remember_session';
  static const String onboardingCompleted = 'onboarding_completed';
}

final secureStorageProvider = Provider<ISecureStorageService>(
  (ref) => SecureStorageService(),
);
