import '../models/workout_plan.dart';

/// Contrato do repositório do Workout Engine (PROMPT 04).
///
/// Offline-first: as operações funcionam sem internet e ficam prontas
/// para sincronização posterior com o Supabase (tabelas workout_*).
abstract interface class WorkoutRepository {
  Future<List<WorkoutPlan>> getPlans();
  Future<WorkoutPlan?> getPlan(String id);

  /// Cria ou atualiza (upsert) um plano.
  Future<WorkoutPlan> savePlan(WorkoutPlan plan);

  /// Duplica um plano existente, gerando novos IDs.
  Future<WorkoutPlan> duplicatePlan(String id);

  /// Soft delete — remove da lista ativa, preservando histórico no backend.
  Future<void> deletePlan(String id);

  /// Marca um plano como ativo (e os demais como inativos).
  Future<void> setActive(String id);
}
