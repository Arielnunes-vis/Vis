import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/edge_functions_service.dart';
import 'services/realtime_service.dart';
import 'services/storage_service.dart';
import 'supabase_client.dart';
import 'supabase_service.dart';

/// Providers Riverpod para a camada Supabase (PROMPT 01).
///
/// Injeção de dependência sempre via Riverpod — nunca Singletons
/// improvisados nas features (04_FLUTTER_ARCHITECTURE.md).

/// Cliente bruto do Supabase (raramente usado direto nas features).
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => VisSupabase.client,
);

/// Serviço de autenticação.
final authServiceProvider = Provider<IAuthService>(
  (ref) => const SupabaseAuthService(),
);

/// Serviço de banco de dados.
final databaseServiceProvider = Provider<IDatabaseService>(
  (ref) => const SupabaseDatabaseService(),
);

/// Serviço de storage.
final storageServiceProvider = Provider<IStorageService>(
  (ref) => const SupabaseStorageService(),
);

/// Serviço de realtime.
final realtimeServiceProvider = Provider<IRealtimeService>(
  (ref) => const SupabaseRealtimeService(),
);

/// Serviço de edge functions.
final edgeFunctionsServiceProvider = Provider<IEdgeFunctionsService>(
  (ref) => const SupabaseEdgeFunctionsService(),
);

/// Fachada agregadora dos serviços.
final supabaseServiceProvider = Provider<SupabaseService>(
  (ref) => SupabaseService(
    auth: ref.watch(authServiceProvider),
    database: ref.watch(databaseServiceProvider),
    storage: ref.watch(storageServiceProvider),
    realtime: ref.watch(realtimeServiceProvider),
    functions: ref.watch(edgeFunctionsServiceProvider),
  ),
);

/// Stream do estado de autenticação do Supabase (sessão).
final supabaseAuthStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(authServiceProvider).onAuthStateChange,
);
