import 'exercise_ref.dart';
import 'workout_set.dart';

/// Exercício dentro de um dia de treino, com suas séries planejadas
/// e observação pessoal do usuário (PROMPT 04).
class WorkoutExercise {
  const WorkoutExercise({
    required this.id,
    required this.exercise,
    required this.orderIndex,
    this.sets = const [],
    this.personalNotes,
  });

  final String id;
  final ExerciseRef exercise;
  final int orderIndex;
  final List<WorkoutSet> sets;
  final String? personalNotes;

  int get workingSets => sets.where((s) => !s.isWarmup).length;
  int get totalSets => sets.length;

  WorkoutExercise copyWith({
    int? orderIndex,
    List<WorkoutSet>? sets,
    String? personalNotes,
  }) {
    return WorkoutExercise(
      id: id,
      exercise: exercise,
      orderIndex: orderIndex ?? this.orderIndex,
      sets: sets ?? this.sets,
      personalNotes: personalNotes ?? this.personalNotes,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'exercise': exercise.toMap(),
        'order_index': orderIndex,
        'sets': sets.map((s) => s.toMap()).toList(),
        'personal_notes': personalNotes,
      };

  factory WorkoutExercise.fromMap(Map<String, dynamic> m) => WorkoutExercise(
        id: m['id'] as String,
        exercise:
            ExerciseRef.fromMap(Map<String, dynamic>.from(m['exercise'] as Map)),
        orderIndex: (m['order_index'] as num?)?.toInt() ?? 0,
        sets: (m['sets'] as List? ?? [])
            .map((e) => WorkoutSet.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        personalNotes: m['personal_notes'] as String?,
      );
}
