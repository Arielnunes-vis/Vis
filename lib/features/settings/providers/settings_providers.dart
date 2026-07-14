import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../controllers/settings_controller.dart';
import '../data/hive_settings_local_store.dart';
import '../data/settings_repository_impl.dart';
import '../domain/app_settings.dart';
import '../domain/settings_enums.dart';
import '../repositories/settings_repository.dart';

/// Providers do módulo de Configurações (PROMPT 17).

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => const SettingsRepositoryImpl(
    store: HiveSettingsLocalStore(LocalStorageService()),
  ),
);

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// Conveniências para consumo por outros módulos, sem observar o objeto
/// inteiro (rebuild mínimo — Regra 009).
final unitSystemProvider = Provider<UnitSystem>(
  (ref) =>
      ref.watch(settingsControllerProvider.select((s) => s.unitSystem)),
);

final defaultRestSecondsProvider = Provider<int>(
  (ref) => ref
      .watch(settingsControllerProvider.select((s) => s.defaultRestSeconds)),
);
