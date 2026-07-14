import 'base_repository.dart';

/// Contrato de CRUD genérico tipado.
///
/// [T] é o modelo de domínio. As implementações convertem entre o
/// modelo e o mapa persistido no Supabase.
///
/// Regra 001/003: `delete` é sempre soft delete — histórico nunca é
/// removido fisicamente.
abstract interface class CrudRepository<T> implements BaseRepository {
  Future<List<T>> getAll({int page, int pageSize});
  Future<T?> getById(String id);
  Future<T> create(T model);
  Future<T> update(String id, T model);
  Future<void> softDelete(String id);
}
