import '../models/notification_model.dart';
import '../models/notification_preferences.dart';
import '../models/reminder.dart';

/// Contrato do repositório de notificações (PROMPT 15).
abstract interface class NotificationRepository {
  Future<void> initialize();

  // Histórico
  List<NotificationModel> history();
  Future<void> record(NotificationModel notification);
  Future<void> markAsRead(String id);
  Future<void> clearHistory();

  // Preferências
  NotificationPreferences preferences();
  Future<void> savePreferences(NotificationPreferences prefs);

  // Lembretes (persistidos + agendados no dispositivo)
  List<Reminder> reminders();
  Future<void> saveReminder(Reminder reminder);
  Future<void> removeReminder(String id);

  /// Exibe imediatamente (respeitando as preferências/categoria).
  Future<void> showNow(NotificationModel notification);
}
