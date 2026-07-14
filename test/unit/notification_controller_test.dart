import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/notifications/controllers/notification_controller.dart';
import 'package:vis/features/notifications/domain/notification_enums.dart';
import 'package:vis/features/notifications/models/notification_model.dart';
import 'package:vis/features/notifications/models/notification_preferences.dart';
import 'package:vis/features/notifications/models/reminder.dart';
import 'package:vis/features/notifications/providers/notification_providers.dart';
import 'package:vis/features/notifications/repositories/notification_repository.dart';

/// Repositório em memória para testar o controller sem Hive/plugin.
class InMemoryNotificationRepository implements NotificationRepository {
  final List<NotificationModel> _history = [];
  final List<Reminder> _reminders = [];
  NotificationPreferences _prefs = const NotificationPreferences();

  @override
  Future<void> initialize() async {}

  @override
  List<NotificationModel> history() => List.unmodifiable(_history);

  @override
  Future<void> record(NotificationModel n) async => _history.insert(0, n);

  @override
  Future<void> markAsRead(String id) async {
    for (var i = 0; i < _history.length; i++) {
      if (_history[i].id == id) {
        _history[i] = _history[i].copyWith(status: NotificationStatus.read);
      }
    }
  }

  @override
  Future<void> clearHistory() async => _history.clear();

  @override
  NotificationPreferences preferences() => _prefs;

  @override
  Future<void> savePreferences(NotificationPreferences prefs) async =>
      _prefs = prefs;

  @override
  List<Reminder> reminders() => List.unmodifiable(_reminders);

  @override
  Future<void> saveReminder(Reminder reminder) async {
    _reminders
      ..removeWhere((r) => r.id == reminder.id)
      ..add(reminder);
  }

  @override
  Future<void> removeReminder(String id) async =>
      _reminders.removeWhere((r) => r.id == id);

  @override
  Future<void> showNow(NotificationModel notification) async =>
      record(notification);
}

ProviderContainer _container(InMemoryNotificationRepository repo) =>
    ProviderContainer(
      overrides: [notificationRepositoryProvider.overrideWithValue(repo)],
    );

void main() {
  test('toggleCategory ativa/desativa e persiste', () async {
    final repo = InMemoryNotificationRepository();
    final container = _container(repo);
    addTearDown(container.dispose);

    final c = container.read(notificationControllerProvider.notifier);
    await c.toggleCategory(NotificationCategory.photos);

    expect(
      container
          .read(notificationControllerProvider)
          .preferences
          .enabledCategories
          .contains(NotificationCategory.photos),
      isTrue,
    );
  });

  test('salvar lembrete adiciona à lista', () async {
    final repo = InMemoryNotificationRepository();
    final container = _container(repo);
    addTearDown(container.dispose);

    final c = container.read(notificationControllerProvider.notifier);
    await c.saveReminder(const Reminder(
      id: 'r1',
      category: NotificationCategory.workout,
      title: 'Hora de treinar',
      message: 'Bora?',
      time: ReminderTime(18, 30),
    ));

    expect(container.read(notificationControllerProvider).reminders.length, 1);
  });

  test('marcar como lida reduz contagem de não lidas', () async {
    final repo = InMemoryNotificationRepository()
      ..record(const NotificationModel(
        id: 'n1',
        title: 'PR!',
        body: 'Novo recorde',
        category: NotificationCategory.workout,
        type: NotificationType.achievement,
      ));
    final container = _container(repo);
    addTearDown(container.dispose);

    final c = container.read(notificationControllerProvider.notifier);
    await c.refresh();
    expect(container.read(notificationControllerProvider).unread, 1);

    await c.markAsRead('n1');
    expect(container.read(notificationControllerProvider).unread, 0);
  });
}
