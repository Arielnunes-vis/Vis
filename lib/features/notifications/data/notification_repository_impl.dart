import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/notification_model.dart';
import '../models/notification_preferences.dart';
import '../models/reminder.dart';
import '../repositories/notification_repository.dart';
import '../services/local_notification_service.dart';

/// Implementação do [NotificationRepository].
///
/// Persiste histórico, preferências e lembretes localmente (Hive) e
/// agenda/cancela via [ILocalNotificationService]. Tudo funciona
/// offline (PROMPT 15).
final class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required ILocalNotificationService local,
    required LocalStorageService storage,
  })  : _local = local,
        _storage = storage;

  final ILocalNotificationService _local;
  final LocalStorageService _storage;

  static const _kHistory = 'notif_history';
  static const _kPrefs = 'notif_prefs';
  static const _kReminders = 'notif_reminders';
  String get _box => AppConstants.boxCache;

  @override
  Future<void> initialize() => _local.initialize();

  // ---------- Histórico ----------
  @override
  List<NotificationModel> history() {
    final raw = _storage.get<List<dynamic>>(_box, _kHistory) ?? [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => NotificationModel.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0)));
  }

  @override
  Future<void> record(NotificationModel notification) async {
    final list = [notification, ...history()].take(100).toList();
    await _persistHistory(list);
  }

  @override
  Future<void> markAsRead(String id) async {
    final list = history()
        .map((n) => n.id == id
            ? n.copyWith(status: NotificationStatus.read)
            : n)
        .toList();
    await _persistHistory(list);
  }

  @override
  Future<void> clearHistory() => _storage.delete(_box, _kHistory);

  Future<void> _persistHistory(List<NotificationModel> list) =>
      _storage.put(_box, _kHistory, list.map((n) => n.toMap()).toList());

  // ---------- Preferências ----------
  @override
  NotificationPreferences preferences() {
    final raw = _storage.get<Map<dynamic, dynamic>>(_box, _kPrefs);
    if (raw == null) return const NotificationPreferences();
    return NotificationPreferences.fromMap(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> savePreferences(NotificationPreferences prefs) =>
      _storage.put(_box, _kPrefs, prefs.toMap());

  // ---------- Lembretes ----------
  @override
  List<Reminder> reminders() {
    final raw = _storage.get<List<dynamic>>(_box, _kReminders) ?? [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Reminder.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> saveReminder(Reminder reminder) async {
    final list = reminders().where((r) => r.id != reminder.id).toList()
      ..add(reminder);
    await _storage.put(_box, _kReminders, list.map((r) => r.toMap()).toList());

    final prefs = preferences();
    await _local.scheduleReminder(
      reminder,
      sound: prefs.soundEnabled,
      vibration: prefs.vibrationEnabled,
    );
  }

  @override
  Future<void> removeReminder(String id) async {
    final target = reminders().where((r) => r.id == id).toList();
    final list = reminders().where((r) => r.id != id).toList();
    await _storage.put(_box, _kReminders, list.map((r) => r.toMap()).toList());
    for (final r in target) {
      await _local.cancel(r.platformId);
    }
  }

  // ---------- Exibição imediata ----------
  @override
  Future<void> showNow(NotificationModel notification) async {
    final prefs = preferences();
    await record(notification);
    if (prefs.isEnabled(notification.category)) {
      await _local.show(notification);
    }
  }
}
