import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/edge_functions_service.dart';
import 'services/realtime_service.dart';
import 'services/storage_service.dart';

/// Fachada que agrupa todos os serviços do Supabase.
///
/// Facilita a injeção de dependência: em vez de expor cinco serviços
/// soltos, as features recebem esta fachada e acessam o que precisam.
final class SupabaseService {
  const SupabaseService({
    required this.auth,
    required this.database,
    required this.storage,
    required this.realtime,
    required this.functions,
  });

  /// Instância padrão com as implementações Supabase.
  factory SupabaseService.production() => const SupabaseService(
        auth: SupabaseAuthService(),
        database: SupabaseDatabaseService(),
        storage: SupabaseStorageService(),
        realtime: SupabaseRealtimeService(),
        functions: SupabaseEdgeFunctionsService(),
      );

  final IAuthService auth;
  final IDatabaseService database;
  final IStorageService storage;
  final IRealtimeService realtime;
  final IEdgeFunctionsService functions;
}
