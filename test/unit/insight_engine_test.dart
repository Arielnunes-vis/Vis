import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/ai_insights/data/insight_engine.dart';
import 'package:vis/features/ai_insights/domain/insight_enums.dart';
import 'package:vis/features/body_progress/data/body_progress_repository_impl.dart';
import 'package:vis/features/body_progress/domain/body_progress_local_store.dart';
import 'package:vis/features/cardio/data/cardio_repository_impl.dart';
import 'package:vis/features/cardio/domain/cardio_local_store.dart';
import 'package:vis/features/nutrition/data/nutrition_repository_impl.dart';
import 'package:vis/features/nutrition/domain/nutrition_local_store.dart';
import 'package:vis/features/workout/models/exercise_ref.dart';
import 'package:vis/features/workout_session/models/workout_exercise_session.dart';
import 'package:vis/features/workout_session/models/workout_session.dart';
import 'package:vis/features/workout_session/models/workout_set_session.dart';
import 'package:vis/features/workout_session/models/workout_summary.dart';
import 'package:vis/features/workout_session/repositories/workout_session_repository.dart';

// ---- Stores em memória ----
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
  Future<void> writeList(
          String u, String c, List<Map<String, dynamic>> i) async =>
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

WorkoutSession _session(String id, DateTime date) => WorkoutSession(
      id: id,
      userId: 'u1',
      planId: 'p1',
      planName: 'ABC',
      dayName: 'Treino A',
      startedAt: date,
      finishedAt: date,
      exercises: [
        WorkoutExerciseSession(
          id: 'es_$id',
          exercise: const ExerciseRef(
              id: 'bp', name: 'Supino', muscleGroup: 'Peitoral'),
          sets: const [
            WorkoutSetSession(
                id: 'st', setNumber: 1, weight: 60, reps: 10, completed: true),
          ],
        ),
      ],
    );

InsightEngine _engine(List<WorkoutSession> sessions, DateTime now) =>
    InsightEngine(
      sessionRepository: _FakeSession(sessions),
      bodyRepository:
          BodyProgressRepositoryImpl(store: _BStore(), currentUserId: () => 'u1'),
      cardioRepository:
          CardioRepositoryImpl(store: _CStore(), currentUserId: () => 'u1'),
      nutritionRepository:
          NutritionRepositoryImpl(store: _NStore(), currentUserId: () => 'u1'),
      now: () => now,
    );

void main() {
  test('gera conquista de sequência quando há 3 dias seguidos', () {
    // Segunda-feira 10h — antes das 15h, para não disparar alertas de nutrição.
    final now = DateTime(2026, 7, 13, 10);
    final sessions = [
      _session('s1', DateTime(2026, 7, 13, 8)),
      _session('s2', DateTime(2026, 7, 12, 8)),
      _session('s3', DateTime(2026, 7, 11, 8)),
    ];

    final bundle = _engine(sessions, now).build();

    expect(bundle.insights, isNotEmpty);
    final top = bundle.top!;
    expect(top.category, InsightCategory.consistency);
    expect(top.type, InsightType.achievement);
    expect(top.priority, InsightPriority.high);
    expect(top.title, contains('3'));
    // Insight sempre acompanhado do motivo (Regra 008).
    expect(top.reason, isNotNull);
  });

  test('resumo semanal contabiliza treinos da semana atual', () {
    final now = DateTime(2026, 7, 13, 10);
    final sessions = [
      _session('s1', DateTime(2026, 7, 13, 8)),
      _session('s2', DateTime(2026, 7, 12, 8)),
    ];

    final bundle = _engine(sessions, now).build();

    expect(bundle.weekly.workouts, 2);
    expect(bundle.weekly.totalVolume, greaterThan(0));
    expect(bundle.weekly.isEmpty, isFalse);
  });

  test('sem dados retorna fallback positivo, nunca vazio', () {
    final now = DateTime(2026, 7, 13, 10);

    final bundle = _engine(const [], now).build();

    expect(bundle.insights, hasLength(1));
    expect(bundle.top!.type, InsightType.insight);
    expect(bundle.weekly.isEmpty, isTrue);
  });
}
