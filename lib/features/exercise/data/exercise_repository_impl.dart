import '../domain/exercise_catalog_source.dart';
import '../domain/exercise_filter.dart';
import '../domain/exercise_user_data_store.dart';
import '../models/exercise.dart';
import '../models/exercise_history.dart';
import '../repositories/exercise_repository.dart';

/// Implementação do [ExerciseRepository].
///
/// Compõe o catálogo (fonte) com dados do usuário (favoritos/histórico).
/// Filtro/busca/ordenação/paginação são resolvidos aqui para que a fonte
/// possa ser trocada (local → Supabase) sem afetar a UI.
final class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl({
    required ExerciseCatalogSource source,
    required ExerciseUserDataStore userStore,
    required String? Function() currentUserId,
  })  : _source = source,
        _userStore = userStore,
        _currentUserId = currentUserId;

  final ExerciseCatalogSource _source;
  final ExerciseUserDataStore _userStore;
  final String? Function() _currentUserId;

  String get _uid => _currentUserId() ?? 'local';

  @override
  Future<List<Exercise>> list({
    int page = 0,
    int pageSize = 30,
    ExerciseFilter filter = const ExerciseFilter(),
    String query = '',
  }) async {
    var all = await _source.search(filter: filter, query: query);

    if (filter.favoritesOnly) {
      final favs = _userStore.favoriteIds(_uid);
      all = all.where((e) => favs.contains(e.id)).toList();
    }

    all = _sort(all, filter.sort);

    final start = page * pageSize;
    if (start >= all.length) return const [];
    return all.sublist(start, (start + pageSize).clamp(0, all.length));
  }

  List<Exercise> _sort(List<Exercise> list, ExerciseSort sort) {
    if (sort == ExerciseSort.name) return list; // fonte já ordena por nome
    final hist = _userStore.history(_uid);
    final sorted = [...list];
    switch (sort) {
      case ExerciseSort.recent:
        sorted.sort((a, b) {
          final da = hist[a.id]?.lastPerformedAt;
          final db = hist[b.id]?.lastPerformedAt;
          return (db ?? DateTime(0)).compareTo(da ?? DateTime(0));
        });
      case ExerciseSort.mostUsed:
        sorted.sort((a, b) => (hist[b.id]?.timesPerformed ?? 0)
            .compareTo(hist[a.id]?.timesPerformed ?? 0));
      case ExerciseSort.name:
        break;
    }
    return sorted;
  }

  @override
  Future<Exercise?> getById(String id) => _source.byId(id);

  @override
  Future<List<Exercise>> getByIds(List<String> ids) => _source.byIds(ids);

  @override
  Future<int> total() => _source.count();

  @override
  Set<String> favorites() => _userStore.favoriteIds(_uid);

  @override
  bool isFavorite(String id) => favorites().contains(id);

  @override
  Future<void> toggleFavorite(String id) async {
    final favs = {...favorites()};
    favs.contains(id) ? favs.remove(id) : favs.add(id);
    await _userStore.writeFavorites(_uid, favs);
  }

  @override
  ExerciseHistorySummary? historyFor(String id) =>
      _userStore.history(_uid)[id];
}
