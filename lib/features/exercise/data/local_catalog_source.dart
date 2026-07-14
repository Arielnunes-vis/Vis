import '../domain/exercise_catalog_source.dart';
import '../domain/exercise_filter.dart';
import '../models/exercise.dart';
import 'exercise_catalog_seed.dart';

/// Implementação local do [ExerciseCatalogSource] a partir do seed.
final class LocalCatalogSource implements ExerciseCatalogSource {
  const LocalCatalogSource([this.catalog = ExerciseCatalogSeed.all]);

  final List<Exercise> catalog;

  @override
  Future<List<Exercise>> search({
    ExerciseFilter filter = const ExerciseFilter(),
    String query = '',
  }) async {
    final q = query.trim().toLowerCase();
    final result = catalog
        .where(filter.matches)
        .where((e) => q.isEmpty || e.searchIndex.contains(q))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  @override
  Future<Exercise?> byId(String id) async {
    for (final e in catalog) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<List<Exercise>> byIds(List<String> ids) async =>
      catalog.where((e) => ids.contains(e.id)).toList();

  @override
  Future<int> count() async => catalog.length;
}
