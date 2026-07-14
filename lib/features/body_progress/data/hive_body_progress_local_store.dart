import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../domain/body_progress_local_store.dart';

/// Implementação Hive do [BodyProgressLocalStore] (box `vis_measurements`).
final class HiveBodyProgressLocalStore implements BodyProgressLocalStore {
  const HiveBodyProgressLocalStore(this._storage);

  final LocalStorageService _storage;

  String _key(String userId, String collection) => 'bp_${collection}_$userId';

  @override
  List<Map<String, dynamic>> read(String userId, String collection) {
    final raw = _storage.get<List<dynamic>>(
          AppConstants.boxMeasurements,
          _key(userId, collection),
        ) ??
        const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<void> write(
    String userId,
    String collection,
    List<Map<String, dynamic>> items,
  ) =>
      _storage.put(
        AppConstants.boxMeasurements,
        _key(userId, collection),
        items,
      );
}
