/// Enums do gerador inteligente de treinos (PROMPT 12).

/// Objetivo do treino solicitado.
enum WorkoutGoal {
  hypertrophy('Hipertrofia'),
  weightLoss('Emagrecimento'),
  strength('Força'),
  endurance('Resistência'),
  conditioning('Condicionamento'),
  health('Saúde'),
  custom('Personalizado');

  const WorkoutGoal(this.label);
  final String label;

  static WorkoutGoal fromName(String? name) => WorkoutGoal.values.firstWhere(
        (g) => g.name == name,
        orElse: () => WorkoutGoal.hypertrophy,
      );
}

/// Divisão do treino sugerida/gerada.
enum WorkoutSplit {
  fullBody('Full Body'),
  upperLower('Upper / Lower'),
  abc('ABC'),
  abcd('ABCD'),
  abcde('ABCDE'),
  pushPullLegs('Push Pull Legs'),
  custom('Personalizado');

  const WorkoutSplit(this.label);
  final String label;

  static WorkoutSplit fromName(String? name) => WorkoutSplit.values.firstWhere(
        (s) => s.name == name,
        orElse: () => WorkoutSplit.custom,
      );
}

/// Local de treino.
enum WorkoutLocation {
  gym('Academia'),
  home('Casa'),
  custom('Personalizado');

  const WorkoutLocation(this.label);
  final String label;
}

/// Nível de experiência.
enum WorkoutExperience {
  beginner('Iniciante'),
  intermediate('Intermediário'),
  advanced('Avançado');

  const WorkoutExperience(this.label);
  final String label;
}

/// Avaliação do treino gerado (feedback).
enum GenerationRating {
  veryEasy('Muito fácil'),
  easy('Fácil'),
  ideal('Ideal'),
  hard('Difícil'),
  veryHard('Muito difícil');

  const GenerationRating(this.label);
  final String label;
}
