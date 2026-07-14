import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/ai_workout/controllers/ai_workout_controller.dart';
import 'package:vis/features/ai_workout/domain/ai_workout_enums.dart';
import 'package:vis/features/ai_workout/models/generated_workout.dart';
import 'package:vis/features/ai_workout/models/generation_result.dart';
import 'package:vis/features/ai_workout/models/workout_request.dart';
import 'package:vis/features/ai_workout/providers/ai_workout_providers.dart';
import 'package:vis/features/ai_workout/repositories/ai_workout_repository.dart';

class FakeAIWorkoutRepository implements AIWorkoutRepository {
  @override
  Future<WorkoutGenerationResult> generate(WorkoutRequest request) async {
    return WorkoutGenerationResult(
      workout: GeneratedWorkout(
        name: 'Treino Teste',
        goal: request.goal,
        split: WorkoutSplit.abc,
        days: const [
          GeneratedWorkoutDay(
            name: 'Treino A',
            exercises: [
              GeneratedExercise(
                name: 'Supino Reto',
                muscleGroup: 'Peitoral',
                sets: 4,
                targetReps: '8-12',
              ),
            ],
          ),
        ],
      ),
      estimatedMinutes: 55,
    );
  }

  @override
  Future<GeneratedExercise> regenerateExercise({
    required WorkoutRequest request,
    required String dayName,
    required String exerciseName,
  }) async =>
      const GeneratedExercise(
          name: 'Alt', muscleGroup: 'Peitoral', sets: 3, targetReps: '10');

  @override
  Future<GeneratedWorkoutDay> regenerateDay({
    required WorkoutRequest request,
    required String dayName,
  }) async =>
      const GeneratedWorkoutDay(name: 'Treino A', exercises: []);

  @override
  Future<void> saveGeneration({
    required WorkoutRequest request,
    required GeneratedWorkout workout,
  }) async {}

  @override
  Future<void> saveFeedback(GenerationFeedback feedback) async {}

  @override
  List<GeneratedWorkout> cachedGenerations() => const [];
}

ProviderContainer _container() => ProviderContainer(
      overrides: [
        aiWorkoutRepositoryProvider
            .overrideWithValue(FakeAIWorkoutRepository()),
      ],
    );

void main() {
  test('gerar → fase result com treino', () async {
    final container = _container();
    addTearDown(container.dispose);

    final c = container.read(aiWorkoutControllerProvider.notifier);
    c.setGoal(WorkoutGoal.strength);
    await c.generate();

    final state = container.read(aiWorkoutControllerProvider);
    expect(state.phase, GenerationPhase.result);
    expect(state.workout?.name, 'Treino Teste');
    expect(state.workout?.goal, WorkoutGoal.strength);
  });

  test('remover exercício edita o treino', () async {
    final container = _container();
    addTearDown(container.dispose);

    final c = container.read(aiWorkoutControllerProvider.notifier);
    await c.generate();
    expect(container.read(aiWorkoutControllerProvider).workout?.totalExercises,
        1);

    c.removeExercise(0, 0);
    expect(container.read(aiWorkoutControllerProvider).workout?.totalExercises,
        0);
  });

  test('renomear treino atualiza o nome', () async {
    final container = _container();
    addTearDown(container.dispose);

    final c = container.read(aiWorkoutControllerProvider.notifier);
    await c.generate();
    c.renameWorkout('Meu Treino');
    expect(container.read(aiWorkoutControllerProvider).workout?.name,
        'Meu Treino');
  });
}
