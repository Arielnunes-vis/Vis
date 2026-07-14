/// Enums do módulo de nutrição (PROMPT 10).

/// Tipo de refeição.
enum MealType {
  breakfast('Café da manhã'),
  morningSnack('Lanche da manhã'),
  lunch('Almoço'),
  afternoonSnack('Lanche da tarde'),
  dinner('Jantar'),
  supper('Ceia'),
  free('Livre');

  const MealType(this.label);
  final String label;

  static MealType fromName(String? n) =>
      MealType.values.firstWhere((t) => t.name == n, orElse: () => MealType.free);
}

/// Unidade de medida de um alimento.
enum MeasureUnit {
  grams('g'),
  milliliters('ml'),
  unit('un'),
  portion('porção');

  const MeasureUnit(this.label);
  final String label;

  static MeasureUnit fromName(String? n) => MeasureUnit.values
      .firstWhere((u) => u.name == n, orElse: () => MeasureUnit.grams);
}

/// Recipiente de água para registro rápido.
enum WaterContainer {
  cup(200, 'Copo (200ml)'),
  glass(300, 'Copo grande (300ml)'),
  bottle(500, 'Garrafa (500ml)'),
  large(750, 'Garrafa (750ml)');

  const WaterContainer(this.ml, this.label);
  final int ml;
  final String label;
}
