import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/notification_enums.dart';
import '../models/notification_model.dart';
import '../models/notification_preferences.dart';
import '../models/reminder.dart';
import '../providers/notification_providers.dart';

/// Estado do módulo de notificações.
class NotificationState {
  const NotificationState({
    this.history = const [],
    this.reminders = const [],
    this.preferences = const NotificationPreferences(),
  });

  final List<NotificationModel> history;
  final List<Reminder> reminders;
  final NotificationPreferences preferences;

  int get unread =>
      history.where((n) => n.status != NotificationStatus.read).length;

  NotificationState copyWith({
    List<NotificationModel>? history,
    List<Reminder>? reminders,
    NotificationPreferences? preferences,
  }) {
    return NotificationState(
      history: history ?? this.history,
      reminders: reminders ?? this.reminders,
      preferences: preferences ?? this.preferences,
    );
  }
}

/// Controller de notificações (PROMPT 15).
class NotificationController extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    final repo = ref.read(notificationRepositoryProvider);
    return NotificationState(
      history: repo.history(),
      reminders: repo.reminders(),
      preferences: repo.preferences(),
    );
  }

  NotificationRepository get _repo =>
      ref.read(notificationRepositoryProvider);

  Future<void> refresh() async {
    state = state.copyWith(
      history: _repo.history(),
      reminders: _repo.reminders(),
      preferences: _repo.preferences(),
    );
  }

  // ----- Preferências -----
  Future<void> toggleCategory(NotificationCategory c) async {
    final set = {...state.preferences.enabledCategories};
    set.contains(c) ? set.remove(c) : set.add(c);
    await _savePrefs(state.preferences.copyWith(enabledCategories: set));
  }

  Future<void> setSound(bool v) =>
      _savePrefs(state.preferences.copyWith(soundEnabled: v));
  Future<void> setVibration(bool v) =>
      _savePrefs(state.preferences.copyWith(vibrationEnabled: v));
  Future<void> setSilent(bool v) =>
      _savePrefs(state.preferences.copyWith(silentMode: v));

  Future<void> _savePrefs(NotificationPreferences prefs) async {
    await _repo.savePreferences(prefs);
    state = state.copyWith(preferences: prefs);
  }

  // ----- Lembretes -----
  Future<void> saveReminder(Reminder reminder) async {
    await _repo.saveReminder(reminder);
    state = state.copyWith(reminders: _repo.reminders());
  }

  Future<void> removeReminder(String id) async {
    await _repo.removeReminder(id);
    state = state.copyWith(reminders: _repo.reminders());
  }

  // ----- Histórico -----
  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    state = state.copyWith(history: _repo.history());
  }

  Future<void> clearHistory() async {
    await _repo.clearHistory();
    state = state.copyWith(history: const []);
  }
}
