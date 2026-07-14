import '../../body_progress/repositories/body_progress_repository.dart';
import '../../cardio/repositories/cardio_repository.dart';
import '../../workout_session/models/workout_session.dart';
import '../../workout_session/repositories/workout_session_repository.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/analytics_enums.dart';
import '../models/analytics_report.dart';

/// Motor de estatísticas (PROMPT 16).
///
/// Consolida dados já registrados (treino, cardio, peso) em relatórios por
/// período. Determinístico e sem efeitos colaterais — `now` é injetável
/// para testes. Cardio e peso são opcionais: o relatório funciona só com
/// as sessões de treino.
final class AnalyticsService {
  AnalyticsService({
    required WorkoutSessionRepository sessionRepository,
    CardioRepository? cardioRepository,
    BodyProgressRepository? bodyRepository,
    DateTime Function()? now,
  })  : _sessions = sessionRepository,
        _cardio = cardioRepository,
        _body = bodyRepository,
        _now = now ?? DateTime.now;

  final WorkoutSessionRepository _sessions;
  final CardioRepository? _cardio;
  final BodyProgressRepository? _body;
  final DateTime Function() _now;

  DateTime _sessionDate(WorkoutSession s) =>
      dateOnly(s.finishedAt ?? s.startedAt);

  AnalyticsReport buildReport(AnalyticsPeriod period) {
    final today = dateOnly(_now());
    final DateTime? from = period.days == null
        ? null
        : today.subtract(Duration(days: period.days! - 1));

    bool inWindow(DateTime d) => from == null || !d.isBefore(from);

    final sessions = _sessions
        .recentSessions(limit: 1000)
        .where((s) => inWindow(_sessionDate(s)))
        .toList();

    final activeDays = sessions.map(_sessionDate).toSet().length;
    var volume = 0.0;
    var sets = 0;
    var minutes = 0;
    for (final s in sessions) {
      volume += s.totalVolume;
      sets += s.completedSets;
      minutes += (s.elapsedSeconds / 60).round();
    }

    return AnalyticsReport(
      period: period,
      workouts: sessions.length,
      activeDays: activeDays,
      totalVolume: volume,
      totalSets: sets,
      totalMinutes: minutes,
      weeklyFrequency: _weeklyFrequency(sessions, period, today),
      muscleDistribution: _muscleDistribution(sessions, volume),
      personalRecords: _personalRecords(sessions),
      volumeTrend: _volumeTrend(sessions, period, today, from),
      cardio: _cardioSummary(inWindow),
      weight: _weightTrend(inWindow),
    );
  }

  double _weeklyFrequency(
    List<WorkoutSession> sessions,
    AnalyticsPeriod period,
    DateTime today,
  ) {
    if (sessions.isEmpty) return 0;
    var weeks = period.weeks;
    if (weeks == null) {
      // "Tudo": usa o intervalo real entre o primeiro treino e hoje.
      final earliest = sessions.map(_sessionDate).reduce(
            (a, b) => a.isBefore(b) ? a : b,
          );
      final spanDays = today.difference(earliest).inDays + 1;
      weeks = spanDays / 7;
    }
    if (weeks < 1) weeks = 1;
    return sessions.length / weeks;
  }

