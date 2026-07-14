import '../models/workout_session.dart';
import '../models/workout_summary.dart';

/// Contrato do repositório da sessão de treino (PROMPT 06).
///
/// Offline-first: a sessão ativa é persistida para sobreviver ao
/// fechamento do app; ao finalizar, calcula PRs, grava a sessão e
/// atualiza o histórico consumido pela Biblioteca.
abstract interface class WorkoutSessionRepository {
  /// Sessão ativa/pausada persistida (para retomar), ou null.
  WorkoutSession? loadActive();

  /// Autosave do progresso atual.
  Future<void> saveActive(WorkoutSession session);

  Future<void> clearActive();

  /// Finaliza: computa PRs, persiste a sessão, atualiza histórico e
  /// limpa a sessão ativa. Retorna o resumo.
  Future<WorkoutSummary> finish(WorkoutSession session);

  /// Sessões concluídas mais recentes (para Dashboard/Analytics).
  List<WorkoutSession> recentSessions({int limit});
}
