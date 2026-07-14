import '../domain/session_enums.dart';

/// Recorde pessoal batido durante a sessão (PROMPT 06).
class WorkoutPR {
  const WorkoutPR({
    required this.exerciseId,
    required this.exerciseName,
    required this.kind,
    required this.value,
  });

  final String exerciseId;
  final String exerciseName;
  final PRKind kind;
  final double value;

  String get display {
    switch (kind) {
      case PRKind.maxWeight:
        return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} kg';
      case PRKind.maxVolume:
        return '${value.toStringAsFixed(0)} kg';
      case PRKind.maxReps:
        return '${value.toStringAsFixed(0)} reps';
    }
  }

  Map<String, dynamic> toMap() => {
        'exercise_id': exerciseId,
        'exercise_name': exerciseName,
        'kind': kind.name,
        'value': value,
      };
}
