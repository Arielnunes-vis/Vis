import 'crud_repository.dart';

/// Contrato para repositórios com suporte offline-first (PROMPT 01).
///
/// Além do CRUD, expõe operações de sincronização entre o cache local
/// (Hive) e o Supabase. A implementação efetiva de envio será feita
/// pelos módulos que gravam offline (treinos, peso, medidas, cardio).
abstract interface class SyncRepository<T> implements CrudRepository<T> {
  /// Persiste localmente e enfileira para envio quando houver conexão.
  Future<T> createOffline(T model);

  /// Envia o que estiver pendente no cache local para o Supabase.
  Future<void> syncPending();

  /// Indica se há dados locais ainda não sincronizados.
  bool get hasPendingChanges;
}
