/// Enums do módulo de execução de treino (PROMPT 06).

/// Humor do usuário (antes/depois do treino).
enum WorkoutMood {
  veryBad('Muito ruim'),
  bad('Ruim'),
  normal('Normal'),
  good('Bom'),
  excellent('Excelente');

  const WorkoutMood(this.label);
  final String label;

  static WorkoutMood? fromName(String? n) => n == null
      ? null
      : WorkoutMood.values.firstWhere((m) => m.name == n,
          orElse: () => WorkoutMood.normal);
}

/// Estado da sessão.
enum SessionStatus { active, paused, finished }

/// Tipo de recorde pessoal batido na sessão.
enum PRKind {
  maxWeight('Maior carga'),
  maxVolume('Maior volume'),
  maxReps('Mais repetições');

  const PRKind(this.label);
  final String label;
}
