import '../../workout/models/exercise_ref.dart';
import 'workout_set_session.dart';

/// Exercício em execução na sessão (PROMPT 06).
class WorkoutExerciseSession {
  const WorkoutExerciseSession({
    required this.id,
    required this.exercise,
    this.sets = const [],
    this.note,
  });

  final String id;
  final ExerciseRef exercise;
  final List<WorkoutSetSession> sets;
  final String? note;

  double get volume => sets.fold(0, (sum, s) => sum + s.volume);
  int get completedSets => sets.where((s) => s.completed).length;
  int get totalSets => sets.length;
  bool get isCompleted => sets.isNotEmpty && completedSets == totalSets;

  double? get maxWeight {
    final done = sets.where((s) => s.completed && s.weight != null);
    if (done.isEmpty) return null;
    return done.map((s) => s.weight!).reduce((a, b) => a > b ? a : b);
  }

  int? get maxReps {
    final done = sets.where((s) => s.completed && s.reps != null);
    if (done.isEmpty) return null;
    return done.map((s) => s.reps!).reduce((a, b) => a > b ? a : b);
  }

  WorkoutExerciseSession copyWith({
    List<WorkoutSetSession>? sets,
    String? note,
  }) {
    return WorkoutExerciseSession(
      id: id,
      exercise: exercise,
      sets: sets ?? this.sets,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'exercise': exercise.toMap(),
        'note': note,
        'sets': sets.map((s) => s.toMap()).toList(),
      };

  factory WorkoutExerciseSession.fromMap(Map<String, dynamic> m) =>
      WorkoutExerciseSession(
        id: m['id'] as String,
        exercise:
            ExerciseRef.fromMap(Map<String, dynamic>.from(m['exercise'] as Map)),
        note: m['note'] as String?,
        sets: (m['sets'] as List? ?? [])
            .map((e) =>
                WorkoutSetSession.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
