import '../../../core/utils/date_utils.dart';
import '../domain/nutrition_goal_status.dart';
import '../models/macro_nutrients.dart';
import '../models/nutrition_period_report.dart';
import '../repositories/nutrition_repository.dart';

/// Calcula os relatórios semanal e mensal de nutrição (PROMPT 10 —
/// Relatórios).
///
/// Apenas soma, tira média e compara com as metas já configuradas pelo
/// usuário — não interpreta, não recomenda e não usa IA. Toda a fonte de
/// dados é o [NutritionRepository] (refeições e água já registrados).
final class NutritionReportService {
  NutritionReportService({
    required NutritionRepository repository,
    DateTime Function()? now,
  })  : _repo = repository,
        _now = now ?? DateTime.now;

  final NutritionRepository _repo;
  final DateTime Function() _now;

  /// Margem em torno da meta considerada "dentro da meta" (10% para
  /// cima ou para baixo).
  static const double _tolerance = 0.10;

  /// Semana corrente (segunda a domingo, contendo [reference] ou hoje).
  NutritionPeriodReport weekReport({DateTime? reference}) {
    final ref = dateOnly(reference ?? _now());
    final start = ref.subtract(Duration(days: ref.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return _build(start: start, end: end);
  }

  /// Mês corrente (dia 1 ao último dia do mês de [reference] ou hoje).
  NutritionPeriodReport monthReport({DateTime? reference}) {
    final ref = reference ?? _now();
    final start = DateTime(ref.year, ref.month, 1);
    final end = DateTime(ref.year, ref.month + 1, 0);
    return _build(start: start, end: end);
  }

  NutritionPeriodReport _build({required DateTime start, required DateTime end}) {
    final today = dateOnly(_now());
    final effectiveEnd = end.isAfter(today) ? today : end;

    final meals = _repo.mealsForRange(start, end);
    final totalWaterMl = _repo.waterForRangeMl(start, end);
    final goal = _repo.goal();

    final daysWithMeals = meals.map((m) => dateOnly(m.consumedAt)).toSet();
    final daysWithRecords = daysWithMeals.length;

    final totalDaysInPeriod =
        effectiveEnd.isBefore(start) ? 0 : effectiveEnd.difference(start).inDays + 1;

    var totalMacros = MacroNutrients.zero;
    for (final m in meals) {
      totalMacros = totalMacros + m.macros;
    }
    final avgMacros =
        daysWithRecords == 0 ? MacroNutrients.zero : totalMacros.scale(1 / daysWithRecords);
    final avgWaterMl = daysWithRecords == 0 ? 0 : (totalWaterMl / daysWithRecords).round();

    final metrics = [
      _metric('Calorias', totalMacros.calories, avgMacros.calories, goal.calories, daysWithRecords),
      _metric('Proteína', totalMacros.protein, avgMacros.protein, goal.protein, daysWithRecords),
      _metric('Carboidratos', totalMacros.carbs, avgMacros.carbs, goal.carbs, daysWithRecords),
      _metric('Gorduras', totalMacros.fats, avgMacros.fats, goal.fats, daysWithRecords),
    ];

    final dailyTrend = <NutritionDailyPoint>[];
    if (!effectiveEnd.isBefore(start)) {
      for (var d = start; !d.isAfter(effectiveEnd); d = d.add(const Duration(days: 1))) {
        final dayCalories = meals
            .where((m) => dateOnly(m.consumedAt) == d)
            .fold(0.0, (sum, m) => sum + m.macros.calories);
        dailyTrend.add(NutritionDailyPoint(date: d, calories: dayCalories));
      }
    }

    return NutritionPeriodReport(
      start: start,
      end: end,
      daysWithRecords: daysWithRecords,
      totalDaysInPeriod: totalDaysInPeriod < 0 ? 0 : totalDaysInPeriod,
      mealsCount: meals.length,
      totalMacros: totalMacros,
      avgMacros: avgMacros,
      totalWaterMl: totalWaterMl,
      avgWaterMl: avgWaterMl,
      metrics: metrics,
      dailyTrend: dailyTrend,
    );
  }

  NutritionMetricSummary _metric(
    String label,
    double total,
    double average,
    double? goalValue,
    int daysWithRecords,
  ) {
    NutritionGoalStatus? status;
    if (goalValue != null && goalValue > 0 && daysWithRecords > 0) {
      final ratio = average / goalValue;
      if (ratio < 1 - _tolerance) {
        status = NutritionGoalStatus.below;
      } else if (ratio > 1 + _tolerance) {
        status = NutritionGoalStatus.above;
      } else {
        status = NutritionGoalStatus.onTarget;
      }
    }
    return NutritionMetricSummary(
      label: label,
      total: total,
      average: average,
      goal: goalValue,
      status: status,
    );
  }
}
