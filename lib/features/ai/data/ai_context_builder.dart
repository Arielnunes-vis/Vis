import '../../body_progress/repositories/body_progress_repository.dart';
import '../../cardio/repositories/cardio_repository.dart';
import '../../nutrition/models/macro_nutrients.dart';
import '../../nutrition/repositories/nutrition_repository.dart';
import '../../workout/repositories/workout_repository.dart';
import '../../workout_session/repositories/workout_session_repository.dart';
import '../domain/ai_context.dart';

/// Monta o [AIContext] real do usuário a partir de todos os módulos
/// (PROMPT 11 / Regra 026).
///
/// A IA NUNCA responde só com a pergunta: primeiro este builder reúne
/// perfil, treinos, peso, medidas, cardio e nutrição — para então o
/// contexto seguir à Edge Function.
final class AIContextBuilder {
  AIContextBuilder({
    required WorkoutRepository workoutRepository,
    required WorkoutSessionRepository sessionRepository,
    required BodyProgressRepository bodyRepository,
    required CardioRepository cardioRepository,
    required NutritionRepository nutritionRepository,
    DateTime Function()? now,
  })  : _workouts = workoutRepository,
        _sessions = sessionRepository,
        _body = bodyRepository,
        _cardio = cardioRepository,
        _nutrition = nutritionRepository,
        _now = now ?? DateTime.now;

  final WorkoutRepository _workouts;
  final WorkoutSessionRepository _sessions;
  final BodyProgressRepository _body;
  final CardioRepository _cardio;
  final NutritionRepository _nutrition;
  final DateTime Function() _now;

  Future<AIContext> build() async {
    final now = _now();
    final plans = await _workouts.getPlans();
    final active = plans.where((p) => p.isActive).isNotEmpty
        ? plans.firstWhere((p) => p.isActive)
        : (plans.isNotEmpty ? plans.first : null);

    final sessions = _sessions.recentSessions(limit: 10);
    final weights = _body.weightHistory().take(10).toList();
    final measurement = _body.latestMeasurement();
    final cardio = _cardio.history().take(10).toList();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weeklyCardio = _cardio.statsSince(startOfWeek);
    final todayMeals = _nutrition.mealsForDay(now);
    final todayMacros =
        todayMeals.fold(MacroNutrients.zero, (s, m) => s + m.macros);

    return AIContext(
      profile: {
        'latest_weight': weights.isNotEmpty ? weights.first.weight : null,
        'total_workouts': sessions.length,
      },
      goals: {
        'training': active?.goal.name,
        'active_plan': active?.name,
      },
      workouts: [
        for (final s in sessions)
          {
            'day': s.dayName,
            'volume': s.totalVolume,
            'sets': s.completedSets,
            'muscles': s.muscleGroups.toList(),
            'date': (s.finishedAt ?? s.startedAt).toIso8601String(),
          },
      ],
      weightHistory: [
        for (final w in weights)
          {'weight': w.weight, 'date': w.recordedAt.toIso8601String()},
      ],
      measurements: measurement == null
          ? const []
          : [
              {
                'date': measurement.recordedAt.toIso8601String(),
                'values': measurement.values,
              },
            ],
      cardio: [
        for (final c in cardio)
          {
            'type': c.type.name,
            'minutes': c.minutes,
            'distance': c.distanceKm,
            'date': c.performedAt.toIso8601String(),
          },
      ],
      preferences: {
        'weekly_cardio_minutes': weeklyCardio.totalMinutes,
        'today_calories': todayMacros.calories,
        'today_protein': todayMacros.protein,
        'today_water_ml': _nutrition.waterForDayMl(now),
      },
    );
  }
}
