import '../../workout/domain/workout_enums.dart';

/// Série executada durante a sessão (PROMPT 06).
///
/// Diferente da série planejada (Workout Engine): guarda o que foi
/// efetivamente realizado (peso, reps, RPE, concluído).
class WorkoutSetSession {
  const WorkoutSetSession({
    required this.id,
    required this.setNumber,
    this.type = SetType.normal,
    this.targetReps = '',
    this.weight,
    this.reps,
    this.rpe,
    this.completed = false,
    this.restSeconds = 90,
    this.note,
  });

  final String id;
  final int setNumber;
  final SetType type;
  final String targetReps;
  final double? weight;
  final int? reps;
  final double? rpe;
  final bool completed;
  final int restSeconds;
  final String? note;

  bool get isWarmup => type == SetType.warmup;
  double get volume =>
      completed && !isWarmup ? (weight ?? 0) * (reps ?? 0) : 0;

  WorkoutSetSession copyWith({
    double? weight,
    int? reps,
    double? rpe,
    bool? completed,
    int? restSeconds,
    String? note,
    SetType? type,
  }) {
    return WorkoutSetSession(
      id: id,
      setNumber: setNumber,
      type: type ?? this.type,
      targetReps: targetReps,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      completed: completed ?? this.completed,
      restSeconds: restSeconds ?? this.restSeconds,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'set_number': setNumber,
        'type': type.name,
        'target_reps': targetReps,
        'weight': weight,
        'reps': reps,
        'rpe': rpe,
        'completed': completed,
        'rest_seconds': restSeconds,
        'note': note,
      };

  factory WorkoutSetSession.fromMap(Map<String, dynamic> m) =>
      WorkoutSetSession(
        id: m['id'] as String,
        setNumber: (m['set_number'] as num?)?.toInt() ?? 1,
        type: SetType.fromName(m['type'] as String?),
        targetReps: (m['target_reps'] ?? '') as String,
        weight: (m['weight'] as num?)?.toDouble(),
        reps: (m['reps'] as num?)?.toInt(),
        rpe: (m['rpe'] as num?)?.toDouble(),
        completed: (m['completed'] as bool?) ?? false,
        restSeconds: (m['rest_seconds'] as num?)?.toInt() ?? 90,
        note: m['note'] as String?,
      );
}
