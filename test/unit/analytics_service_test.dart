import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/analytics/data/analytics_service.dart';
import 'package:vis/features/analytics/domain/analytics_enums.dart';
import 'package:vis/features/body_progress/data/body_progress_repository_impl.dart';
import 'package:vis/features/body_progress/domain/body_progress_local_store.dart';
import 'package:vis/features/body_progress/models/weight_record.dart';
import 'package:vis/features/cardio/data/cardio_repository_impl.dart';
import 'package:vis/features/cardio/domain/cardio_enums.dart';
import 'package:vis/features/cardio/domain/cardio_local_store.dart';
import 'package:vis/features/cardio/models/cardio_session.dart';
import 'package:vis/features/workout/models/exercise_ref.dart';
import 'package:vis/features/workout_session/models/workout_exercise_session.dart';
import 'package:vis/features/workout_session/models/workout_session.dart';
import 'package:vis/features/workout_session/models/workout_set_session.dart';
import 'package:vis/features/workout_session/models/workout_summary.dart';
import 'package:vis/features/workout_session/repositories/workout_session_repository.dart';

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

WorkoutSession _session({
  required String id,
  required DateTime date,
  required String exerciseId,
  required String exerciseName,
  required String muscle,
  required double weight,
  required int reps,
  int elapsedSeconds = 3600,
}) =>
    WorkoutSession(
      id: id,
      userId: 'u1',
      planId: 'p1',
      planName: 'ABC',
      dayName: 'Treino A',
      startedAt: date,
      finishedAt: date,
      elapsedSeconds: elapsedSeconds,
      exercises: [
        WorkoutExerciseSession(
          id: 'es_$id',
          exercise: ExerciseRef(
              id: exerciseId, name: exerciseName, muscleGroup: muscle),
          sets: [
            WorkoutSetSession(
              id: 'st_$id',
              setNumber: 1,
              weight: weight,
              reps: reps,
              completed: true,
            ),
          ],
        ),
      ],
    );

void main() {
  final now = DateTime(2026, 7, 13, 12);

  test('agrega treinos, volume, séries e distribuição muscular', () {
    final sessions = [
      _session(
          id: 's1',
          date: DateTime(2026, 7, 13),
          exerciseId: 'sup',
          exerciseName: 'Supino',
          muscle: 'Peitoral',
          weight: 100,
          reps: 10),
      _session(
          id: 's2',
          date: DateTime(2026, 7, 11),
          exerciseId: 'agac',
          exerciseName: 'Agachamento',
          muscle: 'Pernas',
          weight: 120,
          reps: 8),
    ];

    final service = AnalyticsService(
      sessionRepository: _FakeSession(sessions),
      now: () => now,
    );

    final r = service.buildReport(AnalyticsPeriod.month);

    expect(r.workouts, 2);
    expect(r.activeDays, 2);
    expect(r.totalSets, 2);
    expect(r.totalVolume, 100 * 10 + 120 * 8); // 1960
    expect(r.totalMinutes, 120); // 60 + 60
    expect(r.isEmpty, isFalse);

    // Distribuição ordenada por volume desc: Peitoral (1000) antes de Pernas (960).
    expect(r.muscleDistribution.first.muscle, 'Peitoral');
    expect(
        r.muscleDistribution.map((m) => m.muscle), containsAll(['Peitoral', 'Pernas']));

    // Recordes ordenados por 1RM estimado desc: Agachamento (~152) antes de Supino (~133).
    expect(r.personalRecords.first.exerciseName, 'Agachamento');
    expect(r.personalRecords.first.maxWeight, 120);
    expect(r.personalRecords.first.repsAtMaxWeight, 8);
  });

  test('respeita a janela do período (exclui fora do intervalo)', () {
    final sessions = [
      _session(
          id: 'recent',
          date: DateTime(2026, 7, 13),
          exerciseId: 'sup',
          exerciseName: 'Supino',
          muscle: 'Peitoral',
          weight: 80,
          reps: 10),
      _session(
          id: 'old',
          date: DateTime(2026, 6, 1), // > 30 dias atrás
          exerciseId: 'sup',
          exerciseName: 'Supino',
          muscle: 'Peitoral',
          weight: 90,
          reps: 10),
    ];

    final service = AnalyticsService(
      sessionRepository: _FakeSession(sessions),
      now: () => now,
    );

    expect(service.buildReport(AnalyticsPeriod.week).workouts, 1);
    expect(service.buildReport(AnalyticsPeriod.month).workouts, 1);
    expect(service.buildReport(AnalyticsPeriod.all).workouts, 2);
  });

  test('inclui cardio e variação de peso quando os repositórios existem',
      () async {
    final cardio =
        CardioRepositoryImpl(store: _CStore(), currentUserId: () => 'u1');
    await cardio.addSession(CardioSession(
      id: 'c1',
      userId: 'u1',
      type: CardioType.running,
      performedAt: DateTime(2026, 7, 12),
      durationSeconds: 1800,
      distanceKm: 5,
    ));

    final body =
        BodyProgressRepositoryImpl(store: _BStore(), currentUserId: () => 'u1');
    await body.addWeight(WeightRecord(
        id: 'w1', userId: 'u1', weight: 82, recordedAt: DateTime(2026, 7, 1)));
    await body.addWeight(WeightRecord(
        id: 'w2', userId: 'u1', weight: 80, recordedAt: DateTime(2026, 7, 12)));

    final service = AnalyticsService(
      sessionRepository: _FakeSession(const []),
      cardioRepository: cardio,
      bodyRepository: body,
      now: () => now,
    );

    final r = service.buildReport(AnalyticsPeriod.month);

    expect(r.cardio.sessions, 1);
    expect(r.cardio.minutes, 30);
    expect(r.cardio.distanceKm, 5);
    expect(r.weight.hasData, isTrue);
    expect(r.weight.start, 82);
    expect(r.weight.end, 80);
    expect(r.weight.delta, -2);
    // Só cardio/peso, sem treinos → não é vazio.
    expect(r.isEmpty, isFalse);
  });

  test('sem dados retorna relatório vazio', () {
    final service = AnalyticsService(
      sessionRepository: _FakeSession(const []),
      now: () => now,
    );
    final r = service.buildReport(AnalyticsPeriod.month);
    expect(r.isEmpty, isTrue);
    expect(r.workouts, 0);
    expect(r.personalRecords, isEmpty);
  });
}
