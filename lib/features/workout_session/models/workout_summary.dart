import 'workout_pr.dart';
import 'workout_session.dart';

/// Estatísticas agregadas de uma sessão concluída (PROMPT 06).
class WorkoutStats {
  const WorkoutStats({
    required this.durationSeconds,
    required this.totalVolume,
    required this.totalSets,
    required this.totalExercises,
    required this.muscleGroups,
  });

  final int durationSeconds;
  final double totalVolume;
  final int totalSets;
  final int totalExercises;
  final Set<String> muscleGroups;

  factory WorkoutStats.fromSession(WorkoutSession s) => WorkoutStats(
        durationSeconds: s.elapsedSeconds,
        totalVolume: s.totalVolume,
        totalSets: s.completedSets,
        totalExercises: s.totalExercises,
        muscleGroups: s.muscleGroups,
      );
}

/// Resumo final apresentado ao usuário ao concluir o treino.
class WorkoutSummary {
  const WorkoutSummary({
    required this.session,
    required this.stats,
    this.personalRecords = const [],
    this.aiInsight,
  });

  final WorkoutSession session;
  final WorkoutStats stats;
  final List<WorkoutPR> personalRecords;

  /// Insight da IA (preenchido pelo módulo de IA — estrutura preparada).
  final String? aiInsight;

  bool get hasPr => personalRecords.isNotEmpty;
}
