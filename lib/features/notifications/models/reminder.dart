import '../domain/notification_enums.dart';

/// Frequência de repetição de um lembrete.
enum ReminderRepeat { once, daily, weekly, weekdays, custom }

/// Horário simples (hora/minuto) sem depender de DateTime.
class ReminderTime {
  const ReminderTime(this.hour, this.minute);
  final int hour;
  final int minute;

  Map<String, dynamic> toMap() => {'hour': hour, 'minute': minute};
  factory ReminderTime.fromMap(Map<String, dynamic> m) =>
      ReminderTime((m['hour'] as num).toInt(), (m['minute'] as num).toInt());

  String get label =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Lembrete configurável (treino, água, peso, fotos...) — PROMPT 15.
class Reminder {
  const Reminder({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.time,
    this.repeat = ReminderRepeat.daily,
    this.weekdays = const [],
    this.enabled = true,
  });

  final String id;
  final NotificationCategory category;
  final String title;
  final String message;
  final ReminderTime time;
  final ReminderRepeat repeat;

  /// Dias da semana (1=segunda ... 7=domingo) quando [repeat] é weekly/custom.
  final List<int> weekdays;
  final bool enabled;

  int get platformId => id.hashCode & 0x7fffffff;

  Reminder copyWith({
    ReminderTime? time,
    ReminderRepeat? repeat,
    List<int>? weekdays,
    bool? enabled,
    String? message,
  }) {
    return Reminder(
      id: id,
      category: category,
      title: title,
      message: message ?? this.message,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      weekdays: weekdays ?? this.weekdays,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category.name,
        'title': title,
        'message': message,
        'time': time.toMap(),
        'repeat': repeat.name,
        'weekdays': weekdays,
        'enabled': enabled,
      };

  factory Reminder.fromMap(Map<String, dynamic> m) => Reminder(
        id: m['id'] as String,
        category: NotificationCategory.values.byName(m['category'] as String),
        title: (m['title'] ?? '') as String,
        message: (m['message'] ?? '') as String,
        time: ReminderTime.fromMap(Map<String, dynamic>.from(m['time'] as Map)),
        repeat: ReminderRepeat.values.byName((m['repeat'] ?? 'daily') as String),
        weekdays:
            (m['weekdays'] as List? ?? []).map((e) => (e as num).toInt()).toList(),
        enabled: (m['enabled'] as bool?) ?? true,
      );
}
