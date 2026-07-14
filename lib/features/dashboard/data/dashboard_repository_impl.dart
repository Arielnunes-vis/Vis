import '../../ai_insights/data/insight_engine.dart';
import '../../body_progress/repositories/body_progress_repository.dart';
import '../../cardio/repositories/cardio_repository.dart';
import '../../nutrition/models/macro_nutrients.dart';
import '../../nutrition/repositories/nutrition_repository.dart';
import '../../workout/models/workout_plan.dart';
import '../../workout/repositories/workout_repository.dart';
import '../../workout_session/models/workout_session.dart';
import '../../workout_session/repositories/workout_session_repository.dart';
import '../../../core/utils/date_utils.dart';
import '../models/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

/// Implementação do [DashboardRepository].
///
/// Agrega dados dos módulos Workout (planos), Workout Session (sessões)
/// e Body Progress (peso). Tudo offline-first. `now` é injetável para
/// testes determinísticos. [bodyProgressRepository] é opcional para
/// permitir testes sem esse módulo. Quando [insightEngine] é fornecido,
/// o insight do topo do Dashboard passa a vir do motor de insights
/// (PROMPT 14); caso contrário usa a regra local de fallback.
final class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required WorkoutRepository workoutRepository,
    required WorkoutSessionRepository sessionRepository,
    BodyProgressRepository? bodyProgressRepository,
    CardioRepository? cardioRepository,
    NutritionRepository? nutritionRepository,
    InsightEngine? insightEngine,
    DateTime Function()? now,
  })  : _workouts = workoutRepository,
        _sessions = sessionRepository,
        _body = bodyProgressRepository,
        _cardio = cardioRepository,
        _nutrition = nutritionRepository,
        _insightEngine = insightEngine,
        _now = now ?? DateTime.now;

  final WorkoutRepository _workouts;
  final WorkoutSessionRepository _sessions;
  final BodyProgressRepository? _body;
  final CardioRepository? _cardio;
  final NutritionRepository? _nutrition;
  final InsightEngine? _insightEngine;
  final DateTime Function() _now;

  @override
  Future<DashboardData> load() async {
    final plans = await _workouts.getPlans();
    final active = _activePlan(plans);
    final sessions = _sessions.recentSessions(limit: 200);

    final sequence = _sequence(sessions);
    final weekly = _weekly(sessions);
    final muscleVolume = _muscleVolume(sessions);
    final activity = _activity(sessions);
    final upcoming = _upcoming(active, sessions);
    final latestWeight = _body?.latestWeight();
    final startOfWeek = dateOnly(_now())
        .subtract(Duration(days: _now().weekday - 1));
    final cardioMinutes = _cardio?.statsSince(startOfWeek).totalMinutes ?? 0;

    final today = _now();
    final todayMacros = _nutrition == null
        ? MacroNutrients.zero
        : _nutrition!
            .mealsForDay(today)
            .fold(MacroNutrients.zero, (s, m) => s + m.macros);
    final todayWater = _nutrition?.waterForDayMl(today) ?? 0;

    return DashboardData(
      todayProtein: todayMacros.protein,
      todayWaterMl: todayWater,
      activePlan: active,
      upcoming: upcoming,
      latestWeight: latestWeight?.weight,
      latestWeightAt: latestWeight?.recordedAt,
      weeklyCardioMinutes: cardioMinutes,
      sequence: TrainingSequence(
        current: sequence.$1,
        longest: sequence.$2,
        weekCount: weekly.workouts,
        weekGoal: active?.days.length ?? 3,
      ),
      weekly: weekly,
      muscleVolume: muscleVolume,
      recentActivity: activity,
      lastWorkoutAt: sessions.isNotEmpty
          ? (sessions.first.finishedAt ?? sessions.first.startedAt)
          : null,
      insight: _resolveInsight(sequence.$1, weekly, muscleVolume),
    );
  }

  /// Usa o motor de insights (PROMPT 14) quando disponível; senão, a
  /// regra local de fallback — mantendo o Dashboard funcional sem o módulo.
  DashboardInsight? _resolveInsight(
    int streak,
    WeeklyStats weekly,
    List<MuscleVolume> muscleVolume,
  ) {
    final engine = _insightEngine;
    if (engine != null) {
      final top = engine.build().top;
      if (top != null) {
        return DashboardInsight(message: top.message, reason: top.reason);
      }
    }
    return _insight(streak, weekly, muscleVolume);
  }

  WorkoutPlan? _activePlan(List<WorkoutPlan> plans) {
    if (plans.isEmpty) return null;
    for (final p in plans) {
      if (p.isActive) return p;
    }
    return plans.first;
  }

  DateTime _sessionDate(WorkoutSession s) =>
      dateOnly(s.finishedAt ?? s.startedAt);

  /// (current, longest) sequência de dias consecutivos.
  (int, int) _sequence(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return (0, 0);
    final days = sessions.map(_sessionDate).toSet().toList()..sort();

    // Maior sequência.
    var longest = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        run++;
        if (run > longest) longest = run;
      } else {
        run = 1;
      }
    }

    // Sequência atual (terminando hoje ou ontem).
    final set = days.toSet();
    final today = dateOnly(_now());
    var cursor = today;
    if (!set.contains(today)) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (set.contains(yesterday)) {
        cursor = yesterday;
      } else {
        return (0, longest);
      }
    }
    var current = 0;
    while (set.contains(cursor)) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return (current, longest);
  }

  WeeklyStats _weekly(List<WorkoutSession> sessions) {
    final now = _now();
    final startOfWeek =
        dateOnly(now).subtract(Duration(days: now.weekday - 1));
    final week = sessions.where((s) => !_sessionDate(s).isBefore(startOfWeek));
    if (week.isEmpty) return const WeeklyStats();

    final muscles = <String>{};
    var minutes = 0;
    var volume = 0.0;
    var sets = 0;
    for (final s in week) {
      minutes += (s.elapsedSeconds / 60).round();
      volume += s.totalVolume;
      sets += s.completedSets;
      muscles.addAll(s.muscleGroups);
    }
    return WeeklyStats(
      workouts: week.length,
      totalMinutes: minutes,
      totalVolume: volume,
      totalSets: sets,
      muscleGroups: muscles,
    );
  }

  List<MuscleVolume> _muscleVolume(List<WorkoutSession> sessions) {
    final since = dateOnly(_now()).subtract(const Duration(days: 30));
    final byMuscle = <String, double>{};
    for (final s in sessions.where((s) => !_sessionDate(s).isBefore(since))) {
      for (final e in s.exercises) {
        final g = e.exercise.muscleGroup;
        if (g.isEmpty) continue;
        byMuscle[g] = (byMuscle[g] ?? 0) + e.volume;
      }
    }
    final list = byMuscle.entries
        .map((e) => MuscleVolume(e.key, e.value))
        .toList()
      ..sort((a, b) => b.volume.compareTo(a.volume));
    return list;
  }

  List<RecentActivity> _activity(List<WorkoutSession> sessions) {
    return sessions
        .take(8)
        .map((s) => RecentActivity(
              kind: ActivityKind.workout,
              title: 'Treino ${s.dayName} concluído',
              subtitle:
                  '${s.completedSets} séries · ${s.totalVolume.toStringAsFixed(0)} kg',
              date: s.finishedAt ?? s.startedAt,
            ))
        .toList();
  }

  UpcomingWorkout? _upcoming(WorkoutPlan? active, List<WorkoutSession> sessions) {
    if (active == null || active.days.isEmpty) return null;
    final days = active.days;
    final lastDayName = sessions.isNotEmpty ? sessions.first.dayName : null;
    final idx = days.indexWhere((d) => d.name == lastDayName);
    final next = idx >= 0 ? days[(idx + 1) % days.length] : days.first;
    return UpcomingWorkout(
      planId: active.id,
      planName: active.name,
      dayId: next.id,
      dayName: next.name,
      exerciseCount: next.totalExercises,
      muscleGroups: next.muscleGroups.toList(),
      estimatedMinutes: next.estimatedDuration,
    );
  }

  DashboardInsight? _insight(
    int streak,
    WeeklyStats weekly,
    List<MuscleVolume> muscleVolume,
  ) {
    if (streak >= 2) {
      return DashboardInsight(
        message: 'Você está há $streak dias treinando em sequência. 🔥',
        reason: 'Manter a consistência é o que mais acelera sua evolução.',
      );
    }
    if (weekly.workouts == 0) {
      return const DashboardInsight(
        message: 'Você ainda não treinou nesta semana.',
        reason: 'Que tal começar hoje? Um treino já muda o ritmo da semana.',
      );
    }
    return DashboardInsight(
      message:
          'Você treinou ${weekly.workouts}x nesta semana, movimentando ${weekly.totalVolume.toStringAsFixed(0)} kg.',
      reason: 'Bom volume acumulado — continue no ritmo.',
    );
  }
}
