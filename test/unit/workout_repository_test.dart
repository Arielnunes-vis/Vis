import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/workout/data/workout_repository_impl.dart';
import 'package:vis/features/workout/domain/workout_local_store.dart';
import 'package:vis/features/workout/models/exercise_ref.dart';
import 'package:vis/features/workout/models/workout_day.dart';
import 'package:vis/features/workout/models/workout_exercise.dart';
import 'package:vis/features/workout/models/workout_plan.dart';
import 'package:vis/features/workout/models/workout_set.dart';

class InMemoryStore implements WorkoutLocalStore {
  final Map<String, List<Map<String, dynamic>>> _data = {};

  @override
  List<Map<String, dynamic>> readPlans(String userId) =>
      _data[userId] ?? const [];

  @override
  Future<void> writePlans(
    String userId,
    List<Map<String, dynamic>> plans,
  ) async =>
      _data[userId] = plans;
}

WorkoutPlan _samplePlan() => const WorkoutPlan(
      id: 'p1',
      userId: 'u1',
      name: 'ABC',
      days: [
        WorkoutDay(
          id: 'd1',
          name: 'Treino A',
          orderIndex: 0,
          exercises: [
            WorkoutExercise(
              id: 'e1',
              exercise: ExerciseRef(
                  id: 'bp', name: 'Supino', muscleGroup: 'Peitoral'),
              orderIndex: 0,
              sets: [WorkoutSet(setNumber: 1)],
            ),
          ],
        ),
      ],
    );

void main() {
  late WorkoutRepositoryImpl repo;

  setUp(() {
    var counter = 0;
    repo = WorkoutRepositoryImpl(
      store: InMemoryStore(),
      currentUserId: () => 'u1',
      idGenerator: () => 'gen${counter++}',
    );
  });

  test('salva e lê planos', () async {
    await repo.savePlan(_samplePlan());
    final plans = await repo.getPlans();
    expect(plans.length, 1);
    expect(plans.first.name, 'ABC');
    expect(plans.first.totalExercises, 1);
  });

  test('duplica gerando novos IDs e sufixo (cópia)', () async {
    await repo.savePlan(_samplePlan());
    final copy = await repo.duplicatePlan('p1');
    expect(copy.name, 'ABC (cópia)');
    expect(copy.id, isNot('p1'));
    expect(copy.days.first.id, isNot('d1'));
    expect((await repo.getPlans()).length, 2);
  });

  test('setActive ativa um e desativa os demais', () async {
    await repo.savePlan(_samplePlan());
    final copy = await repo.duplicatePlan('p1');
    await repo.setActive(copy.id);
    final plans = await repo.getPlans();
    expect(plans.firstWhere((p) => p.id == copy.id).isActive, isTrue);
    expect(plans.firstWhere((p) => p.id == 'p1').isActive, isFalse);
  });

  test('deletePlan remove o plano', () async {
    await repo.savePlan(_samplePlan());
    await repo.deletePlan('p1');
    expect((await repo.getPlans()), isEmpty);
  });
}
