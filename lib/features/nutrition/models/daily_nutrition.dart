import 'macro_nutrients.dart';
import 'meal.dart';

/// Resumo nutricional de um dia (PROMPT 10).
class DailyNutrition {
  const DailyNutrition({
    required this.date,
    this.meals = const [],
    this.waterMl = 0,
  });

  final DateTime date;
  final List<Meal> meals;
  final int waterMl;

  MacroNutrients get macros =>
      meals.fold(MacroNutrients.zero, (sum, m) => sum + m.macros);

  bool get isEmpty => meals.isEmpty && waterMl == 0;
}
