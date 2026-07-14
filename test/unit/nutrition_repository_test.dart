import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/nutrition/data/nutrition_repository_impl.dart';
import 'package:vis/features/nutrition/domain/nutrition_enums.dart';
import 'package:vis/features/nutrition/domain/nutrition_local_store.dart';
import 'package:vis/features/nutrition/models/food_item.dart';
import 'package:vis/features/nutrition/models/macro_nutrients.dart';
import 'package:vis/features/nutrition/models/meal.dart';
import 'package:vis/features/nutrition/models/nutrition_goal.dart';
import 'package:vis/features/nutrition/models/water_intake.dart';

class InMemStore implements NutritionLocalStore {
  final Map<String, List<Map<String, dynamic>>> lists = {};
  final Map<String, Map<String, dynamic>> maps = {};

  @override
  List<Map<String, dynamic>> readList(String userId, String collection) =>
      lists['$userId/$collection'] ?? const [];
  @override
  Future<void> writeList(
    String userId,
    String collection,
    List<Map<String, dynamic>> items,
  ) async =>
      lists['$userId/$collection'] = items;
  @override
  Map<String, dynamic>? readMap(String userId, String key) =>
      maps['$userId/$key'];
  @override
  Future<void> writeMap(
    String userId,
    String key,
    Map<String, dynamic> value,
  ) async =>
      maps['$userId/$key'] = value;
}

void main() {
  late NutritionRepositoryImpl repo;

  setUp(() {
    repo = NutritionRepositoryImpl(
      store: InMemStore(),
      currentUserId: () => 'u1',
    );
  });

  test('macros somam corretamente', () {
    const a = MacroNutrients(protein: 10, calories: 100);
    const b = MacroNutrients(protein: 5, calories: 50);
    expect((a + b).protein, 15);
    expect((a + b).calories, 150);
  });

  test('registra refeição do dia e agrega macros', () async {
    final now = DateTime.now();
    await repo.addMeal(Meal(
      id: 'm1',
      userId: 'u1',
      type: MealType.lunch,
      consumedAt: now,
      items: [
        FoodItem(
          id: 'f1',
          name: 'Frango',
          quantity: 150,
          unit: MeasureUnit.grams,
          macros: const MacroNutrients(calories: 250, protein: 45),
        ),
      ],
    ));

    final today = repo.mealsForDay(now);
    expect(today.length, 1);
    expect(today.first.macros.protein, 45);
  });

  test('registra água do dia', () async {
    final now = DateTime.now();
    await repo.addWater(
        WaterIntake(id: 'w1', userId: 'u1', amountMl: 500, at: now));
    await repo.addWater(
        WaterIntake(id: 'w2', userId: 'u1', amountMl: 300, at: now));
    expect(repo.waterForDayMl(now), 800);
  });

  test('meta retorna padrões quando não definida', () {
    expect(repo.goal().calories, NutritionGoal.defaults.calories);
  });
}
