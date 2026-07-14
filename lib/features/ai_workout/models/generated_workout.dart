import '../domain/ai_workout_enums.dart';

/// Exercício gerado pela IA (PROMPT 12).
class GeneratedExercise {
  const GeneratedExercise({
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.targetReps,
    this.equipment,
    this.suggestedRpe,
    this.restSeconds = 90,
    this.notes,
  });

  final String name;
  final String muscleGroup;
  final int sets;
  final String targetReps; // ex.: "8-12"
  final String? equipment;
  final double? suggestedRpe;
  final int restSeconds;
  final String? notes;

  GeneratedExercise copyWith({
    String? name,
    int? sets,
    String? targetReps,
    double? suggestedRpe,
    int? restSeconds,
    String? notes,
  }) {
    return GeneratedExercise(
      name: name ?? this.name,
      muscleGroup: muscleGroup,
      sets: sets ?? this.sets,
      targetReps: targetReps ?? this.targetReps,
      equipment: equipment,
      suggestedRpe: suggestedRpe ?? this.suggestedRpe,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
    );
  }

  factory GeneratedExercise.fromMap(Map<String, dynamic> m) => GeneratedExercise(
        name: (m['name'] ?? '') as String,
        muscleGroup: (m['muscle_group'] ?? '') as String,
        sets: (m['sets'] as num?)?.toInt() ?? 3,
        targetReps: (m['target_reps'] ?? '8-12').toString(),
        equipment: m['equipment'] as String?,
        suggestedRpe: (m['suggested_rpe'] as num?)?.toDouble(),
        restSeconds: (m['rest_seconds'] as num?)?.toInt() ?? 90,
        notes: m['notes'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'muscle_group': muscleGroup,
        'sets': sets,
        'target_reps': targetReps,
        'equipment': equipment,
        'suggested_rpe': suggestedRpe,
        'rest_seconds': restSeconds,
        'notes': notes,
      };
}

/// Um dia do treino gerado (ex.: Treino A).
class GeneratedWorkoutDay {
  const GeneratedWorkoutDay({
    required this.name,
    required this.exercises,
    this.warmup = const [],
    this.focus,
  });

  final String name;
  final List<GeneratedExercise> exercises;
  final List<String> warmup;
  final String? focus;

  GeneratedWorkoutDay copyWith({
    String? name,
    List<GeneratedExercise>? exercises,
  }) {
    return GeneratedWorkoutDay(
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      warmup: warmup,
      focus: focus,
    );
  }

  int get totalSets =>
      exercises.fold(0, (sum, e) => sum + e.sets);

  factory GeneratedWorkoutDay.fromMap(Map<String, dynamic> m) =>
      GeneratedWorkoutDay(
        name: (m['name'] ?? 'Treino') as String,
        focus: m['focus'] as String?,
        warmup: (m['warmup'] as List?)?.map((e) => e.toString()).toList() ?? [],
        exercises: (m['exercises'] as List? ?? [])
            .map((e) => GeneratedExercise.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'focus': focus,
        'warmup': warmup,
        'exercises': exercises.map((e) => e.toMap()).toList(),
      };
}

/// Treino completo gerado pela IA.
class GeneratedWorkout {
  const GeneratedWorkout({
    required this.name,
    required this.goal,
    required this.split,
    required this.days,
    this.notes,
  });

  final String name;
  final WorkoutGoal goal;
  final WorkoutSplit split;
  final List<GeneratedWorkoutDay> days;
  final String? notes;

  int get totalExercises =>
      days.fold(0, (sum, d) => sum + d.exercises.length);
  int get totalSets => days.fold(0, (sum, d) => sum + d.totalSets);

  Set<String> get muscleGroups => {
        for (final d in days)
          for (final e in d.exercises) e.muscleGroup,
      }..removeWhere((e) => e.isEmpty);

  GeneratedWorkout copyWith({
    String? name,
    List<GeneratedWorkoutDay>? days,
  }) {
    return GeneratedWorkout(
      name: name ?? this.name,
      goal: goal,
      split: split,
      days: days ?? this.days,
      notes: notes,
    );
  }

  factory GeneratedWorkout.fromMap(Map<String, dynamic> m) => GeneratedWorkout(
        name: (m['name'] ?? 'Treino VIS') as String,
        goal: WorkoutGoal.fromName(m['goal'] as String?),
        split: WorkoutSplit.fromName(m['split'] as String?),
        notes: m['notes'] as String?,
        days: (m['days'] as List? ?? [])
            .map((e) => GeneratedWorkoutDay.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'goal': goal.name,
        'split': split.name,
        'notes': notes,
        'days': days.map((d) => d.toMap()).toList(),
      };
}
