import '../models/meal.dart';
import '../models/nutrition_goal.dart';
import '../models/water_intake.dart';

/// Contrato do repositório de nutrição (PROMPT 10). Offline-first.
abstract interface class NutritionRepository {
  Future<void> addMeal(Meal meal);

  /// Substitui uma refeição existente (mesmo [Meal.id]), preservando o
  /// restante do histórico. Usado para editar refeições já registradas,
  /// inclusive de dias anteriores.
  Future<void> updateMeal(Meal meal);

  List<Meal> mealsForDay(DateTime day);

  /// Refeições registradas entre [start] e [end] (ambos inclusive,
  /// ignorando a hora). Usado pelos relatórios semanal/mensal.
  List<Meal> mealsForRange(DateTime start, DateTime end);

  List<Meal> recentMeals({int limit});

  Future<void> addWater(WaterIntake water);
  int waterForDayMl(DateTime day);

  /// Soma da água registrada entre [start] e [end] (ambos inclusive,
  /// ignorando a hora).
  int waterForRangeMl(DateTime start, DateTime end);

  Future<void> setGoal(NutritionGoal goal);

  /// Meta salva ou os valores padrão.
  NutritionGoal goal();
}
