import '../constants/app_constants.dart';
import '../storage/local_storage_service.dart';
import 'pending_sync.dart';

/// Fila persistente de operações pendentes (PROMPT 01).
///
/// Guarda as operações em uma box Hive dedicada para sobreviver ao
/// fechamento do app. Ainda sem processamento automático — apenas
/// enfileira/desenfileira.
final class SyncQueue {
  const SyncQueue(this._storage);

  final LocalStorageService _storage;

  String get _boxName => AppConstants.boxSyncQueue;

  Future<void> enqueue(PendingSync item) =>
      _storage.put(_boxName, item.id, item.toMap());

  Future<void> remove(String id) => _storage.delete(_boxName, id);

  List<PendingSync> pending() {
    final box = _storage.box(_boxName);
    return box.values
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => PendingSync.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  bool get isEmpty => _storage.box(_boxName).isEmpty;

  Future<void> clear() => _storage.clearBox(_boxName);
}