  List<MuscleDistribution> _muscleDistribution(
    List<WorkoutSession> sessions,
    double totalVolume,
  ) {
    final byMuscle = <String, double>{};
    for (final s in sessions) {
      for (final e in s.exercises) {
        final g = e.exercise.muscleGroup;
        if (g.isEmpty) continue;
        byMuscle[g] = (byMuscle[g] ?? 0) + e.volume;
      }
    }
    final entries = byMuscle.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in entries)
        MuscleDistribution(
          muscle: e.key,
          volume: e.value,
          percent: totalVolume > 0 ? e.value / totalVolume : 0,
        ),
    ];
  }

  /// Recordes por exercício: maior carga concluída (não aquecimento),
  /// melhor volume de série e 1RM estimado (Epley).
  List<PersonalRecord> _personalRecords(List<WorkoutSession> sessions) {
    final best = <String, PersonalRecord>{};
    for (final s in sessions) {
      final date = _sessionDate(s);
      for (final e in s.exercises) {
        for (final set in e.sets) {
          if (!set.completed || set.isWarmup) continue;
          final w = set.weight;
          final r = set.reps;
          if (w == null || w <= 0 || r == null || r <= 0) continue;
          final setVolume = w * r;
          final oneRm = w * (1 + r / 30);
          final current = best[e.exercise.id];
          if (current == null || w > current.maxWeight) {
            best[e.exercise.id] = PersonalRecord(
              exerciseId: e.exercise.id,
              exerciseName: e.exercise.name,
              muscleGroup: e.exercise.muscleGroup,
              maxWeight: w,
              repsAtMaxWeight: r,
              bestSetVolume:
                  current == null ? setVolume : (setVolume > current.bestSetVolume ? setVolume : current.bestSetVolume),
              estimatedOneRm: oneRm,
              achievedAt: date,
            );
          } else if (setVolume > current.bestSetVolume) {
            best[e.exercise.id] = PersonalRecord(
              exerciseId: current.exerciseId,
              exerciseName: current.exerciseName,
              muscleGroup: current.muscleGroup,
              maxWeight: current.maxWeight,
              repsAtMaxWeight: current.repsAtMaxWeight,
              bestSetVolume: setVolume,
              estimatedOneRm: current.estimatedOneRm,
              achievedAt: current.achievedAt,
            );
          }
        }
      }
    }
    final list = best.values.toList()
      ..sort((a, b) => b.estimatedOneRm.compareTo(a.estimatedOneRm));
    return list;
  }

  /// Série temporal de volume, com granularidade adequada ao período.
  List<TrendPoint> _volumeTrend(
    List<WorkoutSession> sessions,
    AnalyticsPeriod period,
    DateTime today,
    DateTime? from,
  ) {
    if (sessions.isEmpty) return const [];

    switch (period) {
      case AnalyticsPeriod.week:
        return _dailyTrend(sessions, today, 7);
      case AnalyticsPeriod.month:
        return _weeklyTrend(sessions, today, 5);
      case AnalyticsPeriod.quarter:
        return _weeklyTrend(sessions, today, 13);
      case AnalyticsPeriod.year:
      case AnalyticsPeriod.all:
        return _monthlyTrend(sessions, today, 12);
    }
  }

  List<TrendPoint> _dailyTrend(
    List<WorkoutSession> sessions,
    DateTime today,
    int days,
  ) {
    const weekdays = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final points = <TrendPoint>[];
    for (var i = days - 1; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final vol = sessions
          .where((s) => _sessionDate(s) == day)
          .fold(0.0, (sum, s) => sum + s.totalVolume);
      points.add(TrendPoint(label: weekdays[day.weekday - 1], value: vol));
    }
    return points;
  }

  List<TrendPoint> _weeklyTrend(
    List<WorkoutSession> sessions,
    DateTime today,
    int weeks,
  ) {
    final points = <TrendPoint>[];
    // Semana termina hoje; blocos de 7 dias para trás.
    for (var i = weeks - 1; i >= 0; i--) {
      final end = today.subtract(Duration(days: i * 7));
      final start = end.subtract(const Duration(days: 6));
      final vol = sessions.where((s) {
        final d = _sessionDate(s);
        return !d.isBefore(start) && !d.isAfter(end);
      }).fold(0.0, (sum, s) => sum + s.totalVolume);
      points.add(TrendPoint(label: 'S${weeks - i}', value: vol));
    }
    return points;
  }

  List<TrendPoint> _monthlyTrend(
    List<WorkoutSession> sessions,
    DateTime today,
    int months,
  ) {
    const names = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    final points = <TrendPoint>[];
    for (var i = months - 1; i >= 0; i--) {
      final month = DateTime(today.year, today.month - i, 1);
      final vol = sessions.where((s) {
        final d = _sessionDate(s);
        return d.year == month.year && d.month == month.month;
      }).fold(0.0, (sum, s) => sum + s.totalVolume);
      points.add(TrendPoint(label: names[month.month - 1], value: vol));
    }
    return points;
  }

  CardioSummary _cardioSummary(bool Function(DateTime) inWindow) {
    final cardio = _cardio;
    if (cardio == null) return const CardioSummary();
    final list = cardio
        .history()
        .where((c) => inWindow(dateOnly(c.performedAt)))
        .toList();
    if (list.isEmpty) return const CardioSummary();
    var minutes = 0;
    var distance = 0.0;
    var calories = 0.0;
    for (final c in list) {
      minutes += c.minutes;
      distance += c.distanceKm ?? 0;
      calories += c.calories ?? 0;
    }
    return CardioSummary(
      sessions: list.length,
      minutes: minutes,
      distanceKm: distance,
      calories: calories,
    );
  }

  WeightTrend _weightTrend(bool Function(DateTime) inWindow) {
    final body = _body;
    if (body == null) return const WeightTrend();
    // weightHistory() é ordenado do mais recente para o mais antigo.
    final inRange = body
        .weightHistory()
        .where((w) => inWindow(dateOnly(w.recordedAt)))
        .toList();
    if (inRange.isEmpty) return const WeightTrend();
    final end = inRange.first.weight; // mais recente
    final start = inRange.last.weight; // mais antigo do período
    return WeightTrend(start: start, end: end, records: inRange.length);
  }
}
