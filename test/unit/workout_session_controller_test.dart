import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/authentication/models/user_model.dart';
import 'package:vis/features/authentication/providers/authentication_providers.dart';
import 'package:vis/features/authentication/repositories/authentication_repository.dart';
import 'package:vis/features/workout/models/exercise_ref.dart';
import 'package:vis/features/workout/models/workout_day.dart';
import 'package:vis/features/workout/models/workout_exercise.dart';
import 'package:vis/features/workout/models/workout_plan.dart';
import 'package:vis/features/workout/models/workout_set.dart';
import 'package:vis/features/workout_session/domain/session_enums.dart';
import 'package:vis/features/workout_session/models/workout_session.dart';
import 'package:vis/features/workout_session/models/workout_summary.dart';
import 'package:vis/features/workout_session/providers/workout_session_providers.dart';
import 'package:vis/features/workout_session/repositories/workout_session_repository.dart';

class FakeSessionRepo implements WorkoutSessionRepository {
  WorkoutSession? _active;

  @override
  WorkoutSession? loadActive() => _active;
  @override
  Future<void> saveActive(WorkoutSession session) async => _active = session;
  @override
  Future<void> clearActive() async => _active = null;
  @override
  Future<WorkoutSummary> finish(WorkoutSession session) async {
    _active = null;
    final finished = session.copyWith(status: SessionStatus.finished);
    return WorkoutSummary(
      session: finished,
      stats: WorkoutStats.fromSession(finished),
    );
  }

  @override
  List<WorkoutSession> recentSessions({int limit = 20}) => const [];
}

class FakeAuth implements AuthenticationRepository {
  @override
  UserModel? get currentUser => const UserModel(id: 'u1', email: 'a@b.c');
  @override
  Stream<UserModel?> get userChanges => const Stream.empty();
  @override
  Future<UserModel> login({required String email, required String password}) =>
      throw UnimplementedError();
  @override
  Future<UserModel?> register(
          {required String email,
          required String password,
          required String name}) =>
      throw UnimplementedError();
  @override
  Future<void> logout() async {}
  @override
  Future<void> forgotPassword(String email) async {}
  @override
  Future<void> resendConfirmation(String email) async {}
  @override
  Future<UserModel?> refreshSession() async => null;
  @override
  Future<UserModel?> updateProfile({String? name, String? photoUrl}) async =>
      null;
  @override
  Future<void> deleteAccount() async {}
}

WorkoutPlan _plan() => const WorkoutPlan(
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
              sets: [
                WorkoutSet(setNumber: 1),
                WorkoutSet(setNumber: 2),
              ],
            ),
          ],
        ),
      ],
    );

void main() {
  ProviderContainer container() => ProviderContainer(overrides: [
        workoutSessionRepositoryProvider.overrideWithValue(FakeSessionRepo()),
        authenticationRepositoryProvider.overrideWithValue(FakeAuth()),
      ]);

  test('start constrói a sessão a partir do plano/dia', () async {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = c.read(workoutSessionControllerProvider.notifier);
    expect(c.read(workoutSessionControllerProvider).session, isNull);

    final plan = _plan();
    await ctrl.start(plan, plan.days.first);

    final st = c.read(workoutSessionControllerProvider);
    expect(st.session, isNotNull);
    expect(st.session!.exercises.first.sets.length, 2);
  });

  test('completar série registra e inicia descanso', () async {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = c.read(workoutSessionControllerProvider.notifier);
    final plan = _plan();
    await ctrl.start(plan, plan.days.first);

    ctrl.updateSet(0, 0, weight: 50, reps: 10);
    ctrl.completeSet(0, 0);

    final st = c.read(workoutSessionControllerProvider);
    expect(st.session!.exercises.first.sets.first.completed, isTrue);
    expect(st.session!.totalVolume, 500);
    expect(st.isResting, isTrue);
  });

  test('finish retorna resumo e marca a sessão como concluída', () async {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = c.read(workoutSessionControllerProvider.notifier);
    final plan = _plan();
    await ctrl.start(plan, plan.days.first);
    ctrl.updateSet(0, 0, weight: 50, reps: 10);
    ctrl.completeSet(0, 0);

    final summary = await ctrl.finish(mood: WorkoutMood.good, energy: 4);
    expect(summary, isNotNull);
    expect(summary!.session.isFinished, isTrue);
    expect(summary.session.mood, WorkoutMood.good);
  });
}
