/// Enums do módulo de evolução corporal (PROMPT 08).

/// Circunferências corporais (03_DATABASE.md / body_measurements).
enum MeasurementField {
  neck('Pescoço'),
  shoulders('Ombros'),
  chest('Peitoral'),
  rightArm('Braço Direito'),
  leftArm('Braço Esquerdo'),
  rightForearm('Antebraço Direito'),
  leftForearm('Antebraço Esquerdo'),
  waist('Cintura'),
  abdomen('Abdômen'),
  hips('Quadril'),
  glutes('Glúteos'),
  rightThigh('Coxa Direita'),
  leftThigh('Coxa Esquerda'),
  rightCalf('Panturrilha Direita'),
  leftCalf('Panturrilha Esquerda');

  const MeasurementField(this.label);
  final String label;

  static MeasurementField fromName(String n) =>
      MeasurementField.values.firstWhere((f) => f.name == n,
          orElse: () => MeasurementField.chest);
}

/// Tipos de foto de progresso (03_DATABASE.md / progress_photos).
enum PhotoType {
  frontRelaxed('Frente Relaxado'),
  frontFlexed('Frente Contraído'),
  sideRight('Lado Direito'),
  sideLeft('Lado Esquerdo'),
  backRelaxed('Costas Relaxado'),
  backFlexed('Costas Contraído'),
  free('Livre');

  const PhotoType(this.label);
  final String label;

  static PhotoType fromName(String? n) => PhotoType.values
      .firstWhere((t) => t.name == n, orElse: () => PhotoType.free);
}

/// Origem do registro de peso.
enum WeightSource {
  manual('Manual'),
  smartScale('Balança inteligente');

  const WeightSource(this.label);
  final String label;

  static WeightSource fromName(String? n) => WeightSource.values
      .firstWhere((s) => s.name == n, orElse: () => WeightSource.manual);
}

/// Tipo de meta corporal.
enum GoalType {
  weight('Peso'),
  measurement('Medida'),
  custom('Personalizada');

  const GoalType(this.label);
  final String label;

  static GoalType fromName(String? n) => GoalType.values
      .firstWhere((g) => g.name == n, orElse: () => GoalType.weight);
}
