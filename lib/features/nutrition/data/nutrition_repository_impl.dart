import '../domain/nutrition_local_store.dart';
import '../models/meal.dart';
import '../models/nutrition_goal.dart';
import '../models/water_intake.dart';
import '../repositories/nutrition_repository.dart';

/// Implementação offline-first do [NutritionRepository].
final class NutritionRepositoryImpl implements NutritionRepository {
  NutritionRepositoryImpl({
    required NutritionLocalStore store,
    required String? Function() currentUserId,
  })  : _store = store,
        _currentUserId = currentUserId;

  final NutritionLocalStore _store;
  final String? Function() _currentUserId;

  String get _uid => _currentUserId() ?? 'local';
  static const _meals = 'meals';
  static const _water = 'water';
  static const _goal = 'goal';

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Meal> _allMeals() {
    final list = _store.readList(_uid, _meals).map(Meal.fromMap).toList()
      ..sort((a, b) => b.consumedAt.compareTo(a.consumedAt));
    return list;
  }

  @override
  Future<void> addMeal(Meal meal) async {
    final list = _store.readList(_uid, _meals)..add(meal.toMap());
    await _store.writeList(_uid, _meals, list);
  }

  @override
  List<Meal> mealsForDay(DateTime day) =>
      _allMeals().where((m) => _sameDay(m.consumedAt, day)).toList();

  @override
  List<Meal> recentMeals({int limit = 20}) => _allMeals().take(limit).toList();

  @override
  Future<void> addWater(WaterIntake water) async {
    final list = _store.readList(_uid, _water)..add(water.toMap());
    await _store.writeList(_uid, _water, list);
  }

  @override
  int waterForDayMl(DateTime day) {
    return _store
        .readList(_uid, _water)
        .map(WaterIntake.fromMap)
        .where((w) => _sameDay(w.at, day))
        .fold(0, (sum, w) => sum + w.amountMl);
  }

  @override
  Future<void> setGoal(NutritionGoal goal) =>
      _store.writeMap(_uid, _goal, goal.toMap());

  @override
  NutritionGoal goal() {
    final map = _store.readMap(_uid, _goal);
    if (map == null) return NutritionGoal.defaults;
    final g = NutritionGoal.fromMap(map);
    return g.isEmpty ? NutritionGoal.defaults : g;
  }
}
