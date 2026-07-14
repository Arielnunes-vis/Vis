import '../models/generated_workout.dart';
import '../models/generation_result.dart';
import '../models/workout_request.dart';

/// Contrato do repositório do gerador de treinos (PROMPT 12).
abstract interface class AIWorkoutRepository {
  /// Gera um treino a partir do pedido + contexto do usuário.
  /// Exige conexão (a geração é online).
  Future<WorkoutGenerationResult> generate(WorkoutRequest request);

  Future<GeneratedExercise> regenerateExercise({
    required WorkoutRequest request,
    required String dayName,
    required String exerciseName,
  });

  Future<GeneratedWorkoutDay> regenerateDay({
    required WorkoutRequest request,
    required String dayName,
  });

  /// Persiste o treino gerado (e editado) no histórico.
  Future<void> saveGeneration({
    required WorkoutRequest request,
    required GeneratedWorkout workout,
  });

  /// Salva a avaliação do usuário sobre o treino gerado.
  Future<void> saveFeedback(GenerationFeedback feedback);

  /// Treinos gerados anteriormente (disponível offline via cache).
  List<GeneratedWorkout> cachedGenerations();
}
