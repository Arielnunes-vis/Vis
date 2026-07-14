import '../models/exercise.dart';
import 'exercise_filter.dart';

/// Fonte de dados do catálogo de exercícios (PROMPT 05).
///
/// Abstração que permite uma implementação local (seed) e, futuramente,
/// uma implementação Supabase paginada (5.000+ exercícios) sem alterar
/// os controllers.
abstract interface class ExerciseCatalogSource {
  /// Retorna todos os exercícios que atendem [filter] + [query]
  /// (ordenados por nome). A paginação para exibição é aplicada na
  /// camada de repositório; uma fonte remota faria isso no servidor.
  Future<List<Exercise>> search({
    ExerciseFilter filter,
    String query,
  });

  Future<Exercise?> byId(String id);
  Future<List<Exercise>> byIds(List<String> ids);
  Future<int> count();
}
