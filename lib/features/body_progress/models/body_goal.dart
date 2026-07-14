import '../domain/body_enums.dart';

/// Meta corporal (PROMPT 08). Ex.: chegar a 78 kg.
class BodyGoal {
  const BodyGoal({
    required this.id,
    required this.userId,
    required this.type,
    required this.target,
    required this.startValue,
    required this.createdAt,
    this.deadline,
    this.note,
  });

  final String id;
  final String userId;
  final GoalType type;
  final double target;
  final double startValue;
  final DateTime createdAt;
  final DateTime? deadline;
  final String? note;

  /// Progresso 0..1 dado o valor atual, considerando a direção
  /// (ganhar ou reduzir em relação ao início).
  double progress(double current) {
    final total = (target - startValue);
    if (total.abs() < 0.001) return current == target ? 1 : 0;
    final done = (current - startValue) / total;
    return done.clamp(0.0, 1.0);
  }

  bool reached(double current) {
    if (target >= startValue) return current >= target;
    return current <= target;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'type': type.name,
        'target': target,
        'start_value': startValue,
        'deadline': deadline?.toIso8601String(),
        'note': note,
        'created_at': createdAt.toIso8601String(),
      };

  factory BodyGoal.fromMap(Map<String, dynamic> m) => BodyGoal(
        id: m['id'] as String,
        userId: (m['user_id'] ?? '') as String,
        type: GoalType.fromName(m['type'] as String?),
        target: (m['target'] as num?)?.toDouble() ?? 0,
        startValue: (m['start_value'] as num?)?.toDouble() ?? 0,
        deadline: m['deadline'] != null
            ? DateTime.tryParse(m['deadline'] as String)
            : null,
        note: m['note'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}
