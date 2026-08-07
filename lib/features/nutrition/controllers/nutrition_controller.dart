import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/date_utils.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../domain/nutrition_enums.dart';
import '../models/daily_nutrition.dart';
import '../models/food_item.dart';
import '../models/meal.dart';
import '../models/water_intake.dart';
import '../providers/nutrition_providers.dart';

/// Controller do dia de nutrição exibido na aba "Hoje" (PROMPT 10).
///
/// Além do dia atual, permite navegar para dias anteriores (nunca
/// futuros) para consultar ou completar registros esquecidos — os dados
/// são somados automaticamente nos relatórios semanal/mensal.
class NutritionController extends Notifier<DailyNutrition> {
  final Uuid _uuid = const Uuid();

  @override
  DailyNutrition build() => _loadDay(_today());

  String get _uid =>
      ref.read(authenticationRepositoryProvider).currentUser?.id ?? '';

  DateTime _today() => dateOnly(DateTime.now());

  /// `true` quando o dia exibido é hoje.
  bool get isToday => dateOnly(state.date) == _today();

  DailyNutrition _loadDay(DateTime day) {
    final repo = ref.read(nutritionRepositoryProvider);
    return DailyNutrition(
      date: day,
      meals: repo.mealsForDay(day),
      waterMl: repo.waterForDayMl(day),
    );
  }

  /// Vai para [date]. Datas futuras são limitadas a hoje.
  void selectDate(DateTime date) {
    final target = dateOnly(date);
    final today = _today();
    state = _loadDay(target.isAfter(today) ? today : target);
  }

  void goToPreviousDay() =>
      selectDate(dateOnly(state.date).subtract(const Duration(days: 1)));

  void goToNextDay() {
    if (isToday) return;
    selectDate(dateOnly(state.date).add(const Duration(days: 1)));
  }

  void goToToday() => selectDate(_today());

  /// Junta a data (ano/mês/dia) de [date] com o horário atual, para que
  /// refeições lançadas num dia passado fiquem ordenadas pela hora do
  /// lançamento (não existe hora "real" para registros retroativos).
  DateTime _combineWithNowTime(DateTime date) {
    final now = DateTime.now();
    return DateTime(date.year, date.month, date.day, now.hour, now.minute, now.second);
  }

  /// Registra uma refeição. Por padrão usa o dia em exibição (`state.date`)
  /// — passe [date] para registrar num dia específico (nunca futuro).
  Future<void> addMeal({
    required MealType type,
    required List<FoodItem> items,
    String? note,
    DateTime? date,
  }) async {
    final today = _today();
    var targetDate = dateOnly(date ?? state.date);
    if (targetDate.isAfter(today)) targetDate = today;

    await ref.read(nutritionRepositoryProvider).addMeal(
          Meal(
            id: _uuid.v4(),
            userId: _uid,
            type: type,
            consumedAt: _combineWithNowTime(targetDate),
            items: items,
            note: note,
          ),
        );
    state = _loadDay(targetDate);
  }

  /// Atualiza uma refeição já existente (edição), inclusive trocando a
  /// data — nunca para uma data futura.
  Future<void> updateMeal(Meal meal) async {
    final today = _today();
    var consumedAt = meal.consumedAt;
    if (dateOnly(consumedAt).isAfter(today)) {
      consumedAt = _combineWithNowTime(today);
    }
    final updated = Meal(
      id: meal.id,
      userId: meal.userId,
      type: meal.type,
      consumedAt: consumedAt,
      items: meal.items,
      photoPath: meal.photoPath,
      note: meal.note,
    );
    await ref.read(nutritionRepositoryProvider).updateMeal(updated);
    state = _loadDay(dateOnly(consumedAt));
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
    // A água é sempre registrada "agora"; se o usuário estiver vendo um
    // dia anterior, o total mostrado continua sendo o daquele dia.
    state = _loadDay(state.date);
  }
}
