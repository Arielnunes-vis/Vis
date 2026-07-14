import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/settings/data/settings_repository_impl.dart';
import 'package:vis/features/settings/domain/app_settings.dart';
import 'package:vis/features/settings/domain/settings_enums.dart';
import 'package:vis/features/settings/domain/settings_local_store.dart';

class _MemStore implements SettingsLocalStore {
  Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? read() => _data;
  @override
  Future<void> write(Map<String, dynamic> data) async => _data = data;
}

void main() {
  test('retorna padrões quando nada foi salvo', () {
    final repo = SettingsRepositoryImpl(store: _MemStore());
    final s = repo.load();
    expect(s.unitSystem, UnitSystem.metric);
    expect(s.defaultRestSeconds, 90);
    expect(s.hapticsEnabled, isTrue);
    expect(s.soundEnabled, isTrue);
  });

  test('persiste e recarrega as configurações', () async {
    final store = _MemStore();
    final repo = SettingsRepositoryImpl(store: store);

    await repo.save(const AppSettings(
      unitSystem: UnitSystem.imperial,
      defaultRestSeconds: 120,
      hapticsEnabled: false,
      soundEnabled: false,
    ));

    final loaded = repo.load();
    expect(loaded.unitSystem, UnitSystem.imperial);
    expect(loaded.defaultRestSeconds, 120);
    expect(loaded.hapticsEnabled, isFalse);
    expect(loaded.soundEnabled, isFalse);
  });

  test('toMap/fromMap preservam os valores', () {
    const original = AppSettings(
      unitSystem: UnitSystem.imperial,
      defaultRestSeconds: 150,
      hapticsEnabled: false,
    );
    final restored = AppSettings.fromMap(original.toMap());
    expect(restored.unitSystem, original.unitSystem);
    expect(restored.defaultRestSeconds, original.defaultRestSeconds);
    expect(restored.hapticsEnabled, original.hapticsEnabled);
    expect(restored.soundEnabled, original.soundEnabled);
  });

  test('UnitSystem.fromName é tolerante a valores inválidos', () {
    expect(UnitSystem.fromName('imperial'), UnitSystem.imperial);
    expect(UnitSystem.fromName(null), UnitSystem.metric);
    expect(UnitSystem.fromName('xyz'), UnitSystem.metric);
  });
}
