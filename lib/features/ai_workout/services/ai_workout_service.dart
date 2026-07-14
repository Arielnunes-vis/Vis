import '../../../core/supabase/services/edge_functions_service.dart';
import '../../ai/domain/ai_context.dart';
import '../models/generated_workout.dart';
import '../models/generation_result.dart';
import '../models/workout_request.dart';

/// Serviço do gerador de treinos (PROMPT 12).
///
/// Reutiliza a infraestrutura de IA (Supabase Edge Functions) criada
/// anteriormente — NÃO contém lógica de um modelo de IA específico.
/// Apenas monta o payload, invoca a função e converte o retorno em
/// modelos tipados.
abstract interface class IAIWorkoutService {
  Future<WorkoutGenerationResult> generate({
    required WorkoutRequest request,
    required AIContext context,
  });

  /// Regenera apenas um exercício de um dia específico.
  Future<GeneratedExercise> regenerateExercise({
    required WorkoutRequest request,
    required AIContext context,
    required String dayName,
    required String exerciseName,
  });

  /// Regenera um dia inteiro.
  Future<GeneratedWorkoutDay> regenerateDay({
    required WorkoutRequest request,
    required AIContext context,
    required String dayName,
  });
}

final class EdgeFunctionAIWorkoutService implements IAIWorkoutService {
  const EdgeFunctionAIWorkoutService(this._functions);

  final IEdgeFunctionsService _functions;

  static const String _fnGenerate = 'ai-create-workout';
  static const String _fnRegenExercise = 'ai-regenerate-exercise';
  static const String _fnRegenDay = 'ai-regenerate-day';

  @override
  Future<WorkoutGenerationResult> generate({
    required WorkoutRequest request,
    required AIContext context,
  }) async {
    final data = await _functions.invoke(
      _fnGenerate,
      body: {'request': request.toMap(), 'context': context.toJson()},
    );
    return WorkoutGenerationResult.fromMap(data);
  }

  @override
  Future<GeneratedExercise> regenerateExercise({
    required WorkoutRequest request,
    required AIContext context,
    required String dayName,
    required String exerciseName,
  }) async {
    final data = await _functions.invoke(
      _fnRegenExercise,
      body: {
        'request': request.toMap(),
        'context': context.toJson(),
        'day': dayName,
        'exercise': exerciseName,
      },
    );
    final map = data['exercise'] is Map
        ? Map<String, dynamic>.from(data['exercise'] as Map)
        : data;
    return GeneratedExercise.fromMap(map);
  }

  @override
  Future<GeneratedWorkoutDay> regenerateDay({
    required WorkoutRequest request,
    required AIContext context,
    required String dayName,
  }) async {
    final data = await _functions.invoke(
      _fnRegenDay,
      body: {
        'request': request.toMap(),
        'context': context.toJson(),
        'day': dayName,
      },
    );
    final map = data['day'] is Map
        ? Map<String, dynamic>.from(data['day'] as Map)
        : data;
    return GeneratedWorkoutDay.fromMap(map);
  }
}
