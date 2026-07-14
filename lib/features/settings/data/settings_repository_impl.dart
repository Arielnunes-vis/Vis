import '../domain/app_settings.dart';
import '../domain/settings_local_store.dart';
import '../repositories/settings_repository.dart';

/// Implementação offline-first do [SettingsRepository] (PROMPT 17).
final class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({required SettingsLocalStore store})
      : _store = store;

  final SettingsLocalStore _store;

  @override
  AppSettings load() {
    final map = _store.read();
    return map == null ? AppSettings.defaults : AppSettings.fromMap(map);
  }

  @override
  Future<void> save(AppSettings settings) => _store.write(settings.toMap());
}
