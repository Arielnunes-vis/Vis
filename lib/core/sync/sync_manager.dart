import 'dart:async';

import '../logger/app_logger.dart';
import '../network/network_info.dart';
import 'sync_queue.dart';

/// Orquestrador de sincronização offline → online (PROMPT 01).
///
/// Estrutura preparada: observa a conectividade e, quando online,
/// deveria drenar a [SyncQueue] enviando cada operação ao Supabase.
/// O envio efetivo (por tabela) será implementado junto aos módulos
/// de escrita offline. Por ora, expõe o esqueleto e os hooks.
final class SyncManager {
  SyncManager({required SyncQueue queue, required INetworkInfo networkInfo})
      : _queue = queue,
        _networkInfo = networkInfo;

  final SyncQueue _queue;
  final INetworkInfo _networkInfo;

  bool _running = false;
  StreamSubscription<ConnectionStatus>? _statusSub;

  /// Inicia a observação da conectividade para disparar sincronização.
  /// Idempotente: chamadas repetidas não acumulam assinaturas.
  void start() {
    if (_statusSub != null) return;
    _statusSub = _networkInfo.onStatusChange.listen((status) {
      if (status == ConnectionStatus.online) {
        // ignore: discarded_futures
        processQueue();
      }
    });
  }

  /// Encerra a observação da conectividade (libera a assinatura).
  Future<void> dispose() async {
    await _statusSub?.cancel();
    _statusSub = null;
  }

  /// Drena a fila. Implementação de envio será adicionada por módulo.
  Future<void> processQueue() async {
    if (_running) return;
    if (_queue.isEmpty) return;
    _running = true;
    try {
      final items = _queue.pending();
      AppLogger.i('[Sync] ${items.length} operação(ões) pendente(s).');
      // TODO(modulos): implementar envio por tabela ao Supabase.
    } finally {
      _running = false;
    }
  }
}
