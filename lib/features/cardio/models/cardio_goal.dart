import '../domain/cardio_enums.dart';

/// Meta de cardio (PROMPT 09). Ex.: 150 minutos por semana.
class CardioGoal {
  const CardioGoal({
    required this.id,
    required this.userId,
    required this.metric,
    required this.period,
    required this.target,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final CardioGoalMetric metric;
  final CardioGoalPeriod period;
  final double target;
  final DateTime createdAt;

  String get label =>
      '${target.toStringAsFixed(0)} ${metric.label.toLowerCase()} ${period.label}';

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'metric': metric.name,
        'period': period.name,
        'target': target,
        'created_at': createdAt.toIso8601String(),
      };

  factory CardioGoal.fromMap(Map<String, dynamic> m) => CardioGoal(
        id: m['id'] as String,
        userId: (m['user_id'] ?? '') as String,
        metric: CardioGoalMetric.fromName(m['metric'] as String?),
        period: CardioGoalPeriod.fromName(m['period'] as String?),
        target: (m['target'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}
