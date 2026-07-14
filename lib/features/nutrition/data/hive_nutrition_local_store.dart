import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../domain/nutrition_local_store.dart';

/// Implementação Hive do [NutritionLocalStore] (box `vis_cache`).
final class HiveNutritionLocalStore implements NutritionLocalStore {
  const HiveNutritionLocalStore(this._storage);

  final LocalStorageService _storage;

  String _key(String userId, String name) => 'nutri_${name}_$userId';

  @override
  List<Map<String, dynamic>> readList(String userId, String collection) {
    final raw = _storage.get<List<dynamic>>(
          AppConstants.boxCache,
          _key(userId, collection),
        ) ??
        const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<void> writeList(
    String userId,
    String collection,
    List<Map<String, dynamic>> items,
  ) =>
      _storage.put(AppConstants.boxCache, _key(userId, collection), items);

  @override
  Map<String, dynamic>? readMap(String userId, String key) {
    final raw = _storage.get<Map<dynamic, dynamic>>(
      AppConstants.boxCache,
      _key(userId, key),
    );
    return raw == null ? null : Map<String, dynamic>.from(raw);
  }

  @override
  Future<void> writeMap(
    String userId,
    String key,
    Map<String, dynamic> value,
  ) =>
      _storage.put(AppConstants.boxCache, _key(userId, key), value);
}
