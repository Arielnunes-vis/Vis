/// Enums e vocabulários do catálogo de exercícios (PROMPT 05 /
/// 08_EXERCISE_LIBRARY.md).

/// Categoria (padrão de esforço) do exercício.
enum ExerciseCategory {
  push('Empurrar'),
  pull('Puxar'),
  squat('Agachar'),
  hinge('Levantar'),
  carry('Carregar'),
  rotation('Rotacionar'),
  stabilize('Estabilizar'),
  stretch('Alongar'),
  mobilize('Mobilizar');

  const ExerciseCategory(this.label);
  final String label;

  static ExerciseCategory fromName(String? n) => ExerciseCategory.values
      .firstWhere((c) => c.name == n, orElse: () => ExerciseCategory.push);
}

/// Tipo do exercício.
enum ExerciseType {
  compound('Composto'),
  isolation('Isolado'),
  unilateral('Unilateral'),
  bilateral('Bilateral'),
  explosive('Explosivo'),
  isometric('Isométrico'),
  plyometric('Pliométrico'),
  cardio('Cardio'),
  mobility('Mobilidade'),
  stretch('Alongamento');

  const ExerciseType(this.label);
  final String label;

  static ExerciseType fromName(String? n) => ExerciseType.values
      .firstWhere((t) => t.name == n, orElse: () => ExerciseType.compound);
}

/// Nível de dificuldade.
enum ExerciseDifficulty {
  beginner('Iniciante'),
  intermediate('Intermediário'),
  advanced('Avançado');

  const ExerciseDifficulty(this.label);
  final String label;

  static ExerciseDifficulty fromName(String? n) => ExerciseDifficulty.values
      .firstWhere((d) => d.name == n, orElse: () => ExerciseDifficulty.beginner);
}

/// Plano de movimento.
enum MovementPlane {
  horizontal('Horizontal'),
  vertical('Vertical'),
  diagonal('Diagonal'),
  rotational('Rotacional'),
  antiRotational('Anti-Rotacional');

  const MovementPlane(this.label);
  final String label;

  static MovementPlane fromName(String? n) => MovementPlane.values
      .firstWhere((p) => p.name == n, orElse: () => MovementPlane.horizontal);
}

/// Padrão de movimento (locomotor).
enum MovementPattern {
  squat('Squat'),
  hinge('Hip Hinge'),
  lunge('Lunge'),
  push('Push'),
  pull('Pull'),
  carry('Carry'),
  rotation('Rotation'),
  coreStability('Core Stability'),
  locomotion('Locomoção');

  const MovementPattern(this.label);
  final String label;

  static MovementPattern fromName(String? n) => MovementPattern.values
      .firstWhere((p) => p.name == n, orElse: () => MovementPattern.push);
}

/// Grupos musculares canônicos (08_EXERCISE_LIBRARY.md) — usados em
/// filtros e classificação.
abstract final class Muscles {
  const Muscles._();
  static const chest = 'Peitoral';
  static const back = 'Costas';
  static const lats = 'Latíssimo';
  static const traps = 'Trapézio';
  static const frontDelts = 'Deltoide anterior';
  static const sideDelts = 'Deltoide lateral';
  static const rearDelts = 'Deltoide posterior';
  static const biceps = 'Bíceps';
  static const triceps = 'Tríceps';
  static const forearms = 'Antebraços';
  static const abs = 'Abdômen';
  static const obliques = 'Oblíquos';
  static const lowerBack = 'Lombar';
  static const glutes = 'Glúteos';
  static const quads = 'Quadríceps';
  static const hamstrings = 'Posterior de coxa';
  static const calves = 'Panturrilhas';

  static const List<String> all = [
    chest, back, lats, traps, frontDelts, sideDelts, rearDelts, biceps,
    triceps, forearms, abs, obliques, lowerBack, glutes, quads, hamstrings,
    calves,
  ];
}

/// Equipamentos (08_EXERCISE_LIBRARY.md).
abstract final class Equipments {
  const Equipments._();
  static const machine = 'Máquina';
  static const dumbbell = 'Halter';
  static const barbell = 'Barra';
  static const smith = 'Smith';
  static const cable = 'Cabo';
  static const bench = 'Banco';
  static const bodyweight = 'Peso corporal';
  static const kettlebell = 'Kettlebell';
  static const trx = 'TRX';
  static const band = 'Elástico';

  static const List<String> all = [
    machine, dumbbell, barbell, smith, cable, bench, bodyweight, kettlebell,
    trx, band,
  ];
}
