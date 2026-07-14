import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/providers/authentication_providers.dart';
import '../../workout/models/workout_day.dart';
import '../../workout/models/workout_plan.dart';
import '../domain/session_enums.dart';
import '../models/workout_exercise_session.dart';
import '../models/workout_session.dart';
import '../models/workout_set_session.dart';
import '../models/workout_summary.dart';
import '../providers/workout_session_providers.dart';

/// Estado de runtime da sessão: a sessão + o cronômetro de descanso.
class SessionState {
  const SessionState({
    this.session,
    this.restRemaining = 0,
    this.restTotal = 0,
  });

  final WorkoutSession? session;
  final int restRemaining;
  final int restTotal;

  bool get isResting => restRemaining > 0;
  bool get hasActive => session != null && !session!.isFinished;

  SessionState copyWith({
    WorkoutSession? session,
    int? restRemaining,
    int? restTotal,
  }) {
    return SessionState(
      session: session ?? this.session,
      restRemaining: restRemaining ?? this.restRemaining,
      restTotal: restTotal ?? this.restTotal,
    );
  }
}

/// Controller da execução de treino (PROMPT 06).
class WorkoutSessionController extends Notifier<SessionState> {
  final Uuid _uuid = const Uuid();
  Timer? _ticker;
  int _ticks = 0;

  @override
  SessionState build() {
    // Retoma uma sessão pausada/ativa persistida (sobrevive ao fechar o app).
    final active = ref.read(workoutSessionRepositoryProvider).loadActive();
    ref.onDispose(() => _ticker?.cancel());
    if (active != null) {
      _startTicker();
      return SessionState(session: active);
    }
    return const SessionState();
  }

  String _newId() => _uuid.v4();

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final s = state.session;
    if (s == null || s.isFinished) return;

    if (state.restRemaining > 0) {
      state = state.copyWith(
        restRemaining: state.restRemaining - 1,
        session: s.copyWith(restSeconds: s.restSeconds + 1),
      );
    } else if (!s.isPaused) {
      state = state.copyWith(
        session: s.copyWith(elapsedSeconds: s.elapsedSeconds + 1),
      );
    }

    if (++_ticks % 5 == 0) _save();
  }

  // ---------- Início ----------
  Future<void> start(WorkoutPlan plan, WorkoutDay day) async {
    final uid = ref.read(authenticationRepositoryProvider).currentUser?.id ?? '';
    final exercises = day.exercises
        .map((we) => WorkoutExerciseSession(
              id: _newId(),
              exercise: we.exercise,
              sets: we.sets
                  .map((ps) => WorkoutSetSession(
                        id: _newId(),
                        setNumber: ps.setNumber,
                        type: ps.type,
                        targetReps: ps.targetReps,
                        restSeconds: ps.restSeconds,
                      ))
                  .toList(),
            ))
        .toList();

    final session = WorkoutSession(
      id: _newId(),
      userId: uid,
      planId: plan.id,
      planName: plan.name,
      dayName: day.name,
      startedAt: DateTime.now(),
      exercises: exercises,
    );

    state = SessionState(session: session);
    await _save();
    _startTicker();
  }

  // ---------- Edição das séries ----------
  void updateSet(
    int exIndex,
    int setIndex, {
    double? weight,
    int? reps,
    double? rpe,
    String? note,
  }) {
    _mutateSet(exIndex, setIndex,
        (s) => s.copyWith(weight: weight, reps: reps, rpe: rpe, note: note));
  }

  void completeSet(int exIndex, int setIndex) {
    final s = state.session;
    if (s == null) return;
    final set = s.exercises[exIndex].sets[setIndex];
    _mutateSet(exIndex, setIndex, (x) => x.copyWith(completed: true));
    if (!set.isWarmup) startRest(set.restSeconds);
    _save();
  }

  void uncompleteSet(int exIndex, int setIndex) {
    _mutateSet(exIndex, setIndex, (x) => x.copyWith(completed: false));
  }

  void addSet(int exIndex) {
    final s = state.session;
    if (s == null) return;
    final ex = s.exercises[exIndex];
    final last = ex.sets.isNotEmpty ? ex.sets.last : null;
    final newSet = WorkoutSetSession(
      id: _newId(),
      setNumber: ex.sets.length + 1,
      targetReps: last?.targetReps ?? '',
      restSeconds: last?.restSeconds ?? 90,
      weight: last?.weight,
    );
    _mutateExercise(exIndex, (e) => e.copyWith(sets: [...e.sets, newSet]));
    _save();
  }

  void setExerciseNote(int exIndex, String note) =>
      _mutateExercise(exIndex, (e) => e.copyWith(note: note));

  // ---------- Descanso ----------
  void startRest(int seconds) =>
      state = state.copyWith(restRemaining: seconds, restTotal: seconds);
  void addRest(int delta) => state = state.copyWith(
      restRemaining: (state.restRemaining + delta).clamp(0, 3600));
  void skipRest() => state = state.copyWith(restRemaining: 0);

  // ---------- Pausar / retomar ----------
  Future<void> pause() async {
    final s = state.session;
    if (s == null) return;
    state = state.copyWith(session: s.copyWith(status: SessionStatus.paused));
    await _save();
  }

  Future<void> resume() async {
    final s = state.session;
    if (s == null) return;
    state = state.copyWith(session: s.copyWith(status: SessionStatus.active));
    await _save();
  }

  // ---------- Finalizar ----------
  Future<WorkoutSummary?> finish({
    WorkoutMood? mood,
    int? energy,
    String? notes,
  }) async {
    final s = state.session;
    if (s == null) return null;
    _ticker?.cancel();
    final withMeta = s.copyWith(mood: mood, energy: energy, notes: notes);
    final summary =
        await ref.read(workoutSessionRepositoryProvider).finish(withMeta);
    state = state.copyWith(session: summary.session, restRemaining: 0);
    return summary;
  }

  Future<void> discard() async {
    _ticker?.cancel();
    await ref.read(workoutSessionRepositoryProvider).clearActive();
    state = const SessionState();
  }

  // ---------- Helpers ----------
  Future<void> _save() async {
    final s = state.session;
    if (s == null || s.isFinished) return;
    await ref.read(workoutSessionRepositoryProvider).saveActive(s);
  }

  void _mutateSet(
    int exIndex,
    int setIndex,
    WorkoutSetSession Function(WorkoutSetSession) fn,
  ) {
    _mutateExercise(exIndex, (e) {
      final sets = [...e.sets];
      sets[setIndex] = fn(sets[setIndex]);
      return e.copyWith(sets: sets);
    });
  }

  void _mutateExercise(
    int exIndex,
    WorkoutExerciseSession Function(WorkoutExerciseSession) fn,
  ) {
    final s = state.session;
    if (s == null) return;
    final exercises = [...s.exercises];
    exercises[exIndex] = fn(exercises[exIndex]);
    state = state.copyWith(session: s.copyWith(exercises: exercises));
  }
}
