import '../domain/ai_workout_enums.dart';
import 'generated_workout.dart';

/// Recomendação textual que acompanha o treino (explica escolhas).
class WorkoutRecommendation {
  const WorkoutRecommendation({required this.message, this.reason});
  final String message;
  final String? reason;

  factory WorkoutRecommendation.fromMap(Map<String, dynamic> m) =>
      WorkoutRecommendation(
        message: (m['message'] ?? '') as String,
        reason: m['reason'] as String?,
      );
}

/// Resultado da geração: o treino + recomendações + metadados.
class WorkoutGenerationResult {
  const WorkoutGenerationResult({
    required this.workout,
    this.recommendations = const [],
    this.estimatedMinutes,
    this.isEstimate = true,
  });

  final GeneratedWorkout workout;
  final List<WorkoutRecommendation> recommendations;
  final int? estimatedMinutes;
  final bool isEstimate;

  factory WorkoutGenerationResult.fromMap(Map<String, dynamic> m) {
    final workoutMap = m['workout'] is Map
        ? Map<String, dynamic>.from(m['workout'] as Map)
        : m;
    return WorkoutGenerationResult(
      workout: GeneratedWorkout.fromMap(workoutMap),
      estimatedMinutes: (m['estimated_minutes'] as num?)?.toInt(),
      recommendations: (m['recommendations'] as List? ?? [])
          .map((e) =>
              WorkoutRecommendation.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

/// Feedback do usuário sobre o treino gerado (PROMPT 12).
class GenerationFeedback {
  const GenerationFeedback({
    required this.workoutName,
    required this.rating,
    this.comment = '',
    this.createdAt,
  });

  final String workoutName;
  final GenerationRating rating;
  final String comment;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'workout_name': workoutName,
        'rating': rating.name,
        'comment': comment,
        'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      };
}
