import '../models/meal.dart';
import '../models/nutrition_goal.dart';
import '../models/water_intake.dart';

/// Contrato do repositório de nutrição (PROMPT 10). Offline-first.
abstract interface class NutritionRepository {
  Future<void> addMeal(Meal meal);
  List<Meal> mealsForDay(DateTime day);
  List<Meal> recentMeals({int limit});

  Future<void> addWater(WaterIntake water);
  int waterForDayMl(DateTime day);

  Future<void> setGoal(NutritionGoal goal);

  /// Meta salva ou os valores padrão.
  NutritionGoal goal();
}
