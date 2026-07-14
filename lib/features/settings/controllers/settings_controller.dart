import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_settings.dart';
import '../domain/settings_enums.dart';
import '../providers/settings_providers.dart';

/// Controlador das configurações (PROMPT 17).
///
/// Carrega os padrões/persistidos no [build] e grava a cada alteração,
/// mantendo o estado e o armazenamento sincronizados (offline-first).
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsRepositoryProvider).load();

  Future<void> setUnitSystem(UnitSystem system) =>
      _update(state.copyWith(unitSystem: system));

  Future<void> setDefaultRestSeconds(int seconds) =>
      _update(state.copyWith(defaultRestSeconds: seconds));

  Future<void> setHaptics(bool enabled) =>
      _update(state.copyWith(hapticsEnabled: enabled));

  Future<void> setSound(bool enabled) =>
      _update(state.copyWith(soundEnabled: enabled));

  Future<void> _update(AppSettings next) async {
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }
}
