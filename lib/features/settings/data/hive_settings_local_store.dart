import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../domain/settings_local_store.dart';

/// Implementação Hive do [SettingsLocalStore].
///
/// As preferências são de nível de dispositivo — guardadas numa única
/// chave na box de cache (reutiliza `boxCache`, evitando nova box no
/// bootstrap).
final class HiveSettingsLocalStore implements SettingsLocalStore {
  const HiveSettingsLocalStore(this._storage);

  final LocalStorageService _storage;

  static const _key = 'settings_app';

  @override
  Map<String, dynamic>? read() {
    final raw =
        _storage.get<Map<dynamic, dynamic>>(AppConstants.boxCache, _key);
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw);
  }

  @override
  Future<void> write(Map<String, dynamic> data) =>
      _storage.put(AppConstants.boxCache, _key, data);
}
