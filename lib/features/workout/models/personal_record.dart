/// Recorde pessoal de um exercício (PROMPT 04 / tabela `personal_records`).
class PersonalRecord {
  const PersonalRecord({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.repetitions,
    this.estimated1rm,
    this.achievedAt,
  });

  final String id;
  final String userId;
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int repetitions;
  final double? estimated1rm;
  final DateTime? achievedAt;

  /// 1RM estimado pela fórmula de Epley (também há SQL `calculate_estimated_1rm`).
  static double epley1rm(double weight, int reps) =>
      reps <= 1 ? weight : weight * (1 + reps / 30.0);

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'exercise_id': exerciseId,
        'exercise_name': exerciseName,
        'weight': weight,
        'repetitions': repetitions,
        'estimated_1rm': estimated1rm ?? epley1rm(weight, repetitions),
        'achieved_at': (achievedAt ?? DateTime.now()).toIso8601String(),
      };

  factory PersonalRecord.fromMap(Map<String, dynamic> m) => PersonalRecord(
        id: m['id'] as String,
        userId: (m['user_id'] ?? '') as String,
        exerciseId: (m['exercise_id'] ?? '') as String,
        exerciseName: (m['exercise_name'] ?? '') as String,
        weight: (m['weight'] as num?)?.toDouble() ?? 0,
        repetitions: (m['repetitions'] as num?)?.toInt() ?? 0,
        estimated1rm: (m['estimated_1rm'] as num?)?.toDouble(),
        achievedAt: m['achieved_at'] != null
            ? DateTime.tryParse(m['achieved_at'] as String)
            : null,
      );
}
