import '../domain/ai_workout_enums.dart';

/// Preferências informadas para a geração (PROMPT 12).
class WorkoutPreferences {
  const WorkoutPreferences({
    this.favoriteExercises = const [],
    this.dislikedExercises = const [],
  });

  final List<String> favoriteExercises;
  final List<String> dislikedExercises;

  Map<String, dynamic> toMap() => {
        'favorite_exercises': favoriteExercises,
        'disliked_exercises': dislikedExercises,
      };
}

/// Restrições físicas/lesões informadas para a geração.
class WorkoutRestrictions {
  const WorkoutRestrictions({
    this.injuries = const [],
    this.forbiddenMovements = const [],
    this.notes = '',
  });

  final List<String> injuries;
  final List<String> forbiddenMovements;
  final String notes;

  Map<String, dynamic> toMap() => {
        'injuries': injuries,
        'forbidden_movements': forbiddenMovements,
        'notes': notes,
      };
}

/// Resumo do histórico do usuário anexado ao pedido, para a IA levar
/// em conta últimos treinos, PRs, frequência e grupos treinados.
class WorkoutHistorySummary {
  const WorkoutHistorySummary({
    this.recentWorkouts = const [],
    this.personalRecords = const [],
    this.weeklyFrequency,
    this.recentMuscleGroups = const [],
  });

  final List<String> recentWorkouts;
  final List<String> personalRecords;
  final int? weeklyFrequency;
  final List<String> recentMuscleGroups;

  Map<String, dynamic> toMap() => {
        'recent_workouts': recentWorkouts,
        'personal_records': personalRecords,
        'weekly_frequency': weeklyFrequency,
        'recent_muscle_groups': recentMuscleGroups,
      };
}

/// Pedido completo enviado ao gerador (PROMPT 12).
class WorkoutRequest {
  const WorkoutRequest({
    required this.goal,
    required this.daysPerWeek,
    required this.minutesPerWorkout,
    required this.location,
    required this.experience,
    this.equipment = const [],
    this.preferences = const WorkoutPreferences(),
    this.restrictions = const WorkoutRestrictions(),
    this.history = const WorkoutHistorySummary(),
  });

  final WorkoutGoal goal;
  final int daysPerWeek;
  final int minutesPerWorkout;
  final WorkoutLocation location;
  final WorkoutExperience experience;
  final List<String> equipment;
  final WorkoutPreferences preferences;
  final WorkoutRestrictions restrictions;
  final WorkoutHistorySummary history;

  WorkoutRequest copyWith({
    WorkoutGoal? goal,
    int? daysPerWeek,
    int? minutesPerWorkout,
    WorkoutLocation? location,
    WorkoutExperience? experience,
    List<String>? equipment,
    WorkoutPreferences? preferences,
    WorkoutRestrictions? restrictions,
    WorkoutHistorySummary? history,
  }) {
    return WorkoutRequest(
      goal: goal ?? this.goal,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      minutesPerWorkout: minutesPerWorkout ?? this.minutesPerWorkout,
      location: location ?? this.location,
      experience: experience ?? this.experience,
      equipment: equipment ?? this.equipment,
      preferences: preferences ?? this.preferences,
      restrictions: restrictions ?? this.restrictions,
      history: history ?? this.history,
    );
  }

  /// Corpo minimizado enviado à Edge Function (envia só o necessário).
  Map<String, dynamic> toMap() => {
        'goal': goal.name,
        'days_per_week': daysPerWeek,
        'minutes_per_workout': minutesPerWorkout,
        'location': location.name,
        'experience': experience.name,
        'equipment': equipment,
        'preferences': preferences.toMap(),
        'restrictions': restrictions.toMap(),
        'history': history.toMap(),
      };
}
