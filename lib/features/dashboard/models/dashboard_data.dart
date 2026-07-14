import '../../workout/models/workout_plan.dart';

/// Insight exibido no topo do Dashboard (PROMPT 07 / Regra 006-008).
///
/// Sempre baseado em dados reais e acompanhado do motivo. Nesta fase é
/// gerado por regras locais; o módulo de IA (14) substituirá a origem.
class DashboardInsight {
  const DashboardInsight({required this.message, this.reason});
  final String message;
  final String? reason;
}

/// Próximo treino sugerido.
class UpcomingWorkout {
  const UpcomingWorkout({
    required this.planId,
    required this.planName,
    required this.dayId,
    required this.dayName,
    required this.exerciseCount,
    required this.muscleGroups,
    this.estimatedMinutes,
  });

  final String planId;
  final String planName;
  final String dayId;
  final String dayName;
  final int exerciseCount;
  final List<String> muscleGroups;
  final int? estimatedMinutes;
}

/// Sequência de treinos.
class TrainingSequence {
  const TrainingSequence({
    this.current = 0,
    this.longest = 0,
    this.weekCount = 0,
    this.weekGoal = 0,
  });

  final int current;
  final int longest;
  final int weekCount;
  final int weekGoal;
}

/// Resumo semanal.
class WeeklyStats {
  const WeeklyStats({
    this.workouts = 0,
    this.totalMinutes = 0,
    this.totalVolume = 0,
    this.totalSets = 0,
    this.muscleGroups = const {},
  });

  final int workouts;
  final int totalMinutes;
  final double totalVolume;
  final int totalSets;
  final Set<String> muscleGroups;
}

/// Volume por grupo muscular (para o gráfico).
class MuscleVolume {
  const MuscleVolume(this.muscle, this.volume);
  final String muscle;
  final double volume;
}

/// Item da atividade recente.
enum ActivityKind { workout, personalRecord, weight, measurement, photo, cardio }

class RecentActivity {
  const RecentActivity({
    required this.kind,
    required this.title,
    required this.date,
    this.subtitle,
  });

  final ActivityKind kind;
  final String title;
  final String? subtitle;
  final DateTime date;
}

/// Agregado consumido pela tela do Dashboard (PROMPT 07).
class DashboardData {
  const DashboardData({
    this.insight,
    this.upcoming,
    this.activePlan,
    this.sequence = const TrainingSequence(),
    this.weekly = const WeeklyStats(),
    this.muscleVolume = const [],
    this.recentActivity = const [],
    this.lastWorkoutAt,
    this.latestWeight,
    this.latestWeightAt,
    this.weeklyCardioMinutes = 0,
    this.todayProtein = 0,
    this.todayWaterMl = 0,
  });

  final DashboardInsight? insight;
  final UpcomingWorkout? upcoming;
  final WorkoutPlan? activePlan;
  final TrainingSequence sequence;
  final WeeklyStats weekly;
  final List<MuscleVolume> muscleVolume;
  final List<RecentActivity> recentActivity;
  final DateTime? lastWorkoutAt;
  final double? latestWeight;
  final DateTime? latestWeightAt;
  final int weeklyCardioMinutes;
  final double todayProtein;
  final int todayWaterMl;

  bool get isEmpty =>
      upcoming == null && weekly.workouts == 0 && recentActivity.isEmpty;
}
