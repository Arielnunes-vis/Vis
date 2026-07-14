import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/ai/data/ai_context_builder.dart';
import 'package:vis/features/body_progress/data/body_progress_repository_impl.dart';
import 'package:vis/features/body_progress/domain/body_progress_local_store.dart';
import 'package:vis/features/body_progress/models/weight_record.dart';
import 'package:vis/features/cardio/data/cardio_repository_impl.dart';
import 'package:vis/features/cardio/domain/cardio_enums.dart';
import 'package:vis/features/cardio/domain/cardio_local_store.dart';
import 'package:vis/features/cardio/models/cardio_session.dart';
import 'package:vis/features/nutrition/data/nutrition_repository_impl.dart';
import 'package:vis/features/nutrition/domain/nutrition_enums.dart';
import 'package:vis/features/nutrition/domain/nutrition_local_store.dart';
import 'package:vis/features/nutrition/models/food_item.dart';
import 'package:vis/features/nutrition/models/macro_nutrients.dart';
import 'package:vis/features/nutrition/models/meal.dart';
import 'package:vis/features/workout/data/workout_repository_impl.dart';
import 'package:vis/features/workout/domain/workout_local_store.dart';
import 'package:vis/features/workout/models/exercise_ref.dart';
import 'package:vis/features/workout_session/models/workout_exercise_session.dart';
import 'package:vis/features/workout_session/models/workout_session.dart';
import 'package:vis/features/workout_session/models/workout_set_session.dart';
import 'package:vis/features/workout_session/models/workout_summary.dart';
import 'package:vis/features/workout_session/repositories/workout_session_repository.dart';

// ---- Stores em memória ----
class _WStore implements WorkoutLocalStore {
  final Map<String, List<Map<String, dynamic>>> d = {};
  @override
  List<Map<String, dynamic>> readPlans(String u) => d[u] ?? const [];
  @override
  Future<void> writePlans(String u, List<Map<String, dynamic>> p) async =>
      d[u] = p;
}

class _BStore implements BodyProgressLocalStore {
  final Map<String, List<Map<String, dynamic>>> d = {};
  @override
  List<Map<String, dynamic>> read(String u, String c) => d['$u/$c'] ?? const [];
  @override
  Future<void> write(String u, String c, List<Map<String, dynamic>> i) async =>
      d['$u/$c'] = i;
}

class _CStore implements CardioLocalStore {
  final Map<String, List<Map<String, dynamic>>> d = {};
  @override
  List<Map<String, dynamic>> read(String u, String c) => d['$u/$c'] ?? const [];
  @override
  Future<void> write(String u, String c, List<Map<String, dynamic>> i) async =>
      d['$u/$c'] = i;
}

class _NStore implements NutritionLocalStore {
  final Map<String, List<Map<String, dynamic>>> l = {};
  final Map<String, Map<String, dynamic>> m = {};
  @override
  List<Map<String, dynamic>> readList(String u, String c) =>
      l['$u/$c'] ?? const [];
  @override
  Future<void> writeList(String u, String c, List<Map<String, dynamic>> i) async =>
      l['$u/$c'] = i;
  @override
  Map<String, dynamic>? readMap(String u, String k) => m['$u/$k'];
  @override
  Future<void> writeMap(String u, String k, Map<String, dynamic> v) async =>
      m['$u/$k'] = v;
}

class _FakeSession implements WorkoutSessionRepository {
  _FakeSession(this._list);
  final List<WorkoutSession> _list;
  @override
  List<WorkoutSession> recentSessions({int limit = 20}) => _list;
  @override
  WorkoutSession? loadActive() => null;
  @override
  Future<void> saveActive(WorkoutSession s) async {}
  @override
  Future<void> clearActive() async {}
  @override
  Future<WorkoutSummary> finish(WorkoutSession s) => throw UnimplementedError();
}

void main() {
  test('constrói contexto com dados reais de vários módulos', () async {
    final now = DateTime.now();

    final workoutRepo =
        WorkoutRepositoryImpl(store: _WStore(), currentUserId: () => 'u1');

    final bodyRepo =
        BodyProgressRepositoryImpl(store: _BStore(), currentUserId: () => 'u1');
    await bodyRepo.addWeight(
        WeightRecord(id: 'w1', userId: 'u1', weight: 80, recordedAt: now));

    final cardioRepo =
        CardioRepositoryImpl(store: _CStore(), currentUserId: () => 'u1');
    await cardioRepo.addSession(CardioSession(
      id: 'c1',
      userId: 'u1',
      type: CardioType.running,
      performedAt: now,
      durationSeconds: 1800,
      distanceKm: 5,
    ));

    final nutritionRepo =
        NutritionRepositoryImpl(store: _NStore(), currentUserId: () => 'u1');
    await nutritionRepo.addMeal(Meal(
      id: 'm1',
      userId: 'u1',
      type: MealType.lunch,
      consumedAt: now,
      items: [
        FoodItem(
          id: 'f1',
          name: 'Frango',
          quantity: 150,
          unit: MeasureUnit.grams,
          macros: const MacroNutrients(calories: 250, protein: 40),
        ),
      ],
    ));

    final session = WorkoutSession(
      id: 's1',
      userId: 'u1',
      planId: 'p1',
      planName: 'ABC',
      dayName: 'Treino A',
      startedAt: now,
      finishedAt: now,
      exercises: [
        WorkoutExerciseSession(
          id: 'es1',
          exercise: const ExerciseRef(
              id: 'bp', name: 'Supino', muscleGroup: 'Peitoral'),
          sets: const [
            WorkoutSetSession(
                id: 'st', setNumber: 1, weight: 60, reps: 10, completed: true),
          ],
        ),
      ],
    );

    final builder = AIContextBuilder(
      workoutRepository: workoutRepo,
      sessionRepository: _FakeSession([session]),
      bodyRepository: bodyRepo,
      cardioRepository: cardioRepo,
      nutritionRepository: nutritionRepo,
      now: () => now,
    );

    final ctx = await builder.build();

    expect(ctx.workouts.length, 1);
    expect(ctx.workouts.first['day'], 'Treino A');
    expect(ctx.weightHistory.length, 1);
    expect(ctx.weightHistory.first['weight'], 80);
    expect(ctx.cardio.length, 1);
    expect(ctx.preferences['today_protein'], 40);
    expect(ctx.preferences['weekly_cardio_minutes'], 30);
    expect(ctx.isEmpty, isFalse);
  });
}
