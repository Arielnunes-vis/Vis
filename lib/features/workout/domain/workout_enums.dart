/// Enums do Workout Engine (PROMPT 04).

/// Dias da semana (1=segunda … 7=domingo, alinhado a DateTime.weekday).
enum Weekday {
  monday(1, 'Segunda'),
  tuesday(2, 'Terça'),
  wednesday(3, 'Quarta'),
  thursday(4, 'Quinta'),
  friday(5, 'Sexta'),
  saturday(6, 'Sábado'),
  sunday(7, 'Domingo');

  const Weekday(this.number, this.label);
  final int number;
  final String label;

  static Weekday fromNumber(int n) =>
      Weekday.values.firstWhere((d) => d.number == n, orElse: () => Weekday.monday);
}

/// Tipo/técnica de uma série (PROMPT 04).
enum SetType {
  normal('Normal'),
  warmup('Aquecimento'),
  dropSet('Drop Set'),
  restPause('Rest Pause'),
  superset('Superset'),
  biSet('Bi-set'),
  triSet('Tri-set'),
  cluster('Cluster'),
  forcedReps('Forced Reps'),
  negatives('Negativas'),
  tempo('Tempo Controlado'),
  isometric('Isometria'),
  preExhaustion('Pré-exaustão'),
  postExhaustion('Pós-exaustão'),
  failure('Falha');

  const SetType(this.label);
  final String label;

  static SetType fromName(String? name) =>
      SetType.values.firstWhere((t) => t.name == name, orElse: () => SetType.normal);
}

/// Objetivo do plano de treino.
enum WorkoutGoalType {
  hypertrophy('Hipertrofia'),
  strength('Força'),
  endurance('Resistência'),
  weightLoss('Emagrecimento'),
  conditioning('Condicionamento'),
  health('Saúde'),
  custom('Personalizado');

  const WorkoutGoalType(this.label);
  final String label;

  static WorkoutGoalType fromName(String? name) => WorkoutGoalType.values
      .firstWhere((g) => g.name == name, orElse: () => WorkoutGoalType.hypertrophy);
}
