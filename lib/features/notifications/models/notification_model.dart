import '../domain/notification_enums.dart';

/// Status de uma notificação no histórico.
enum NotificationStatus { scheduled, delivered, read, cancelled }

/// Notificação (histórico e exibição) — PROMPT 15.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.type,
    this.priority = NotificationPriority.medium,
    this.action = NotificationAction.none,
    this.status = NotificationStatus.delivered,
    this.scheduledAt,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final NotificationType type;
  final NotificationPriority priority;
  final NotificationAction action;
  final NotificationStatus status;
  final DateTime? scheduledAt;
  final DateTime? createdAt;

  /// ID inteiro estável para o plugin de notificações locais.
  int get platformId => id.hashCode & 0x7fffffff;

  bool get isRead => status == NotificationStatus.read;

  NotificationModel copyWith({NotificationStatus? status}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        category: category,
        type: type,
        priority: priority,
        action: action,
        status: status ?? this.status,
        scheduledAt: scheduledAt,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category.name,
        'type': type.name,
        'priority': priority.name,
        'action': action.name,
        'status': status.name,
        'scheduled_at': scheduledAt?.toIso8601String(),
        'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory NotificationModel.fromMap(Map<String, dynamic> m) => NotificationModel(
        id: m['id'] as String,
        title: (m['title'] ?? '') as String,
        body: (m['body'] ?? '') as String,
        category: NotificationCategory.values.byName(
          (m['category'] ?? 'system') as String,
        ),
        type: NotificationType.values.byName((m['type'] ?? 'info') as String),
        priority: NotificationPriority.values.byName(
          (m['priority'] ?? 'medium') as String,
        ),
        action: NotificationAction.fromName(m['action'] as String?),
        status: NotificationStatus.values.byName(
          (m['status'] ?? 'delivered') as String,
        ),
        scheduledAt: m['scheduled_at'] != null
            ? DateTime.tryParse(m['scheduled_at'] as String)
            : null,
        createdAt: m['created_at'] != null
            ? DateTime.tryParse(m['created_at'] as String)
            : null,
      );
}
