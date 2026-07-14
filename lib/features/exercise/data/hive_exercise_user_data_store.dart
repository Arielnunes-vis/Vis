import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../domain/exercise_user_data_store.dart';
import '../models/exercise_history.dart';

/// Implementação Hive do [ExerciseUserDataStore] (box `vis_cache`).
final class HiveExerciseUserDataStore implements ExerciseUserDataStore {
  const HiveExerciseUserDataStore(this._storage);

  final LocalStorageService _storage;

  String _favKey(String u) => 'ex_favs_$u';
  String _histKey(String u) => 'ex_hist_$u';

  @override
  Set<String> favoriteIds(String userId) {
    final raw = _storage.get<List<dynamic>>(
          AppConstants.boxCache,
          _favKey(userId),
        ) ??
        const [];
    return raw.map((e) => e.toString()).toSet();
  }

  @override
  Future<void> writeFavorites(String userId, Set<String> ids) =>
      _storage.put(AppConstants.boxCache, _favKey(userId), ids.toList());

  @override
  Map<String, ExerciseHistorySummary> history(String userId) {
    final raw = _storage.get<List<dynamic>>(
          AppConstants.boxCache,
          _histKey(userId),
        ) ??
        const [];
    final entries = raw.whereType<Map<dynamic, dynamic>>().map(
          (e) => ExerciseHistorySummary.fromMap(Map<String, dynamic>.from(e)),
        );
    return {for (final h in entries) h.exerciseId: h};
  }

  @override
  Future<void> writeHistory(
    String userId,
    Map<String, ExerciseHistorySummary> history,
  ) =>
      _storage.put(
        AppConstants.boxCache,
        _histKey(userId),
        history.values.map((h) => h.toMap()).toList(),
      );
}
