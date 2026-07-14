import '../domain/exercise_filter.dart';
import '../models/exercise.dart';
import '../models/exercise_history.dart';

/// Contrato do repositório da biblioteca de exercícios (PROMPT 05).
abstract interface class ExerciseRepository {
  /// Lista paginada com filtros e busca.
  Future<List<Exercise>> list({
    int page,
    int pageSize,
    ExerciseFilter filter,
    String query,
  });

  Future<Exercise?> getById(String id);
  Future<List<Exercise>> getByIds(List<String> ids);
  Future<int> total();

  // Favoritos (offline).
  Set<String> favorites();
  bool isFavorite(String id);
  Future<void> toggleFavorite(String id);

  // Histórico agregado.
  ExerciseHistorySummary? historyFor(String id);
}
