import '../domain/notification_enums.dart';

/// Preferências de notificação por categoria + som/vibração (PROMPT 15).
class NotificationPreferences {
  const NotificationPreferences({
    this.enabledCategories = const {
      NotificationCategory.workout,
      NotificationCategory.water,
      NotificationCategory.ai,
    },
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.silentMode = false,
    this.hideSensitiveOnLockScreen = true,
  });

  final Set<NotificationCategory> enabledCategories;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool silentMode;
  final bool hideSensitiveOnLockScreen;

  bool isEnabled(NotificationCategory c) =>
      !silentMode && enabledCategories.contains(c);

  NotificationPreferences copyWith({
    Set<NotificationCategory>? enabledCategories,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? silentMode,
    bool? hideSensitiveOnLockScreen,
  }) {
    return NotificationPreferences(
      enabledCategories: enabledCategories ?? this.enabledCategories,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      silentMode: silentMode ?? this.silentMode,
      hideSensitiveOnLockScreen:
          hideSensitiveOnLockScreen ?? this.hideSensitiveOnLockScreen,
    );
  }

  Map<String, dynamic> toMap() => {
        'enabled_categories': enabledCategories.map((c) => c.name).toList(),
        'sound_enabled': soundEnabled,
        'vibration_enabled': vibrationEnabled,
        'silent_mode': silentMode,
        'hide_sensitive': hideSensitiveOnLockScreen,
      };

  factory NotificationPreferences.fromMap(Map<String, dynamic> m) {
    final cats = (m['enabled_categories'] as List? ?? [])
        .map((e) => NotificationCategory.values.byName(e as String))
        .toSet();
    return NotificationPreferences(
      enabledCategories: cats.isEmpty
          ? const {NotificationCategory.workout}
          : cats,
      soundEnabled: (m['sound_enabled'] as bool?) ?? true,
      vibrationEnabled: (m['vibration_enabled'] as bool?) ?? true,
      silentMode: (m['silent_mode'] as bool?) ?? false,
      hideSensitiveOnLockScreen: (m['hide_sensitive'] as bool?) ?? true,
    );
  }
}
