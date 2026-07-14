import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../logger/app_logger.dart';

/// Cliente Supabase global do VIS (singleton).
///
/// PROMPT 01: um único cliente, nunca múltiplas instâncias.
/// A inicialização acontece uma vez no bootstrap ([VisSupabase.initialize]),
/// após o carregamento das variáveis de ambiente ([Env.load]).
abstract final class VisSupabase {
  const VisSupabase._();

  static bool _initialized = false;

  /// Inicializa o Supabase. Idempotente.
  static Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        // Sessão persistida automaticamente pelo próprio Supabase.
        autoRefreshToken: true,
      ),
      // Realtime preparado para uso futuro.
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.error,
      ),
    );

    _initialized = true;
    AppLogger.i('[Supabase] Cliente inicializado.');
  }

  /// Instância única do cliente. Lança se acessada antes de [initialize].
  static SupabaseClient get client {
    assert(
      _initialized,
      'VisSupabase.initialize() deve ser chamado antes de acessar o client.',
    );
    return Supabase.instance.client;
  }

  static GoTrueClient get auth => client.auth;
  static SupabaseStorageClient get storage => client.storage;
  static RealtimeClient get realtime => client.realtime;

  static bool get isInitialized => _initialized;
}
