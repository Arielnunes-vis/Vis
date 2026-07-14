import 'dart:io';

import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/core/constants/app_constants.dart';
import 'package:vis/core/storage/local_storage_service.dart';
import 'package:vis/features/exercise/data/hive_exercise_user_data_store.dart';
import 'package:vis/features/workout/models/exercise_ref.dart';
import 'package:vis/features/workout_session/data/workout_session_repository_impl.dart';
import 'package:vis/features/workout_session/models/workout_exercise_session.dart';
import 'package:vis/features/workout_session/models/workout_session.dart';
import 'package:vis/features/workout_session/models/workout_set_session.dart';

void main() {
  late Directory dir;

  setUpAll(() async {
    dir = Directory.systemTemp.createTempSync('vis_hive_test');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>(AppConstants.boxWorkouts);
    await Hive.openBox<dynamic>(AppConstants.boxCache);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    dir.deleteSync(recursive: true);
  });

  WorkoutSession sample() => WorkoutSession(
        id: 's1',
        userId: 'u1',
        planId: 'p1',
        planName: 'ABC',
        dayName: 'Treino A',
        startedAt: DateTime(2026, 1, 1),
        elapsedSeconds: 1800,
        exercises: [
          WorkoutExerciseSession(
            id: 'es1',
            exercise: const ExerciseRef(
                id: 'bench_press', name: 'Supino', muscleGroup: 'Peitoral'),
            sets: const [
              WorkoutSetSession(
                  id: 'st1', setNumber: 1, weight: 60, reps: 10, completed: true),
              WorkoutSetSession(
                  id: 'st2', setNumber: 2, weight: 60, reps: 8, completed: true),
            ],
          ),
        ],
      );

  test('finish computa PRs, atualiza histórico e limpa a sessão ativa',
      () async {
    const storage = LocalStorageService();
    final exStore = const HiveExerciseUserDataStore(storage);
    final repo = WorkoutSessionRepositoryImpl(
      storage: storage,
      exerciseStore: exStore,
      currentUserId: () => 'u1',
    );

    await repo.saveActive(sample());
    expect(repo.loadActive(), isNotNull);

    final summary = await repo.finish(sample());

    // Volume = 60*10 + 60*8 = 1080; maxWeight = 60; maxReps = 10.
    expect(summary.stats.totalVolume, 1080);
    expect(summary.personalRecords.any((p) => p.value == 60), isTrue);
    expect(summary.personalRecords.any((p) => p.value == 10), isTrue);

    // Histórico da Biblioteca foi atualizado.
    final hist = exStore.history('u1')['bench_press'];
    expect(hist, isNotNull);
    expect(hist!.maxWeight, 60);
    expect(hist.timesPerformed, 1);

    // Sessão ativa foi limpa; sessão concluída registrada.
    expect(repo.loadActive(), isNull);
    expect(repo.recentSessions().length, 1);
  });

  test('segunda sessão igual NÃO gera novo PR de carga', () async {
    const storage = LocalStorageService();
    final exStore = const HiveExerciseUserDataStore(storage);
    final repo = WorkoutSessionRepositoryImpl(
      storage: storage,
      exerciseStore: exStore,
      currentUserId: () => 'u2',
    );

    await repo.finish(sample().copyWith()); // u2 primeira vez → PR
    final second = await repo.finish(sample().copyWith());
    // Mesmos números: sem novo PR de maior carga nem de reps.
    expect(second.personalRecords.where((p) => p.value == 60), isEmpty);
  });
}
