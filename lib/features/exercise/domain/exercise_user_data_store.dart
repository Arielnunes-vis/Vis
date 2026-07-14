import '../models/exercise_history.dart';

/// Armazena dados do usuário sobre exercícios (favoritos e histórico),
/// localmente para funcionar offline (PROMPT 05).
///
/// O histórico é alimentado pelo módulo Workout Session; aqui é lido
/// como agregado por exercício.
abstract interface class ExerciseUserDataStore {
  Set<String> favoriteIds(String userId);
  Future<void> writeFavorites(String userId, Set<String> ids);

  /// Histórico agregado por exerciseId (pode estar vazio até haver sessões).
  Map<String, ExerciseHistorySummary> history(String userId);

  /// Persiste o histórico agregado (escrito pelo módulo Workout Session).
  Future<void> writeHistory(
    String userId,
    Map<String, ExerciseHistorySummary> history,
  );
}
