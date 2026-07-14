import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/providers/authentication_providers.dart';
import '../domain/nutrition_enums.dart';
import '../models/daily_nutrition.dart';
import '../models/food_item.dart';
import '../models/meal.dart';
import '../models/water_intake.dart';
import '../providers/nutrition_providers.dart';

/// Controller do dia atual de nutrição (PROMPT 10).
class NutritionController extends Notifier<DailyNutrition> {
  final Uuid _uuid = const Uuid();

  @override
  DailyNutrition build() => _today();

  String get _uid =>
      ref.read(authenticationRepositoryProvider).currentUser?.id ?? '';

  DailyNutrition _today() {
    final repo = ref.read(nutritionRepositoryProvider);
    final now = DateTime.now();
    return DailyNutrition(
      date: now,
      meals: repo.mealsForDay(now),
      waterMl: repo.waterForDayMl(now),
    );
  }

  Future<void> addMeal({
    required MealType type,
    required List<FoodItem> items,
    String? note,
  }) async {
    await ref.read(nutritionRepositoryProvider).addMeal(
          Meal(
            id: _uuid.v4(),
            userId: _uid,
            type: type,
            consumedAt: DateTime.now(),
            items: items,
            note: note,
          ),
        );
    state = _today();
  }

  Future<void> addWater(int amountMl) async {
    await ref.read(nutritionRepositoryProvider).addWater(
          WaterIntake(
            id: _uuid.v4(),
            userId: _uid,
            amountMl: amountMl,
            at: DateTime.now(),
          ),
        );
    state = _today();
  }
}
