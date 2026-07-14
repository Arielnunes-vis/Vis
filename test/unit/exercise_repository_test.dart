import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/exercise/data/exercise_repository_impl.dart';
import 'package:vis/features/exercise/data/local_catalog_source.dart';
import 'package:vis/features/exercise/domain/exercise_enums.dart';
import 'package:vis/features/exercise/domain/exercise_filter.dart';
import 'package:vis/features/exercise/domain/exercise_user_data_store.dart';
import 'package:vis/features/exercise/models/exercise_history.dart';

class InMemUserStore implements ExerciseUserDataStore {
  final Map<String, Set<String>> _favs = {};

  @override
  Set<String> favoriteIds(String userId) => _favs[userId] ?? {};

  @override
  Future<void> writeFavorites(String userId, Set<String> ids) async =>
      _favs[userId] = ids;

  final Map<String, Map<String, ExerciseHistorySummary>> _hist = {};

  @override
  Map<String, ExerciseHistorySummary> history(String userId) =>
      _hist[userId] ?? const {};

  @override
  Future<void> writeHistory(
    String userId,
    Map<String, ExerciseHistorySummary> history,
  ) async =>
      _hist[userId] = history;
}

void main() {
  late ExerciseRepositoryImpl repo;

  setUp(() {
    repo = ExerciseRepositoryImpl(
      source: const LocalCatalogSource(),
      userStore: InMemUserStore(),
      currentUserId: () => 'u1',
    );
  });

  test('lista o catálogo completo', () async {
    final all = await repo.list(pageSize: 500);
    expect(all.length, greaterThan(10));
  });

  test('filtra por grupo muscular', () async {
    final chest = await repo.list(
      pageSize: 500,
      filter: const ExerciseFilter(muscle: Muscles.chest),
    );
    expect(chest, isNotEmpty);
    expect(chest.every((e) => e.primaryMuscle == Muscles.chest), isTrue);
  });

  test('busca por nome', () async {
    final res = await repo.list(query: 'supino', pageSize: 500);
    expect(res.any((e) => e.name.contains('Supino')), isTrue);
  });

  test('favoritar e filtrar favoritos', () async {
    await repo.toggleFavorite('bench_press');
    expect(repo.isFavorite('bench_press'), isTrue);

    final favs = await repo.list(
      pageSize: 500,
      filter: const ExerciseFilter(favoritesOnly: true),
    );
    expect(favs.length, 1);
    expect(favs.first.id, 'bench_press');

    await repo.toggleFavorite('bench_press');
    expect(repo.isFavorite('bench_press'), isFalse);
  });

  test('getByIds retorna relacionados', () async {
    final list = await repo.getByIds(['push_up', 'squat']);
    expect(list.length, 2);
  });

  test('paginação respeita page/pageSize', () async {
    final page0 = await repo.list(page: 0, pageSize: 5);
    final page1 = await repo.list(page: 1, pageSize: 5);
    expect(page0.length, 5);
    expect(page0.first.id, isNot(page1.first.id));
  });
}
