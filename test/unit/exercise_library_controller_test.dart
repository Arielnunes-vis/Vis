import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/exercise/data/exercise_repository_impl.dart';
import 'package:vis/features/exercise/data/local_catalog_source.dart';
import 'package:vis/features/exercise/domain/exercise_enums.dart';
import 'package:vis/features/exercise/providers/exercise_providers.dart';

import 'exercise_repository_test.dart' show InMemUserStore;

void main() {
  ProviderContainer container() {
    final repo = ExerciseRepositoryImpl(
      source: const LocalCatalogSource(),
      userStore: InMemUserStore(),
      currentUserId: () => 'u1',
    );
    return ProviderContainer(
      overrides: [exerciseRepositoryProvider.overrideWithValue(repo)],
    );
  }

  test('reload popula resultados', () async {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = c.read(exerciseLibraryControllerProvider.notifier);
    await ctrl.reload();
    final state = c.read(exerciseLibraryControllerProvider);
    expect(state.results.value, isNotNull);
    expect(state.results.value!.isNotEmpty, isTrue);
  });

  test('setMuscle filtra por grupo muscular', () async {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = c.read(exerciseLibraryControllerProvider.notifier);

    ctrl.setMuscle(Muscles.chest);
    expect(
      c.read(exerciseLibraryControllerProvider).filter.muscle,
      Muscles.chest,
    );

    await ctrl.reload();
    final res = c.read(exerciseLibraryControllerProvider).results.value!;
    expect(res.every((e) => e.primaryMuscle == Muscles.chest), isTrue);
  });
}
