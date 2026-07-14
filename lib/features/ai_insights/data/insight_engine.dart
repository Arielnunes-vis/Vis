import '../../body_progress/repositories/body_progress_repository.dart';
import '../../cardio/repositories/cardio_repository.dart';
import '../../nutrition/models/macro_nutrients.dart';
import '../../nutrition/repositories/nutrition_repository.dart';
import '../../workout_session/models/workout_session.dart';
import '../../workout_session/repositories/workout_session_repository.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/insight_enums.dart';
import '../models/insight.dart';
import '../models/weekly_summary.dart';

/// Resultado do motor: insights + resumo semanal.
class InsightBundle {
  const InsightBundle({this.insights = const [], this.weekly = const WeeklySummary()});
  final List<Insight> insights;
  final WeeklySummary weekly;

  Insight? get top => insights.isEmpty ? null : insights.first;
  List<Insight> get alerts => insights.where((i) => i.isAlert).toList();
}

/// Motor de insights e alertas por regras (PROMPT 14).
///
/// Cada insight é derivado de dados reais. A geração por modelo de IA
/// (não implementada aqui) poderá substituir/complementar estas regras.
final class InsightEngine {
  InsightEngine({
    required WorkoutSessionRepository sessionRepository,
    required BodyProgressRepository bodyRepository,
    required CardioRepository cardioRepository,
    required NutritionRepository nutritionRepository,
    DateTime Function()? now,
  })  : _sessions = sessionRepository,
        _body = bodyRepository,
        _cardio = cardioRepository,
        _nutrition = nutritionRepository,
        _now = now ?? DateTime.now;

  final WorkoutSessionRepository _sessions;
  final BodyProgressRepository _body;
  final CardioRepository _cardio;
  final NutritionRepository _nutrition;
  final DateTime Function() _now;

  InsightBundle build() {
    final now = _now();
    final today = dateOnly(now);
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = startOfWeek.subtract(const Duration(days: 7));

    final sessions = _sessions.recentSessions(limit: 200);
    final insights = <Insight>[];

    // ---- Consistência (sequência) ----
    final streak = _streak(sessions, today);
    if (streak >= 3) {
      insights.add(Insight(
        category: InsightCategory.consistency,
        type: InsightType.achievement,
        priority: InsightPriority.high,
        title: 'Sequência de $streak dias 🔥',
        message: 'Você treinou $streak dias seguidos.',
        reason: 'Consistência é o que mais acelera sua evolução.',
        createdAt: now,
      ));
    } else if (streak == 0 && sessions.isNotEmpty) {
      final days = today.difference(_sessionDate(sessions.first)).inDays;
      if (days >= 3) {
        insights.add(Insight(
          category: InsightCategory.consistency,
          type: InsightType.alert,
          priority: InsightPriority.medium,
          title: 'Sua sequência parou',
          message: 'Você não treina há $days dias.',
          reason: 'Retomar hoje evita perder o ritmo conquistado.',
          createdAt: now,
        ));
      }
    }

    // ---- Volume semanal vs semana anterior ----
    final thisWeekVol = _volumeBetween(sessions, startOfWeek, today.add(const Duration(days: 1)));
    final lastWeekVol = _volumeBetween(sessions, lastWeekStart, startOfWeek);
    if (lastWeekVol > 0 && thisWeekVol >= lastWeekVol * 1.1) {
      final pct = ((thisWeekVol / lastWeekVol - 1) * 100).round();
      insights.add(Insight(
        category: InsightCategory.performance,
        type: InsightType.insight,
        priority: InsightPriority.low,
        title: 'Volume em alta',
        message: 'Seu volume subiu $pct% em relação à semana passada.',
        reason: 'Progressão de volume é um bom sinal de evolução.',
        createdAt: now,
      ));
    }

    // ---- Cardio ----
    final cardio = _cardio.history();
    if (cardio.isNotEmpty) {
      final daysNoCardio = today.difference(dateOnly(cardio.first.performedAt)).inDays;
      if (daysNoCardio >= 6) {
        insights.add(Insight(
          category: InsightCategory.cardio,
          type: InsightType.alert,
          priority: InsightPriority.medium,
          title: 'Cardio parado',
          message: 'Você está há $daysNoCardio dias sem cardio.',
          reason: 'Um pouco de cardio ajuda na recuperação e no condicionamento.',
          createdAt: now,
        ));
      }
    }

    // ---- Nutrição (hoje) ----
    final goal = _nutrition.goal();
    final todayMacros = _nutrition
        .mealsForDay(now)
        .fold(MacroNutrients.zero, (s, m) => s + m.macros);
    if (now.hour >= 15 &&
        goal.protein != null &&
        todayMacros.protein < goal.protein! * 0.6) {
      final missing = (goal.protein! - todayMacros.protein).round();
      insights.add(Insight(
        category: InsightCategory.nutrition,
        type: InsightType.alert,
        priority: InsightPriority.medium,
        title: 'Proteína abaixo da meta',
        message: 'Faltam ${missing}g de proteína para sua meta de hoje.',
        reason: 'Proteína suficiente sustenta o ganho muscular.',
        createdAt: now,
      ));
    }
    final water = _nutrition.waterForDayMl(now);
    if (now.hour >= 15 &&
        goal.waterMl != null &&
        water < goal.waterMl! * 0.4) {
      insights.add(Insight(
        category: InsightCategory.nutrition,
        type: InsightType.alert,
        priority: InsightPriority.low,
        title: 'Pouca água hoje',
        message: 'Você bebeu ${water}ml de ${goal.waterMl}ml.',
        reason: 'Hidratação afeta desempenho e recuperação.',
        createdAt: now,
      ));
    }

    // ---- Peso estável ----
    final weights = _body.weightHistory();
    if (weights.length >= 2) {
      final latest = weights.first;
      final oldest = weights.last;
      final spanDays = latest.recordedAt.difference(oldest.recordedAt).inDays;
      if (spanDays >= 21 && (latest.weight - oldest.weight).abs() < 0.6) {
        insights.add(Insight(
          category: InsightCategory.evolution,
          type: InsightType.insight,
          priority: InsightPriority.low,
          title: 'Peso estável',
          message: 'Seu peso está estável há $spanDays dias.',
          reason: 'Estabilidade pode ser boa ou não — depende do seu objetivo.',
          createdAt: now,
        ));
      }
    }

    // ---- Fallback positivo ----
    if (insights.isEmpty) {
      insights.add(Insight(
        category: InsightCategory.consistency,
        type: InsightType.insight,
        priority: InsightPriority.low,
        title: 'Vamos evoluir?',
        message: sessions.isEmpty
            ? 'Registre seu primeiro treino para o VIS começar a te acompanhar.'
            : 'Continue registrando — quanto mais dados, melhores os insights.',
        createdAt: now,
      ));
    }

    insights.sort((a, b) => b.priorityWeight.compareTo(a.priorityWeight));

    return InsightBundle(
      insights: insights,
      weekly: _weekly(sessions, startOfWeek, today),
    );
  }

