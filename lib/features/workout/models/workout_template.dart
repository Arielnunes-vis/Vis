import '../domain/workout_enums.dart';
import 'workout_day.dart';

/// Modelo de treino pré-pronto (blueprint) usado para criar um plano
/// rapidamente (PROMPT 04). O gerador de IA (módulo 12) também produz
/// estruturas convertíveis em [WorkoutTemplate].
class WorkoutTemplate {
  const WorkoutTemplate({
    required this.id,
    required this.name,
    required this.goal,
    this.description = '',
    this.days = const [],
  });

  final String id;
  final String name;
  final WorkoutGoalType goal;
  final String description;
  final List<WorkoutDay> days;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'goal': goal.name,
        'description': description,
        'days': days.map((d) => d.toMap()).toList(),
      };

  factory WorkoutTemplate.fromMap(Map<String, dynamic> m) => WorkoutTemplate(
        id: m['id'] as String,
        name: (m['name'] ?? '') as String,
        goal: WorkoutGoalType.fromName(m['goal'] as String?),
        description: (m['description'] ?? '') as String,
        days: (m['days'] as List? ?? [])
            .map((e) => WorkoutDay.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
