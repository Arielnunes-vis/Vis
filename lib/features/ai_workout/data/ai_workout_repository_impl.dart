import '../../../core/constants/app_constants.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/network/connection_checker.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/supabase/services/database_service.dart';
import '../../ai/domain/ai_context.dart';
import '../models/generated_workout.dart';
import '../models/generation_result.dart';
import '../models/workout_request.dart';
import '../repositories/ai_workout_repository.dart';
import '../services/ai_workout_service.dart';

/// Implementação do [AIWorkoutRepository].
///
/// Orquestra: contexto do usuário (IA) → serviço (Edge Function) →
/// cache local (offline) → persistência de histórico/feedback.
final class AIWorkoutRepositoryImpl implements AIWorkoutRepository {
  AIWorkoutRepositoryImpl({
    required IAIWorkoutService service,
    required IDatabaseService database,
    required LocalStorageService storage,
    required ConnectionChecker connection,
    required Future<AIContext> Function() buildContext,
    required String? Function() currentUserId,
  })  : _service = service,
        _database = database,
        _storage = storage,
        _connection = connection,
        _buildContext = buildContext,
        _currentUserId = currentUserId;

  final IAIWorkoutService _service;
  final IDatabaseService _database;
  final LocalStorageService _storage;
  final ConnectionChecker _connection;
  final Future<AIContext> Function() _buildContext;
  final String? Function() _currentUserId;

  static const String _cacheKey = 'ai_generated_workouts';

  @override
  Future<WorkoutGenerationResult> generate(WorkoutRequest request) async {
    await _connection.requireConnection(); // geração é online
    final context = await _buildContext();
    final result = await _service.generate(request: request, context: context);
    _cache(result.workout);
    return result;
  }

  @override
  Future<GeneratedExercise> regenerateExercise({
    required WorkoutRequest request,
    required String dayName,
    required String exerciseName,
  }) async {
    await _connection.requireConnection();
    final context = await _buildContext();
    return _service.regenerateExercise(
      request: request,
      context: context,
      dayName: dayName,
      exerciseName: exerciseName,
    );
  }

  @override
  Future<GeneratedWorkoutDay> regenerateDay({
    required WorkoutRequest request,
    required String dayName,
  }) async {
    await _connection.requireConnection();
    final context = await _buildContext();
    return _service.regenerateDay(
      request: request,
      context: context,
      dayName: dayName,
    );
  }

  @override
  Future<void> saveGeneration({
    required WorkoutRequest request,
    required GeneratedWorkout workout,
  }) async {
    final userId = _currentUserId();
    _cache(workout);
    if (userId == null) return;
    try {
      await _database.insert('ai_workout_generations', {
        'user_id': userId,
        'goal': request.goal.name,
        'request': request.toMap(),
        'workout': workout.toMap(),
      });
    } catch (e) {
      // Não bloquear o usuário: fica em cache local para sync futuro.
      AppLogger.w('[AIWorkout] saveGeneration adiado (offline?): $e');
    }
  }

  @override
  Future<void> saveFeedback(GenerationFeedback feedback) async {
    final userId = _currentUserId();
    if (userId == null) return;
    try {
      await _database.insert('ai_workout_feedback', {
        'user_id': userId,
        ...feedback.toMap(),
      });
    } catch (e) {
      AppLogger.w('[AIWorkout] saveFeedback adiado: $e');
    }
  }

  @override
  List<GeneratedWorkout> cachedGenerations() {
    final raw = _storage.get<List<dynamic>>(AppConstants.boxCache, _cacheKey);
    if (raw == null) return [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => GeneratedWorkout.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  void _cache(GeneratedWorkout workout) {
    final current = cachedGenerations();
    final updated = [workout, ...current].take(20).toList();
    // ignore: discarded_futures
    _storage.put(
      AppConstants.boxCache,
      _cacheKey,
      updated.map((w) => w.toMap()).toList(),
    );
  }
}
