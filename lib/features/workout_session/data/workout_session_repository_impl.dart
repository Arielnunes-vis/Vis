import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../exercise/domain/exercise_user_data_store.dart';
import '../../exercise/models/exercise_history.dart';
import '../domain/session_enums.dart';
import '../models/workout_pr.dart';
import '../models/workout_session.dart';
import '../models/workout_summary.dart';
import '../repositories/workout_session_repository.dart';

/// Implementação offline-first do [WorkoutSessionRepository].
final class WorkoutSessionRepositoryImpl implements WorkoutSessionRepository {
  WorkoutSessionRepositoryImpl({
    required LocalStorageService storage,
    required ExerciseUserDataStore exerciseStore,
    required String? Function() currentUserId,
  })  : _storage = storage,
        _exerciseStore = exerciseStore,
        _currentUserId = currentUserId;

  final LocalStorageService _storage;
  final ExerciseUserDataStore _exerciseStore;
  final String? Function() _currentUserId;

  String get _uid => _currentUserId() ?? 'local';
  String get _box => AppConstants.boxWorkouts;
  String get _activeKey => 'active_session_$_uid';
  String get _sessionsKey => 'sessions_$_uid';

  @override
  WorkoutSession? loadActive() {
    final raw = _storage.get<Map<dynamic, dynamic>>(_box, _activeKey);
    if (raw == null) return null;
    final session = WorkoutSession.fromMap(Map<String, dynamic>.from(raw));
    return session.isFinished ? null : session;
  }

  @override
  Future<void> saveActive(WorkoutSession session) =>
      _storage.put(_box, _activeKey, session.toMap());

  @override
  Future<void> clearActive() => _storage.delete(_box, _activeKey);

  @override
  Future<WorkoutSummary> finish(WorkoutSession session) async {
    final finished = session.copyWith(
      status: SessionStatus.finished,
      finishedAt: DateTime.now(),
    );

    final history = {..._exerciseStore.history(_uid)};
    final prs = <WorkoutPR>[];

    for (final ex in finished.exercises) {
      if (ex.completedSets == 0) continue;
      final prev = history[ex.exercise.id];
      final newMaxWeight = ex.maxWeight;
      final newMaxReps = ex.maxReps;
      final newVolume = ex.volume;

      // Detecção de PRs (comparado ao histórico anterior).
      if (newMaxWeight != null &&
          newMaxWeight > (prev?.maxWeight ?? 0)) {
        prs.add(WorkoutPR(
          exerciseId: ex.exercise.id,
          exerciseName: ex.exercise.name,
          kind: PRKind.maxWeight,
          value: newMaxWeight,
        ));
      }
      if (newVolume > (prev?.maxVolume ?? 0)) {
        prs.add(WorkoutPR(
          exerciseId: ex.exercise.id,
          exerciseName: ex.exercise.name,
          kind: PRKind.maxVolume,
          value: newVolume,
        ));
      }
      if (newMaxReps != null && newMaxReps > (prev?.maxReps ?? 0)) {
        prs.add(WorkoutPR(
          exerciseId: ex.exercise.id,
          exerciseName: ex.exercise.name,
          kind: PRKind.maxReps,
          value: newMaxReps.toDouble(),
        ));
      }

      // Atualiza o histórico agregado (nunca reduz os máximos).
      history[ex.exercise.id] = ExerciseHistorySummary(
        exerciseId: ex.exercise.id,
        lastPerformedAt: finished.finishedAt,
        maxWeight: _max(prev?.maxWeight, newMaxWeight),
        maxVolume: _max(prev?.maxVolume, newVolume),
        maxReps: _maxInt(prev?.maxReps, newMaxReps),
        timesPerformed: (prev?.timesPerformed ?? 0) + 1,
        lastNote: ex.note ?? prev?.lastNote,
      );
    }

    await _exerciseStore.writeHistory(_uid, history);
    await _appendSession(finished);
    await clearActive();

    return WorkoutSummary(
      session: finished,
      stats: WorkoutStats.fromSession(finished),
      personalRecords: prs,
    );
  }

  @override
  List<WorkoutSession> recentSessions({int limit = 20}) {
    final raw = _storage.get<List<dynamic>>(_box, _sessionsKey) ?? const [];
    final list = raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => WorkoutSession.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) =>
          (b.finishedAt ?? b.startedAt).compareTo(a.finishedAt ?? a.startedAt));
    return list.take(limit).toList();
  }

  Future<void> _appendSession(WorkoutSession session) async {
    final raw = _storage.get<List<dynamic>>(_box, _sessionsKey) ?? const [];
    final list = [session.toMap(), ...raw].take(100).toList();
    await _storage.put(_box, _sessionsKey, list);
  }

  double? _max(double? a, double? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a > b ? a : b;
  }

  int? _maxInt(int? a, int? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a > b ? a : b;
  }
}
