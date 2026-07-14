/// Armazenamento local de planos de treino (offline-first) — PROMPT 04.
///
/// Abstração para permitir uma implementação Hive em produção e uma
/// implementação em memória nos testes. Guarda/recupera os planos já
/// serializados (mapas), por usuário.
abstract interface class WorkoutLocalStore {
  List<Map<String, dynamic>> readPlans(String userId);
  Future<void> writePlans(String userId, List<Map<String, dynamic>> plans);
}
