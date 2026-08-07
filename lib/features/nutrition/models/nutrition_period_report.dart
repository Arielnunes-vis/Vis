import '../domain/nutrition_goal_status.dart';
import 'macro_nutrients.dart';

/// Resumo de uma métrica (calorias, proteína, carboidrato ou gordura) num
/// período — total, média por dia registrado e status frente à meta.
class NutritionMetricSummary {
  const NutritionMetricSummary({
    required this.label,
    required this.total,
    required this.average,
    required this.goal,
    this.status,
  });

  final String label;
  final double total;

  /// Média por dia com pelo menos uma refeição registrada no período.
  final double average;

  /// Meta diária configurada pelo usuário, se houver.
  final double? goal;

  /// `null` quando não há meta configurada para esta métrica ou não há
  /// dados suficientes no período para comparar.
  final NutritionGoalStatus? status;
}

/// Total de calorias consumidas em um dia do período — usado para o
/// gráfico simples de evolução.
class NutritionDailyPoint {
  const NutritionDailyPoint({required this.date, required this.calories});

  final DateTime date;
  final double calories;
}

/// Relatório nutricional agregado de um período (semana ou mês).
///
/// Construído inteiramente a partir de refeições e registros de água já
/// lançados pelo usuário — nunca cria ou estima dados (PROMPT 10 —
/// Relatórios). Sem IA.
class NutritionPeriodReport {
  const NutritionPeriodReport({
    required this.start,
    required this.end,
    required this.daysWithRecords,
    required this.totalDaysInPeriod,
    required this.mealsCount,
    required this.totalMacros,
    required this.avgMacros,
    required this.totalWaterMl,
    required this.avgWaterMl,
    required this.metrics,
    required this.dailyTrend,
  });

  final DateTime start;
  final DateTime end;

  /// Quantidade de dias distintos com ao menos uma refeição registrada.
  final int daysWithRecords;

  /// Quantidade de dias já transcorridos dentro do período (não conta
  /// dias futuros de uma semana/mês ainda em andamento).
  final int totalDaysInPeriod;

  final int mealsCount;
  final MacroNutrients totalMacros;

  /// Média por dia registrado (não por dia do período).
  final MacroNutrients avgMacros;

  final int totalWaterMl;
  final int avgWaterMl;

  /// Calorias, proteína, carboidrato e gordura — nesta ordem.
  final List<NutritionMetricSummary> metrics;

  /// Um ponto por dia do período (calorias do dia), para o gráfico.
  final List<NutritionDailyPoint> dailyTrend;

  bool get isEmpty => daysWithRecords == 0;
}
