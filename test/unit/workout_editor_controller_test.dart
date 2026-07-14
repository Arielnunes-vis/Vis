import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/authentication/models/user_model.dart';
import 'package:vis/features/authentication/providers/authentication_providers.dart';
import 'package:vis/features/authentication/repositories/authentication_repository.dart';
import 'package:vis/features/workout/models/exercise_ref.dart';
import 'package:vis/features/workout/providers/workout_providers.dart';

/// Fake mínimo de auth (o editor lê apenas currentUser?.id).
class _FakeAuth implements AuthenticationRepository {
  @override
  UserModel? get currentUser => const UserModel(id: 'u1', email: 'a@b.c');
  @override
  Stream<UserModel?> get userChanges => const Stream.empty();
  @override
  Future<UserModel> login({required String email, required String password}) =>
      throw UnimplementedError();
  @override
  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
  }) =>
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

void main() {
  ProviderContainer container() => ProviderContainer(
        overrides: [
          authenticationRepositoryProvider.overrideWithValue(_FakeAuth()),
        ],
      );

  test('adicionar dia e exercício cria 3 séries por padrão', () {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = c.read(workoutEditorControllerProvider.notifier);

    ctrl.setName('PPL');
    ctrl.addDay('Push');
    final dayId = c.read(workoutEditorControllerProvider).days.first.id;
    ctrl.addExercise(dayId,
        const ExerciseRef(id: 'bp', name: 'Supino', muscleGroup: 'Peitoral'));

    final state = c.read(workoutEditorControllerProvider);
    expect(state.days.first.exercises.length, 1);
    expect(state.days.first.exercises.first.sets.length, 3);
    expect(ctrl.isValid, isTrue);
  });

  test('mover exercício para baixo troca a ordem', () {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = c.read(workoutEditorControllerProvider.notifier);

    ctrl.addDay('Push');
    final dayId = c.read(workoutEditorControllerProvider).days.first.id;
    ctrl.addExercise(dayId,
        const ExerciseRef(id: 'a', name: 'Supino', muscleGroup: 'Peitoral'));
    ctrl.addExercise(dayId,
        const ExerciseRef(id: 'b', name: 'Crucifixo', muscleGroup: 'Peitoral'));

    ctrl.moveExerciseDown(dayId, 0);
    final ex = c.read(workoutEditorControllerProvider).days.first.exercises;
    expect(ex.first.exercise.name, 'Crucifixo');
    expect(ex.last.exercise.name, 'Supino');
  });

  test('isValid exige nome e ao menos um dia', () {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = c.read(workoutEditorControllerProvider.notifier);

    expect(ctrl.isValid, isFalse);
    ctrl.setName('Treino');
    expect(ctrl.isValid, isFalse); // sem dias
    ctrl.addDay();
    expect(ctrl.isValid, isTrue);
  });
}
