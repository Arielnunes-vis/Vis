/// Metas nutricionais diárias (PROMPT 10).
class NutritionGoal {
  const NutritionGoal({
    this.calories,
    this.protein,
    this.carbs,
    this.fats,
    this.fiber,
    this.waterMl,
  });

  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fats;
  final double? fiber;
  final int? waterMl;

  bool get isEmpty =>
      calories == null &&
      protein == null &&
      carbs == null &&
      fats == null &&
      waterMl == null;

  Map<String, dynamic> toMap() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'fiber': fiber,
        'water_ml': waterMl,
      };

  factory NutritionGoal.fromMap(Map<String, dynamic> m) => NutritionGoal(
        calories: (m['calories'] as num?)?.toDouble(),
        protein: (m['protein'] as num?)?.toDouble(),
        carbs: (m['carbs'] as num?)?.toDouble(),
        fats: (m['fats'] as num?)?.toDouble(),
        fiber: (m['fiber'] as num?)?.toDouble(),
        waterMl: (m['water_ml'] as num?)?.toInt(),
      );

  /// Metas padrão razoáveis (usadas até o usuário definir as suas).
  static const defaults = NutritionGoal(
    calories: 2200,
    protein: 140,
    carbs: 250,
    fats: 70,
    waterMl: 2500,
  );
}
