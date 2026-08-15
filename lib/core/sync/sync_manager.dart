import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logger/app_logger.dart';
import '../network/connection_provider.dart';
import '../network/network_info.dart';
import '../storage/local_storage_service.dart';
import '../supabase/services/database_service.dart';
import '../supabase/supabase_provider.dart';
import 'pending_sync.dart';
import 'sync_queue.dart';

/// Orquestrador de sincronização offline ↔ online (PROMPT 01).
///
/// Drena a [SyncQueue] enviando cada operação pendente ao Supabase via
/// [IDatabaseService]. O Hive (local) continua sendo a fonte da verdade
/// offline — a operação só sai da fila após confirmação do servidor;
/// falhas (ex.: sem conexão) permanecem na fila para nova tentativa.
final class SyncManager {
  SyncManager({
    required SyncQueue queue,
    required INetworkInfo networkInfo,
    required IDatabaseService database,
  })  : _queue = queue,
        _networkInfo = networkInfo,
        _database = database;

  final SyncQueue _queue;
  final INetworkInfo _networkInfo;
  final IDatabaseService _database;

  bool _running = false;
  StreamSubscription<ConnectionStatus>? _statusSub;

  /// Inicia a observação da conectividade para disparar sincronização.
  /// Idempotente: chamadas repetidas não acumulam assinaturas. Também
  /// tenta drenar a fila imediatamente (cobre o caso de o app já abrir
  /// online com itens pendentes de uma sessão offline anterior).
  void start() {
    if (_statusSub != null) return;
    _statusSub = _networkInfo.onStatusChange.listen((status) {
      if (status == ConnectionStatus.online) {
        // ignore: discarded_futures
        processQueue();
      }
    });
    // ignore: discarded_futures
    processQueue();
  }

  /// Encerra a observação da conectividade (libera a assinatura).
  Future<void> dispose() async {
    await _statusSub?.cancel();
    _statusSub = null;
  }

  /// Enfileira uma operação (grava na fila local, rápido) e tenta
  /// sincronizar em seguida sem bloquear quem chamou — o envio ao
  /// Supabase roda em segundo plano, preservando o offline-first.
  Future<void> enqueueAndSync(PendingSync item) async {
    await _queue.enqueue(item);
    // ignore: discarded_futures
    processQueue();
  }

  /// Drena a fila, enviando cada operação pendente ao Supabase.
  /// Operações com falha (ex.: offline) permanecem na fila para a
  /// próxima tentativa — nunca são descartadas silenciosamente.
  Future<void> processQueue() async {
    if (_running) return;
    if (_queue.isEmpty) return;
    _running = true;
    try {
      final items = _queue.pending();
      AppLogger.i('[Sync] ${items.length} operação(ões) pendente(s).');
      for (final item in items) {
        try {
          await _send(item);
          await _queue.remove(item.id);
        } catch (e, st) {
          AppLogger.w(
            '[Sync] falha ao enviar ${item.table}/${item.id} '
            '(tentativa ${item.retries + 1}): $e',
          );
          await _queue.enqueue(item.copyWith(retries: item.retries + 1));
        }
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _send(PendingSync item) async {
    switch (item.operation) {
      case SyncOperation.insert:
      case SyncOperation.update:
        await _database.upsert(item.table, item.payload);
        break;
      case SyncOperation.softDelete:
        final id = item.payload['id'] as String;
        await _database.softDelete(item.table, id: id);
        break;
    }
  }
}

/// Fila de sincronização (Hive) — persiste entre sessões do app.
final syncQueueProvider = Provider<SyncQueue>(
  (ref) => const SyncQueue(LocalStorageService()),
);

/// Orquestrador de sincronização — inicia a observação de conectividade
/// e drena a fila (ver [SyncManager.start]).
final syncManagerProvider = Provider<SyncManager>(
  (ref) => SyncManager(
    queue: ref.watch(syncQueueProvider),
    networkInfo: ref.watch(networkInfoProvider),
    database: ref.watch(databaseServiceProvider),
  ),
);
