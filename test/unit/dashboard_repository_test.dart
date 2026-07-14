import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:vis/features/workout/models/exercise_ref.dart';
import 'package:vis/features/workout/models/workout_day.dart';
import 'package:vis/features/workout/models/workout_exercise.dart';
import 'package:vis/features/workout/models/workout_plan.dart';
import 'package:vis/features/workout/models/workout_set.dart';
import 'package:vis/features/workout/repositories/workout_repository.dart';
import 'package:vis/features/workout_session/models/workout_exercise_session.dart';
import 'package:vis/features/workout_session/models/workout_session.dart';
import 'package:vis/features/workout_session/models/workout_set_session.dart';
import 'package:vis/features/workout_session/models/workout_summary.dart';
import 'package:vis/features/workout_session/repositories/workout_session_repository.dart';

class FakeWorkoutRepo implements WorkoutRepository {
  @override
  Future<List<WorkoutPlan>> getPlans() async => const [
        WorkoutPlan(
          id: 'p1',
          userId: 'u1',
          name: 'ABC',
          isActive: true,
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
        ),
      ];

  @override
  Future<WorkoutPlan?> getPlan(String id) => throw UnimplementedError();
  @override
  Future<WorkoutPlan> savePlan(WorkoutPlan plan) => throw UnimplementedError();
  @override
  Future<WorkoutPlan> duplicatePlan(String id) => throw UnimplementedError();
  @override
  Future<void> deletePlan(String id) => throw UnimplementedError();
  @override
  Future<void> setActive(String id) => throw UnimplementedError();
}

class FakeSessionRepo implements WorkoutSessionRepository {
  FakeSessionRepo(this._sessions);
  final List<WorkoutSession> _sessions;

  @override
  List<WorkoutSession> recentSessions({int limit = 20}) => _sessions;
  @override
  WorkoutSession? loadActive() => null;
  @override
  Future<void> saveActive(WorkoutSession session) async {}
  @override
  Future<void> clearActive() async {}
  @override
  Future<WorkoutSummary> finish(WorkoutSession session) =>
      throw UnimplementedError();
}

WorkoutSession _session(DateTime date) => WorkoutSession(
      id: 's_${date.day}',
      userId: 'u1',
      planId: 'p1',
      planName: 'ABC',
      dayName: 'Treino A',
      startedAt: date,
      finishedAt: date,
      elapsedSeconds: 1800,
      exercises: [
        WorkoutExerciseSession(
          id: 'es1',
          exercise: const ExerciseRef(
              id: 'bp', name: 'Supino', muscleGroup: 'Peitoral'),
          sets: const [
            WorkoutSetSession(
                id: 'st1', setNumber: 1, weight: 60, reps: 10, completed: true),
          ],
        ),
      ],
    );

void main() {
  DashboardRepositoryImpl repo(List<WorkoutSession> sessions, DateTime now) =>
      DashboardRepositoryImpl(
        workoutRepository: FakeWorkoutRepo(),
        sessionRepository: FakeSessionRepo(sessions),
        now: () => now,
      );

  test('sequência conta dias consecutivos terminando hoje', () async {
    final now = DateTime(2026, 1, 15, 20);
    final data = await repo([
      _session(DateTime(2026, 1, 15)),
      _session(DateTime(2026, 1, 14)),
    ], now).load();

    expect(data.sequence.current, 2);
    expect(data.sequence.longest, greaterThanOrEqualTo(2));
  });

  test('resumo semanal soma treinos da semana atual', () async {
    final now = DateTime(2026, 1, 15, 20); // quinta
    final data = await repo([
      _session(DateTime(2026, 1, 15)),
      _session(DateTime(2026, 1, 14)),
    ], now).load();

    expect(data.weekly.workouts, 2);
    expect(data.weekly.totalVolume, 1200); // 2 x (60*10)
    expect(data.muscleVolume.first.muscle, 'Peitoral');
    expect(data.upcoming, isNotNull);
    expect(data.insight, isNotNull);
  });

  test('sem sessões → sequência zero e insight de incentivo', () async {
    final data = await repo(const [], DateTime(2026, 1, 15)).load();
    expect(data.sequence.current, 0);
    expect(data.weekly.workouts, 0);
    expect(data.insight, isNotNull);
  });
}
