import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../exceptions/app_exception.dart';

/// Traduz erros do SDK do Supabase para a hierarquia [AppException]
/// do VIS, com mensagens amigáveis em português.
///
/// Regra: nunca vazar stacktrace ou mensagem técnica para a UI.
abstract final class SupabaseErrorMapper {
  const SupabaseErrorMapper._();

  static AppException map(Object error, [StackTrace? stackTrace]) {
    // ----- Autenticação -----
    if (error is sb.AuthException) {
      return AuthException(
        _authMessage(error),
        code: error.statusCode ?? 'auth_error',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    // ----- Banco de dados (PostgREST / Postgres) -----
    if (error is sb.PostgrestException) {
      return DatabaseException(
        'Não foi possível completar a operação com seus dados.',
        code: error.code ?? 'postgrest_error',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    // ----- Storage -----
    if (error is sb.StorageException) {
      return StorageException(
        'Não foi possível processar o arquivo.',
        code: error.statusCode ?? 'storage_error',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    // ----- Fallback -----
    return UnknownException('Ocorreu um erro inesperado.', error);
  }

  static String _authMessage(sb.AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login') ||
        message.contains('invalid credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (message.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (message.contains('already registered') ||
        message.contains('user already')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (message.contains('rate limit') || message.contains('too many')) {
      return 'Muitas tentativas. Aguarde alguns instantes.';
    }
    return 'Não foi possível autenticar. Tente novamente.';
  }
}
