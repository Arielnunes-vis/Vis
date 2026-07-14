import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/logger/app_logger.dart';
import '../models/notification_model.dart';
import '../models/reminder.dart';

/// Serviço de notificações locais (PROMPT 15).
///
/// Envolve o `flutter_local_notifications` + `timezone`. Responsável
/// por mostrar, agendar (com repetição), atualizar e cancelar
/// notificações no dispositivo. Funciona offline.
abstract interface class ILocalNotificationService {
  Future<void> initialize();
  Future<bool> requestPermissions();

  Future<void> show(NotificationModel notification);

  Future<void> scheduleReminder(
    Reminder reminder, {
    bool sound = true,
    bool vibration = true,
  });

  Future<void> cancel(int platformId);
  Future<void> cancelAll();
}

final class LocalNotificationService implements ILocalNotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const String _channelId = 'vis_reminders';
  static const String _channelName = 'Lembretes VIS';

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings);
    _initialized = true;
    AppLogger.i('[Notifications] plugin local inicializado.');
  }

  /// Define o fuso horário local (o app pode passar o nome do dispositivo).
  void configureTimeZone(String timeZoneName) {
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Mantém UTC como fallback, mas registra para diagnóstico.
      AppLogger.w('[Notifications] fuso "$timeZoneName" inválido; usando UTC.',
          error: e);
    }
  }

  @override
  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: true, sound: true);

    return androidGranted ?? iosGranted ?? true;
  }

  NotificationDetails _details({bool sound = true, bool vibration = true}) {
    final android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Lembretes e alertas do VIS',
      importance: Importance.high,
      priority: Priority.high,
      playSound: sound,
      enableVibration: vibration,
    );
    final ios = DarwinNotificationDetails(presentSound: sound);
    return NotificationDetails(android: android, iOS: ios);
  }

  @override
  Future<void> show(NotificationModel n) async {
    await initialize();
    await _plugin.show(n.platformId, n.title, n.body, _details());
  }

  @override
  Future<void> scheduleReminder(
    Reminder reminder, {
    bool sound = true,
    bool vibration = true,
  }) async {
    await initialize();
    if (!reminder.enabled) {
      await cancel(reminder.platformId);
      return;
    }

    final details = _details(sound: sound, vibration: vibration);

    // Repetição única de agendamento por dia da semana.
    if (reminder.repeat == ReminderRepeat.weekly ||
        reminder.repeat == ReminderRepeat.custom) {
      // Agenda uma notificação por dia da semana selecionado.
      for (final weekday in reminder.weekdays) {
        await _plugin.zonedSchedule(
          reminder.platformId + weekday,
          reminder.title,
          reminder.message,
          _nextInstance(reminder.time, weekday: weekday),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
      return;
    }

    // Diário / uma vez.
    await _plugin.zonedSchedule(
      reminder.platformId,
      reminder.title,
      reminder.message,
      _nextInstance(reminder.time),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: reminder.repeat == ReminderRepeat.daily
          ? DateTimeComponents.time
          : null,
    );
  }

  /// Calcula a próxima ocorrência de [time] (opcionalmente num [weekday]).
  tz.TZDateTime _nextInstance(ReminderTime time, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (weekday != null) {
      while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    } else if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  @override
  Future<void> cancel(int platformId) => _plugin.cancel(platformId);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
