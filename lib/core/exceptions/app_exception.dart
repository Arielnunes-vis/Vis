/// Hierarquia de exceções do VIS.
///
/// Regra: NUNCA lançar `Exception` genérica (PROMPT 01 / Regra 15).
/// Toda falha deve ser representada por um subtipo de [AppException],
/// carregando uma mensagem amigável (exibível ao usuário) e,
/// opcionalmente, detalhes técnicos e o erro original.
sealed class AppException implements Exception {
  const AppException(
    this.message, {
    this.code,
    this.cause,
    this.stackTrace,
  });

  /// Mensagem amigável, em português, segura para exibir ao usuário.
  final String message;

  /// Código opcional (ex.: código de erro do Supabase/Postgres).
  final String? code;

  /// Erro original que causou esta exceção (para logs).
  final Object? cause;

  final StackTrace? stackTrace;

  @override
  String toString() =>
      '$runtimeType(code: $code, message: $message, cause: $cause)';
}

/// Falha de autenticação (login, sessão, tokens).
final class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.cause,
    super.stackTrace,
  });

  factory AuthException.unknown([Object? cause]) => AuthException(
        'Não foi possível autenticar. Tente novamente.',
        code: 'auth_unknown',
        cause: cause,
      );
}

/// Falha de acesso a dados (PostgreSQL / consultas / RLS).
final class DatabaseException extends AppException {
  const DatabaseException(
    super.message, {
    super.code,
    super.cause,
    super.stackTrace,
  });

  factory DatabaseException.unknown([Object? cause]) => DatabaseException(
        'Ocorreu um erro ao acessar seus dados.',
        code: 'db_unknown',
        cause: cause,
      );
}

/// Falha de armazenamento (upload/download de arquivos, buckets).
final class StorageException extends AppException {
  const StorageException(
    super.message, {
    super.code,
    super.cause,
    super.stackTrace,
  });

  factory StorageException.unknown([Object? cause]) => StorageException(
        'Ocorreu um erro ao processar o arquivo.',
        code: 'storage_unknown',
        cause: cause,
      );
}

/// Falha de rede / conectividade.
final class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.cause,
    super.stackTrace,
  });

  factory NetworkException.offline() => const NetworkException(
        'Sem conexão com a internet.',
        code: 'network_offline',
      );
}

/// Falha ao consumir a camada de IA (Edge Functions / OpenAI).
final class AIException extends AppException {
  const AIException(
    super.message, {
    super.code,
    super.cause,
    super.stackTrace,
  });

  factory AIException.unknown([Object? cause]) => AIException(
        'Não foi possível gerar a resposta do VIS Coach agora.',
        code: 'ai_unknown',
        cause: cause,
      );
}

/// Falha de validação de entrada (dados do usuário).
final class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.code,
    super.cause,
    super.stackTrace,
  });
}

/// Falha não mapeada. Use apenas como último recurso.
final class UnknownException extends AppException {
  const UnknownException([
    String message = 'Ocorreu um erro inesperado.',
    Object? cause,
  ]) : super(message, code: 'unknown', cause: cause);
}
