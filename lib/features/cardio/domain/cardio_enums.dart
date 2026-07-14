/// Enums do módulo de cardio (PROMPT 09).

/// Tipo de atividade cardiovascular. [distanceBased] indica se a
/// distância é relevante (para cálculo de pace/velocidade).
enum CardioType {
  walking('Caminhada', true),
  running('Corrida', true),
  treadmill('Esteira', true),
  bike('Bike', true),
  spinBike('Bicicleta Ergométrica', true),
  stairs('Escada', false),
  elliptical('Elíptico', false),
  rowing('Remo', true),
  swimming('Natação', true),
  jumpRope('Pular Corda', false),
  hiit('HIIT', false),
  other('Outro', false);

  const CardioType(this.label, this.distanceBased);
  final String label;
  final bool distanceBased;

  static CardioType fromName(String? n) => CardioType.values
      .firstWhere((t) => t.name == n, orElse: () => CardioType.other);
}

/// Período de uma meta de cardio.
enum CardioGoalPeriod {
  week('por semana'),
  month('por mês');

  const CardioGoalPeriod(this.label);
  final String label;

  static CardioGoalPeriod fromName(String? n) => CardioGoalPeriod.values
      .firstWhere((p) => p.name == n, orElse: () => CardioGoalPeriod.week);
}

/// Métrica de uma meta de cardio.
enum CardioGoalMetric {
  minutes('Minutos'),
  distanceKm('Distância (km)'),
  sessions('Sessões'),
  calories('Calorias');

  const CardioGoalMetric(this.label);
  final String label;

  static CardioGoalMetric fromName(String? n) => CardioGoalMetric.values
      .firstWhere((m) => m.name == n, orElse: () => CardioGoalMetric.minutes);
}
