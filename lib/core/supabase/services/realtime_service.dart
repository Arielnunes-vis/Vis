import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_client.dart';

/// Tipos de evento Realtime que o app poderá assinar (PROMPT 01).
///
/// Estrutura preparada — o consumo por tabela será implementado pelos
/// módulos que precisarem de atualização ao vivo (ex.: sincronização
/// entre dispositivos, notificações).
enum RealtimeEvents {
  insert(PostgresChangeEvent.insert),
  update(PostgresChangeEvent.update),
  delete(PostgresChangeEvent.delete),
  all(PostgresChangeEvent.all);

  const RealtimeEvents(this.change);
  final PostgresChangeEvent change;
}

/// Serviço de Realtime — estrutura preparada (PROMPT 01).
///
/// Ainda sem implementação de canais de produção. Expõe apenas o
/// ponto de criação de canais para uso futuro (ex.: sincronização,
/// notificações ao vivo).
abstract interface class IRealtimeService {
  RealtimeChannel channel(String name);
  Future<void> removeAllChannels();
}

final class SupabaseRealtimeService implements IRealtimeService {
  const SupabaseRealtimeService();

  @override
  RealtimeChannel channel(String name) => VisSupabase.client.channel(name);

  @override
  Future<void> removeAllChannels() =>
      VisSupabase.client.removeAllChannels();
}
