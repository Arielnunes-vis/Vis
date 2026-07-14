import 'settings_enums.dart';

/// Preferências do aplicativo (PROMPT 17).
///
/// Configurações de nível de dispositivo (não histórico do usuário):
/// unidades, tempo de descanso padrão e feedback. Imutável, com
/// [copyWith] e (de)serialização para persistência offline.
class AppSettings {
  const AppSettings({
    this.unitSystem = UnitSystem.metric,
    this.defaultRestSeconds = 90,
    this.hapticsEnabled = true,
    this.soundEnabled = true,
  });

  final UnitSystem unitSystem;

  /// Tempo de descanso padrão sugerido entre séries (segundos).
  final int defaultRestSeconds;

  /// Feedback tátil (vibração) em ações e cronômetro.
  final bool hapticsEnabled;

  /// Som ao concluir descanso/treino.
  final bool soundEnabled;

  static const defaults = AppSettings();

  AppSettings copyWith({
    UnitSystem? unitSystem,
    int? defaultRestSeconds,
    bool? hapticsEnabled,
    bool? soundEnabled,
  }) {
    return AppSettings(
      unitSystem: unitSystem ?? this.unitSystem,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'unit_system': unitSystem.name,
        'default_rest_seconds': defaultRestSeconds,
        'haptics_enabled': hapticsEnabled,
        'sound_enabled': soundEnabled,
      };

  factory AppSettings.fromMap(Map<String, dynamic> m) => AppSettings(
        unitSystem: UnitSystem.fromName(m['unit_system'] as String?),
        defaultRestSeconds:
            (m['default_rest_seconds'] as num?)?.toInt() ?? 90,
        hapticsEnabled: m['haptics_enabled'] as bool? ?? true,
        soundEnabled: m['sound_enabled'] as bool? ?? true,
      );
}
