/// Resumo do histórico de um exercício para o usuário (PROMPT 05).
///
/// Preenchido a partir das sessões de treino (módulo Workout Session).
/// Aqui é um agregado exibível na tela do exercício e usado pela IA.
class ExerciseHistorySummary {
  const ExerciseHistorySummary({
    required this.exerciseId,
    this.lastPerformedAt,
    this.maxWeight,
    this.maxVolume,
    this.maxReps,
    this.timesPerformed = 0,
    this.lastNote,
  });

  final String exerciseId;
  final DateTime? lastPerformedAt;
  final double? maxWeight;
  final double? maxVolume;
  final int? maxReps;
  final int timesPerformed;
  final String? lastNote;

  bool get isEmpty => timesPerformed == 0;

  Map<String, dynamic> toMap() => {
        'exercise_id': exerciseId,
        'last_performed_at': lastPerformedAt?.toIso8601String(),
        'max_weight': maxWeight,
        'max_volume': maxVolume,
        'max_reps': maxReps,
        'times_performed': timesPerformed,
        'last_note': lastNote,
      };

  factory ExerciseHistorySummary.fromMap(Map<String, dynamic> m) =>
      ExerciseHistorySummary(
        exerciseId: m['exercise_id'] as String,
        lastPerformedAt: m['last_performed_at'] != null
            ? DateTime.tryParse(m['last_performed_at'] as String)
            : null,
        maxWeight: (m['max_weight'] as num?)?.toDouble(),
        maxVolume: (m['max_volume'] as num?)?.toDouble(),
        maxReps: (m['max_reps'] as num?)?.toInt(),
        timesPerformed: (m['times_performed'] as num?)?.toInt() ?? 0,
        lastNote: m['last_note'] as String?,
      );
}