  DateTime _sessionDate(WorkoutSession s) =>
      dateOnly(s.finishedAt ?? s.startedAt);

  int _streak(List<WorkoutSession> sessions, DateTime today) {
    if (sessions.isEmpty) return 0;
    final set = sessions.map(_sessionDate).toSet();
    var cursor = today;
    if (!set.contains(today)) {
      final y = today.subtract(const Duration(days: 1));
      if (set.contains(y)) {
        cursor = y;
      } else {
        return 0;
      }
    }
    var count = 0;
    while (set.contains(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  double _volumeBetween(List<WorkoutSession> sessions, DateTime from, DateTime to) {
    return sessions
        .where((s) {
          final d = _sessionDate(s);
          return !d.isBefore(from) && d.isBefore(to);
        })
        .fold(0.0, (sum, s) => sum + s.totalVolume);
  }

  WeeklySummary _weekly(
    List<WorkoutSession> sessions,
    DateTime startOfWeek,
    DateTime today,
  ) {
    final week =
        sessions.where((s) => !_sessionDate(s).isBefore(startOfWeek)).toList();
    final cardioWeek = _cardio.statsSince(startOfWeek);
    final highlights = <String>[];
    final attention = <String>[];

    var minutes = 0;
    var volume = 0.0;
    final muscles = <String>{};
    for (final s in week) {
      minutes += (s.elapsedSeconds / 60).round();
      volume += s.totalVolume;
      muscles.addAll(s.muscleGroups);
    }
    if (week.isNotEmpty) {
      highlights.add('${week.length} treino(s) e ${volume.toStringAsFixed(0)} kg movimentados.');
    }
    if (cardioWeek.sessions == 0) {
      attention.add('Nenhum cardio nesta semana.');
    }

    return WeeklySummary(
      workouts: week.length,
      totalMinutes: minutes,
      totalVolume: volume,
      cardioSessions: cardioWeek.sessions,
      cardioMinutes: cardioWeek.totalMinutes,
      highlights: highlights,
      attentionPoints: attention,
    );
  }
}
