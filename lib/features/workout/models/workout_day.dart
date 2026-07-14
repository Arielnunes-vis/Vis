import '../domain/workout_enums.dart';
import 'workout_exercise.dart';

/// Um dia/divisão do treino (ex.: "Treino A") — PROMPT 04.
class WorkoutDay {
  const WorkoutDay({
    required this.id,
    required this.name,
    required this.orderIndex,
    this.exercises = const [],
    this.weekdays = const [],
    this.estimatedDuration,
    this.focus,
  });

  final String id;
  final String name;
  final int orderIndex;
  final List<WorkoutExercise> exercises;
  final List<Weekday> weekdays;

  /// Duração estimada em minutos.
  final int? estimatedDuration;
  final String? focus;

  int get totalExercises => exercises.length;
  int get totalSets => exercises.fold(0, (sum, e) => sum + e.totalSets);

  Set<String> get muscleGroups => {
        for (final e in exercises) e.exercise.muscleGroup,
      }..removeWhere((e) => e.isEmpty);

  WorkoutDay copyWith({
    String? name,
    int? orderIndex,
    List<WorkoutExercise>? exercises,
    List<Weekday>? weekdays,
    int? estimatedDuration,
    String? focus,
  }) {
    return WorkoutDay(
      id: id,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      exercises: exercises ?? this.exercises,
      weekdays: weekdays ?? this.weekdays,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      focus: focus ?? this.focus,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'order_index': orderIndex,
        'weekdays': weekdays.map((w) => w.number).toList(),
        'estimated_duration': estimatedDuration,
        'focus': focus,
        'exercises': exercises.map((e) => e.toMap()).toList(),
      };

  factory WorkoutDay.fromMap(Map<String, dynamic> m) => WorkoutDay(
        id: m['id'] as String,
        name: (m['name'] ?? 'Treino') as String,
        orderIndex: (m['order_index'] as num?)?.toInt() ?? 0,
        weekdays: (m['weekdays'] as List? ?? [])
            .map((e) => Weekday.fromNumber((e as num).toInt()))
            .toList(),
        estimatedDuration: (m['estimated_duration'] as num?)?.toInt(),
        focus: m['focus'] as String?,
        exercises: (m['exercises'] as List? ?? [])
            .map((e) =>
                WorkoutExercise.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
