/// Macronutrientes de um alimento/refeição/dia (PROMPT 10).
class MacroNutrients {
  const MacroNutrients({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    this.fiber = 0,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;

  MacroNutrients operator +(MacroNutrients o) => MacroNutrients(
        calories: calories + o.calories,
        protein: protein + o.protein,
        carbs: carbs + o.carbs,
        fats: fats + o.fats,
        fiber: fiber + o.fiber,
      );

  MacroNutrients scale(double factor) => MacroNutrients(
        calories: calories * factor,
        protein: protein * factor,
        carbs: carbs * factor,
        fats: fats * factor,
        fiber: fiber * factor,
      );

  Map<String, dynamic> toMap() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'fiber': fiber,
      };

  factory MacroNutrients.fromMap(Map<String, dynamic> m) => MacroNutrients(
        calories: (m['calories'] as num?)?.toDouble() ?? 0,
        protein: (m['protein'] as num?)?.toDouble() ?? 0,
        carbs: (m['carbs'] as num?)?.toDouble() ?? 0,
        fats: (m['fats'] as num?)?.toDouble() ?? 0,
        fiber: (m['fiber'] as num?)?.toDouble() ?? 0,
      );

  static const zero = MacroNutrients();
}
