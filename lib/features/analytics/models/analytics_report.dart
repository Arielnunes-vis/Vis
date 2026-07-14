import '../domain/analytics_enums.dart';

/// Recorde pessoal de um exercício no período analisado (PROMPT 16).
///
/// O 1RM estimado usa a fórmula de Epley (peso × (1 + reps/30)) — apenas
/// referência, nunca prescrição.
class PersonalRecord {
  const PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.maxWeight,
    required this.repsAtMaxWeight,
    required this.bestSetVolume,
    required this.estimatedOneRm,
    required this.achievedAt,
  });

  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final double maxWeight;
  final int repsAtMaxWeight;
  final double bestSetVolume;
  final double estimatedOneRm;
  final DateTime achievedAt;
}

/// Distribuição de volume por grupo muscular no período.
class MuscleDistribution {
  const MuscleDistribution({
    required this.muscle,
    required this.volume,
    required this.percent,
  });

  final String muscle;
  final double volume;

  /// Fração de 0..1 do volume total do período.
  final double percent;
}

/// Ponto de uma série temporal agregada (para gráficos de tendência).
class TrendPoint {
  const TrendPoint({required this.label, required this.value});

  /// Rótulo do balde (ex.: "Sem 1", "Jan").
  final String label;
  final double value;
}

/// Resumo de cardio dentro do período.
class CardioSummary {
  const CardioSummary({
    this.sessions = 0,
    this.minutes = 0,
    this.distanceKm = 0,
    this.calories = 0,
  });

  final int sessions;
  final int minutes;
  final double distanceKm;
  final double calories;

  bool get isEmpty => sessions == 0;
}

/// Variação de peso no período.
class WeightTrend {
  const WeightTrend({this.start, this.end, this.records = 0});

  final double? start;
  final double? end;
  final int records;

  double? get delta => (start == null || end == null) ? null : end! - start!;
  bool get hasData => start != null && end != null;
}

/// Relatório consolidado de estatísticas (PROMPT 16).
///
/// Agrega dados já registrados (treino, cardio, peso) num único objeto
/// imutável — nunca cria dados, apenas interpreta o histórico (Regra 006).
class AnalyticsReport {
  const AnalyticsReport({
    required this.period,
    this.workouts = 0,
    this.activeDays = 0,
    this.totalVolume = 0,
    this.totalSets = 0,
    this.totalMinutes = 0,
    this.weeklyFrequency = 0,
    this.muscleDistribution = const [],
    this.personalRecords = const [],
    this.volumeTrend = const [],
    this.cardio = const CardioSummary(),
    this.weight = const WeightTrend(),
  });

  final AnalyticsPeriod period;
  final int workouts;
  final int activeDays;
  final double totalVolume;
  final int totalSets;
  final int totalMinutes;

  /// Média de treinos por semana no período.
  final double weeklyFrequency;

  final List<MuscleDistribution> muscleDistribution;
  final List<PersonalRecord> personalRecords;
  final List<TrendPoint> volumeTrend;
  final CardioSummary cardio;
  final WeightTrend weight;

  double get avgSessionMinutes =>
      workouts == 0 ? 0 : totalMinutes / workouts;

  double get avgSessionVolume =>
      workouts == 0 ? 0 : totalVolume / workouts;

  bool get isEmpty =>
      workouts == 0 && cardio.isEmpty && !weight.hasData;
}
