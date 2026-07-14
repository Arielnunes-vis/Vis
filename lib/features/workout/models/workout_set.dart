import '../domain/workout_enums.dart';

/// Série PLANEJADA de um exercício (PROMPT 04).
///
/// Representa a meta configurada no plano (não a execução, que pertence
/// ao módulo Workout Session). Suporta técnicas avançadas via [type].
class WorkoutSet {
  const WorkoutSet({
    required this.setNumber,
    this.type = SetType.normal,
    this.targetReps = '8-12',
    this.targetWeight,
    this.targetRpe,
    this.restSeconds = 90,
  });

  final int setNumber;
  final SetType type;
  final String targetReps;
  final double? targetWeight;
  final double? targetRpe;
  final int restSeconds;

  bool get isWarmup => type == SetType.warmup;

  WorkoutSet copyWith({
    int? setNumber,
    SetType? type,
    String? targetReps,
    double? targetWeight,
    double? targetRpe,
    int? restSeconds,
  }) {
    return WorkoutSet(
      setNumber: setNumber ?? this.setNumber,
      type: type ?? this.type,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      targetRpe: targetRpe ?? this.targetRpe,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  Map<String, dynamic> toMap() => {
        'set_number': setNumber,
        'type': type.name,
        'target_reps': targetReps,
        'target_weight': targetWeight,
        'target_rpe': targetRpe,
        'rest_seconds': restSeconds,
      };

  factory WorkoutSet.fromMap(Map<String, dynamic> m) => WorkoutSet(
        setNumber: (m['set_number'] as num?)?.toInt() ?? 1,
        type: SetType.fromName(m['type'] as String?),
        targetReps: (m['target_reps'] ?? '8-12').toString(),
        targetWeight: (m['target_weight'] as num?)?.toDouble(),
        targetRpe: (m['target_rpe'] as num?)?.toDouble(),
        restSeconds: (m['rest_seconds'] as num?)?.toInt() ?? 90,
      );
}
