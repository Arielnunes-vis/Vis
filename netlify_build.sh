#!/usr/bin/env bash
set -euo pipefail

echo "==> Instalando Flutter 3.29.3 (versao fixada, compativel com os pacotes)…"
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.29.3 "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"
git config --global --add safe.directory "$HOME/flutter" || true
flutter --version
flutter config --enable-web

echo "==> Gerando a plataforma web…"
flutter create --platforms web --project-name vis --org com.vis .

echo "==> Aplicando correcoes de compilacao…"
EDITOR_FILE=lib/features/workout/presentation/workout_editor_screen.dart
if ! grep -q "controllers/workout_editor_controller.dart" "$EDITOR_FILE"; then
  sed -i "s|import '../domain/workout_enums.dart';|import '../controllers/workout_editor_controller.dart';\nimport '../domain/workout_enums.dart';|" "$EDITOR_FILE"
fi

NOTIF_FILE=lib/features/notifications/services/local_notification_service.dart
if ! grep -q "uiLocalNotificationDateInterpretation" "$NOTIF_FILE"; then
  sed -i "s|androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,|androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,\n          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,|g" "$NOTIF_FILE"
fi

echo "==> Ajustando env.dart para ler as chaves embutidas…"
ENV_FILE=lib/core/config/env.dart
if ! grep -q "String.fromEnvironment('SUPABASE_URL')" "$ENV_FILE"; then
  sed -i "s|await dotenv.load(fileName: fileName);|try { await dotenv.load(fileName: fileName); } catch (_) {}|" "$ENV_FILE"
  sed -i "s|static String get supabaseUrl => _require('SUPABASE_URL');|static String get supabaseUrl { const v = String.fromEnvironment('SUPABASE_URL'); return v.isNotEmpty ? v : _require('SUPABASE_URL'); }|" "$ENV_FILE"
  sed -i "s|static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');|static String get supabaseAnonKey { const v = String.fromEnvironment('SUPABASE_ANON_KEY'); return v.isNotEmpty ? v : _require('SUPABASE_ANON_KEY'); }|" "$ENV_FILE"
fi

echo "==> Criando .env (fallback local)…"
printf 'SUPABASE_URL=%s\nSUPABASE_ANON_KEY=%s\n' "${SUPABASE_URL:-}" "${SUPABASE_ANON_KEY:-}" > .env

echo "==> Garantindo pastas de assets…"
mkdir -p assets/images assets/icons assets/gifs assets/fonts

echo "==> Escrevendo arquivos ajustados…"
mkdir -p lib/shared/widgets/media lib/shared/widgets/navigation
echo "    - lib/core/theme/app_colors.dart"
cat > lib/core/theme/app_colors.dart <<'DARTEOF_COLORS'
import 'package:flutter/material.dart';

/// Paleta de cores do VIS.
///
/// Fonte de verdade: 07_DESIGN_SYSTEM.md (Dark Mode).
/// O Light Mode está previsto para o futuro, portanto os tokens
/// são expostos de forma semântica para facilitar a expansão.
abstract final class AppColors {
  const AppColors._();

  // ----- Superfícies (Dark) -----
  static const Color background = Color(0xFF0B0B0B);
  static const Color surface = Color(0xFF111111);
  static const Color card = Color(0xFF1A1A1A);
  static const Color elevated = Color(0xFF1C1C1E);

  // ----- Marca -----
  static const Color primary = Color(0xFF3A86FF);
  static const Color secondary = Color(0xFF6C63FF);

  // ----- Acentos por seção (cabeçalhos coloridos) -----
  static const Color accentGreen = Color(0xFF2FBF71);
  static const Color accentOrange = Color(0xFFFF8A3D);
  static const Color accentTeal = Color(0xFF17BEBB);
  static const Color accentPink = Color(0xFFF4468F);

  // ----- Feedback -----
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFFCC00);
  static const Color danger = Color(0xFFFF453A);

  // ----- Texto -----
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color disabled = Color(0xFF707070);

  // ----- Estrutura -----
  static const Color divider = Color(0xFF2A2A2A);

  // ----- Aliases semânticos -----
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = textSecondary;
}
DARTEOF_COLORS

echo "    - lib/features/exercise/domain/exercise_enums.dart"
cat > lib/features/exercise/domain/exercise_enums.dart <<'DARTEOF_ENUMS'
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
  static const abductors = 'Abdutores';
  static const adductors = 'Adutores';

  static const List<String> all = [
    chest, back, lats, traps, frontDelts, sideDelts, rearDelts, biceps,
    triceps, forearms, abs, obliques, lowerBack, glutes, quads, hamstrings,
    calves, abductors, adductors,
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
DARTEOF_ENUMS

echo "    - lib/features/exercise/data/exercise_media.dart"
cat > lib/features/exercise/data/exercise_media.dart <<'DARTEOF_MEDIA'
// GERADO AUTOMATICAMENTE — não editar à mão.
//
// Mídia dos exercícios da Biblioteca. As imagens vêm do
// free-exercise-db (https://github.com/yuhonas/free-exercise-db),
// em DOMÍNIO PÚBLICO (licença Unlicense) — uso livre, inclusive
// comercial. Cada exercício tem 2 quadros (posição inicial e final);
// o app alterna entre eles para simular o movimento
// (ver AnimatedExerciseImage).
abstract final class ExerciseMedia {
  const ExerciseMedia._();

  /// id do exercício -> lista de quadros (URLs das fotos).
  static const Map<String, List<String>> _frames = {
    'bench_press': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Bench_Press_-_Medium_Grip/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Bench_Press_-_Medium_Grip/1.jpg',
    ],
    'incline_db_press': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Incline_Dumbbell_Press/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Incline_Dumbbell_Press/1.jpg',
    ],
    'chest_fly': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Flyes/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Flyes/1.jpg',
    ],
    'lat_pulldown': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Wide-Grip_Lat_Pulldown/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Wide-Grip_Lat_Pulldown/1.jpg',
    ],
    'barbell_row': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Bent_Over_Barbell_Row/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Bent_Over_Barbell_Row/1.jpg',
    ],
    'pull_up': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pullups/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pullups/1.jpg',
    ],
    'overhead_press': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Standing_Military_Press/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Standing_Military_Press/1.jpg',
    ],
    'lateral_raise': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Side_Lateral_Raise/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Side_Lateral_Raise/1.jpg',
    ],
    'biceps_curl': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Curl/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Curl/1.jpg',
    ],
    'triceps_pushdown': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Triceps_Pushdown/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Triceps_Pushdown/1.jpg',
    ],
    'squat': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Squat/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Squat/1.jpg',
    ],
    'leg_press': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Leg_Press/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Leg_Press/1.jpg',
    ],
    'romanian_deadlift': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Romanian_Deadlift/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Romanian_Deadlift/1.jpg',
    ],
    'leg_curl': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Lying_Leg_Curls/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Lying_Leg_Curls/1.jpg',
    ],
    'hip_thrust': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Hip_Thrust/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Hip_Thrust/1.jpg',
    ],
    'calf_raise': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Standing_Calf_Raises/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Standing_Calf_Raises/1.jpg',
    ],
    'plank': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plank/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plank/1.jpg',
    ],
    'push_up': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pushups/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Pushups/1.jpg',
    ],
    'dumbbell_shrug': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Shrug/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Shrug/1.jpg',
    ],
    'upright_row': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Standing_Dumbbell_Upright_Row/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Standing_Dumbbell_Upright_Row/1.jpg',
    ],
    'reverse_fly': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Flyes/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Flyes/1.jpg',
    ],
    'face_pull': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Face_Pull/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Face_Pull/1.jpg',
    ],
    'wrist_curl': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Palms-Up_Barbell_Wrist_Curl_Over_A_Bench/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Palms-Up_Barbell_Wrist_Curl_Over_A_Bench/1.jpg',
    ],
    'reverse_curl': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Barbell_Curl/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Reverse_Barbell_Curl/1.jpg',
    ],
    'side_plank': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Side_Bridge/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Side_Bridge/1.jpg',
    ],
    'russian_twist': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Russian_Twist/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Russian_Twist/1.jpg',
    ],
    'hyperextension': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Hyperextensions_Back_Extensions/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Hyperextensions_Back_Extensions/1.jpg',
    ],
    'good_morning': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Good_Morning/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Good_Morning/1.jpg',
    ],
    'db_bench_press': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Bench_Press/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Bench_Press/1.jpg',
    ],
    'decline_bench': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Decline_Barbell_Bench_Press/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Decline_Barbell_Bench_Press/1.jpg',
    ],
    'cable_crossover': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Cable_Crossover/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Cable_Crossover/1.jpg',
    ],
    'pec_deck': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Butterfly/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Butterfly/1.jpg',
    ],
    'machine_chest_press': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Leverage_Chest_Press/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Leverage_Chest_Press/1.jpg',
    ],
    'chest_dips': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dips_-_Chest_Version/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dips_-_Chest_Version/1.jpg',
    ],
    'one_arm_db_row': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One-Arm_Dumbbell_Row/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/One-Arm_Dumbbell_Row/1.jpg',
    ],
    'seated_cable_row': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Cable_Rows/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Cable_Rows/1.jpg',
    ],
    'tbar_row': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Lying_T-Bar_Row/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Lying_T-Bar_Row/1.jpg',
    ],
    'close_grip_pulldown': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Close-Grip_Front_Lat_Pulldown/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Close-Grip_Front_Lat_Pulldown/1.jpg',
    ],
    'db_pullover': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Bent-Arm_Dumbbell_Pullover/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Bent-Arm_Dumbbell_Pullover/1.jpg',
    ],
    'db_shoulder_press': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Shoulder_Press/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Shoulder_Press/1.jpg',
    ],
    'arnold_press': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Arnold_Dumbbell_Press/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Arnold_Dumbbell_Press/1.jpg',
    ],
    'front_raise': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Front_Dumbbell_Raise/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Front_Dumbbell_Raise/1.jpg',
    ],
    'cable_lateral_raise': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Cable_Seated_Lateral_Raise/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Cable_Seated_Lateral_Raise/1.jpg',
    ],
    'hammer_curl': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Hammer_Curls/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Hammer_Curls/1.jpg',
    ],
    'preacher_curl': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Preacher_Curl/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Preacher_Curl/1.jpg',
    ],
    'concentration_curl': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Concentration_Curls/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Concentration_Curls/1.jpg',
    ],
    'incline_db_curl': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Alternate_Incline_Dumbbell_Curl/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Alternate_Incline_Dumbbell_Curl/1.jpg',
    ],
    'skullcrusher': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Lying_Triceps_Press/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Lying_Triceps_Press/1.jpg',
    ],
    'french_press': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Triceps_Press/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Triceps_Press/1.jpg',
    ],
    'triceps_kickback': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Tricep_Dumbbell_Kickback/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Tricep_Dumbbell_Kickback/1.jpg',
    ],
    'bench_dips': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Bench_Dips/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Bench_Dips/1.jpg',
    ],
    'sumo_squat': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plie_Dumbbell_Squat/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plie_Dumbbell_Squat/1.jpg',
    ],
    'bulgarian_split': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Rear_Lunge/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Rear_Lunge/1.jpg',
    ],
    'lunge': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Lunges/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Lunges/1.jpg',
    ],
    'leg_extension': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Leg_Extensions/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Leg_Extensions/1.jpg',
    ],
    'hack_squat': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Hack_Squat/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Hack_Squat/1.jpg',
    ],
    'front_squat': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Front_Barbell_Squat/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Front_Barbell_Squat/1.jpg',
    ],
    'seated_leg_curl': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Leg_Curl/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Leg_Curl/1.jpg',
    ],
    'stiff_deadlift': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Stiff-Legged_Dumbbell_Deadlift/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Stiff-Legged_Dumbbell_Deadlift/1.jpg',
    ],
    'glute_bridge': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Glute_Bridge/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Glute_Bridge/1.jpg',
    ],
    'glute_kickback': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Glute_Kickback/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Glute_Kickback/1.jpg',
    ],
    'hip_abduction': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Thigh_Abductor/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Thigh_Abductor/1.jpg',
    ],
    'hip_adduction': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Thigh_Adductor/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Thigh_Adductor/1.jpg',
    ],
    'seated_calf': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Calf_Raise/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Calf_Raise/1.jpg',
    ],
    'crunch': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Crunches/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Crunches/1.jpg',
    ],
    'hanging_leg_raise': [
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Hanging_Leg_Raise/0.jpg',
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Hanging_Leg_Raise/1.jpg',
    ],
  };

  /// Quadros do exercício (lista vazia se não houver mídia).
  static List<String> framesFor(String id) => _frames[id] ?? const [];

  /// Primeira imagem (capa) do exercício, ou null.
  static String? coverFor(String id) {
    final f = _frames[id];
    return (f == null || f.isEmpty) ? null : f.first;
  }
}
DARTEOF_MEDIA

echo "    - lib/shared/widgets/media/animated_exercise_image.dart"
cat > lib/shared/widgets/media/animated_exercise_image.dart <<'DARTEOF_ANIMWIDGET'
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Mostra uma sequência de imagens (quadros) em looping, criando uma
/// animação simples do movimento a partir de fotos estáticas de posição
/// inicial e final. As imagens são carregadas da rede e cacheadas.
///
/// Se [frames] estiver vazio, mostra [placeholder] (ou nada).
class AnimatedExerciseImage extends StatefulWidget {
  const AnimatedExerciseImage({
    required this.frames,
    this.fit = BoxFit.cover,
    this.interval = const Duration(milliseconds: 850),
    this.placeholder,
    super.key,
  });

  final List<String> frames;
  final BoxFit fit;
  final Duration interval;
  final Widget? placeholder;

  @override
  State<AnimatedExerciseImage> createState() => _AnimatedExerciseImageState();
}

class _AnimatedExerciseImageState extends State<AnimatedExerciseImage> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    _timer?.cancel();
    _index = 0;
    // Só anima quando há mais de um quadro.
    if (widget.frames.length > 1) {
      _timer = Timer.periodic(widget.interval, (_) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % widget.frames.length);
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedExerciseImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.frames, widget.frames) &&
        oldWidget.frames.join() != widget.frames.join()) {
      _restart();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frames = widget.frames;
    if (frames.isEmpty) {
      return widget.placeholder ?? const SizedBox.shrink();
    }
    final url = frames[_index % frames.length];
    final fallback = widget.placeholder ?? const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: CachedNetworkImage(
        key: ValueKey(url),
        imageUrl: url,
        fit: widget.fit,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}
DARTEOF_ANIMWIDGET

echo "    - lib/shared/widgets/media/progress_photo_view.dart"
cat > lib/shared/widgets/media/progress_photo_view.dart <<'DARTEOF_PHOTOVIEW'
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Exibe uma foto de progresso a partir de uma "fonte" que pode ser:
/// - data URL (`data:image/...;base64,...`) → decodifica e mostra os bytes
///   (funciona na web, onde `Image.file` não funciona);
/// - URL http/https → imagem de rede (cacheada);
/// - qualquer outra coisa (ex.: caminho de arquivo antigo/blob) → espaço
///   neutro, evitando a "imagem preta".
class ProgressPhotoView extends StatelessWidget {
  const ProgressPhotoView({
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholder =
        Container(width: width, height: height, color: AppColors.card);

    if (source.startsWith('data:')) {
      final comma = source.indexOf(',');
      if (comma == -1) return placeholder;
      try {
        final bytes = base64Decode(source.substring(comma + 1));
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => placeholder,
        );
      } catch (_) {
        return placeholder;
      }
    }

    if (source.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: source,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      );
    }

    return placeholder;
  }
}
DARTEOF_PHOTOVIEW

echo "    - lib/shared/widgets/navigation/vis_app_bar.dart"
cat > lib/shared/widgets/navigation/vis_app_bar.dart <<'DARTEOF_VISAPPBAR'
import 'package:flutter/material.dart';

/// AppBar do VIS com cabeçalho colorido em degradê (identidade por seção).
///
/// Mantém o tema escuro do app, mas dá cor a cada área (Biblioteca, Nutrição,
/// Cardio, Evolução, Fotos…), em vez de tudo preto. Texto e ícones ficam
/// brancos sobre a cor.
class VisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VisAppBar({
    required this.title,
    required this.accent,
    this.actions,
    this.bottom,
    super.key,
  });

  final String title;
  final Color accent;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final darker = Color.alphaBlend(Colors.black.withValues(alpha: 0.45), accent);
    return AppBar(
      title: Text(title),
      actions: actions,
      bottom: bottom,
      foregroundColor: Colors.white,
      backgroundColor: accent,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, darker],
          ),
        ),
      ),
    );
  }
}
DARTEOF_VISAPPBAR

echo "    - lib/shared/widgets/widgets.dart"
cat > lib/shared/widgets/widgets.dart <<'DARTEOF_BARREL'
/// Barrel de exportação do Design System do VIS.
///
/// As features importam `package:vis/shared/widgets/widgets.dart` para
/// acessar todos os componentes reutilizáveis de uma vez.
library;

export 'buttons/primary_button.dart';
export 'buttons/secondary_button.dart';
export 'buttons/vis_icon_button.dart';
export 'cards/exercise_card.dart';
export 'cards/insight_card.dart';
export 'cards/metric_card.dart';
export 'cards/photo_card.dart';
export 'cards/workout_card.dart';
export 'charts/progress_chart.dart';
export 'common/app_snackbar.dart';
export 'common/avatar.dart';
export 'common/card_container.dart';
export 'common/vis_progress_bar.dart';
export 'common/placeholder_view.dart';
export 'common/section_header.dart';
export 'common/vis_badge.dart';
export 'common/vis_chip.dart';
export 'dialogs/confirmation_dialog.dart';
export 'feedback/empty_state.dart';
export 'feedback/error_state.dart';
export 'feedback/loading_widget.dart';
export 'feedback/offline_banner.dart';
export 'inputs/search_field.dart';
export 'inputs/vis_text_field.dart';
export 'media/animated_exercise_image.dart';
export 'media/progress_photo_view.dart';
export 'navigation/bottom_navigation.dart';
export 'navigation/vis_app_bar.dart';
DARTEOF_BARREL

echo "    - lib/shared/widgets/cards/exercise_card.dart"
cat > lib/shared/widgets/cards/exercise_card.dart <<'DARTEOF_CARD'
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../common/card_container.dart';
import '../media/animated_exercise_image.dart';

/// Card de exercício: miniatura, nome, equipamento e grupo muscular.
///
/// Se [frames] tiver mais de uma imagem, a miniatura anima em looping
/// (posição inicial ↔ final). Caso contrário usa [imageUrl] estático, e
/// se nada houver mostra um espaço neutro.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    required this.name,
    required this.muscle,
    required this.equipment,
    this.imageUrl,
    this.frames = const [],
    this.onTap,
    this.trailing,
    super.key,
  });

  final String name;
  final String muscle;
  final String equipment;
  final String? imageUrl;
  final List<String> frames;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(color: AppColors.elevated);

    Widget thumb;
    if (frames.isNotEmpty) {
      thumb = AnimatedExerciseImage(frames: frames, placeholder: placeholder);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      thumb = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      );
    } else {
      thumb = placeholder;
    }

    return CardContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 56, height: 56, child: thumb),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('$muscle · $equipment', style: AppTypography.small),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
DARTEOF_CARD

echo "    - lib/features/exercise/data/exercise_catalog_seed.dart"
cat > lib/features/exercise/data/exercise_catalog_seed.dart <<'DARTEOF_SEED'
import '../domain/exercise_enums.dart';
import '../models/exercise.dart';

/// Catálogo semente do VIS (PROMPT 05).
///
/// Conjunto curado inicial com conteúdo completo. A arquitetura suporta
/// milhares de exercícios; este seed será expandido/substituído por uma
/// fonte remota (Supabase `exercise_library`) sem mudar o restante do
/// código. Os IDs coincidem com os usados pelo Workout Engine.
abstract final class ExerciseCatalogSeed {
  const ExerciseCatalogSeed._();

  static const List<Exercise> all = [
    Exercise(
      id: 'bench_press',
      name: 'Supino Reto',
      slug: 'supino-reto',
      primaryMuscle: Muscles.chest,
      secondaryMuscles: [Muscles.frontDelts, Muscles.triceps],
      equipment: Equipments.barbell,
      category: ExerciseCategory.push,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      plane: MovementPlane.horizontal,
      pattern: MovementPattern.push,
      description: 'Principal exercício de empurrar horizontal para o peitoral.',
      execution:
          'Deite no banco, retraia as escápulas, desça a barra até o peito e empurre até estender os cotovelos.',
      breathing: 'Inspire na descida, expire na subida.',
      cadence: '2-0-1',
      amplitude: 'Barra até tocar levemente o peito.',
      commonErrors: ['Abrir os cotovelos 90°', 'Tirar o quadril do banco'],
      tips: ['Mantenha os pés firmes', 'Escápulas retraídas'],
      synonyms: ['supino', 'bench press'],
      alternatives: ['incline_db_press', 'push_up'],
      progressions: ['bench_press'],
      regressions: ['push_up'],
    ),
    Exercise(
      id: 'incline_db_press',
      name: 'Supino Inclinado com Halteres',
      slug: 'supino-inclinado-halteres',
      primaryMuscle: Muscles.chest,
      secondaryMuscles: [Muscles.frontDelts, Muscles.triceps],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.push,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      execution:
          'Banco a 30-45°, empurre os halteres para cima sem chocá-los, controle a descida.',
      breathing: 'Expire ao empurrar.',
      cadence: '2-0-1',
      commonErrors: ['Inclinação excessiva', 'Amplitude curta'],
      tips: ['Foco na porção superior do peito'],
      synonyms: ['inclinado', 'incline press'],
      alternatives: ['bench_press', 'chest_fly'],
    ),
    Exercise(
      id: 'chest_fly',
      name: 'Crucifixo',
      slug: 'crucifixo',
      primaryMuscle: Muscles.chest,
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.push,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Abra os braços em arco com leve flexão de cotovelo e retorne contraindo o peito.',
      breathing: 'Inspire na abertura, expire ao fechar.',
      commonErrors: ['Transformar em supino', 'Descer demais'],
      tips: ['Cotovelos semi-fixos'],
      alternatives: ['incline_db_press'],
    ),
    Exercise(
      id: 'lat_pulldown',
      name: 'Puxada na Frente',
      slug: 'puxada-frente',
      primaryMuscle: Muscles.lats,
      secondaryMuscles: [Muscles.biceps, Muscles.rearDelts],
      equipment: Equipments.cable,
      category: ExerciseCategory.pull,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.beginner,
      plane: MovementPlane.vertical,
      pattern: MovementPattern.pull,
      execution: 'Puxe a barra até a parte alta do peito, descendo as escápulas.',
      breathing: 'Expire ao puxar.',
      commonErrors: ['Balançar o tronco', 'Puxar atrás da nuca'],
      tips: ['Inicie pelas costas, não pelos braços'],
      synonyms: ['pulldown', 'puxada'],
      alternatives: ['pull_up', 'barbell_row'],
      regressions: ['lat_pulldown'],
      progressions: ['pull_up'],
    ),
    Exercise(
      id: 'barbell_row',
      name: 'Remada Curvada',
      slug: 'remada-curvada',
      primaryMuscle: Muscles.back,
      secondaryMuscles: [Muscles.lats, Muscles.biceps],
      equipment: Equipments.barbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      pattern: MovementPattern.pull,
      execution: 'Tronco inclinado, puxe a barra ao abdômen mantendo a lombar neutra.',
      breathing: 'Expire ao puxar.',
      commonErrors: ['Arredondar a lombar', 'Usar impulso'],
      tips: ['Coluna neutra sempre'],
      synonyms: ['remada'],
      alternatives: ['lat_pulldown'],
    ),
    Exercise(
      id: 'pull_up',
      name: 'Barra Fixa',
      slug: 'barra-fixa',
      primaryMuscle: Muscles.lats,
      secondaryMuscles: [Muscles.biceps],
      equipment: Equipments.bodyweight,
      category: ExerciseCategory.pull,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.advanced,
      plane: MovementPlane.vertical,
      pattern: MovementPattern.pull,
      homeCompatible: true,
      execution: 'Suspenso na barra, puxe até o queixo passar a barra e desça controlado.',
      breathing: 'Expire ao subir.',
      commonErrors: ['Amplitude parcial', 'Balanço'],
      tips: ['Comece com barra assistida se necessário'],
      synonyms: ['pull up'],
      regressions: ['lat_pulldown'],
    ),
    Exercise(
      id: 'overhead_press',
      name: 'Desenvolvimento',
      slug: 'desenvolvimento',
      primaryMuscle: Muscles.frontDelts,
      secondaryMuscles: [Muscles.sideDelts, Muscles.triceps],
      equipment: Equipments.barbell,
      category: ExerciseCategory.push,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      plane: MovementPlane.vertical,
      pattern: MovementPattern.push,
      execution: 'Empurre a barra acima da cabeça até estender os cotovelos.',
      breathing: 'Expire ao empurrar.',
      commonErrors: ['Hiperextensão lombar', 'Amplitude curta'],
      tips: ['Contraia o core'],
      synonyms: ['ohp', 'militar'],
      alternatives: ['lateral_raise'],
    ),
    Exercise(
      id: 'lateral_raise',
      name: 'Elevação Lateral',
      slug: 'elevacao-lateral',
      primaryMuscle: Muscles.sideDelts,
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.push,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Eleve os halteres até a linha dos ombros com leve flexão de cotovelo.',
      breathing: 'Expire ao elevar.',
      commonErrors: ['Usar impulso', 'Subir acima do ombro'],
      tips: ['Movimento controlado'],
      synonyms: ['elevação lateral'],
    ),
    Exercise(
      id: 'biceps_curl',
      name: 'Rosca Direta',
      slug: 'rosca-direta',
      primaryMuscle: Muscles.biceps,
      equipment: Equipments.barbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Flexione os cotovelos elevando a barra, sem mover os ombros.',
      breathing: 'Expire ao subir.',
      commonErrors: ['Balançar o corpo', 'Cotovelos à frente'],
      tips: ['Cotovelos fixos ao lado do corpo'],
      synonyms: ['rosca'],
    ),
    Exercise(
      id: 'triceps_pushdown',
      name: 'Tríceps na Polia',
      slug: 'triceps-polia',
      primaryMuscle: Muscles.triceps,
      equipment: Equipments.cable,
      category: ExerciseCategory.push,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Estenda os cotovelos empurrando a barra/corda para baixo.',
      breathing: 'Expire ao estender.',
      commonErrors: ['Mover os cotovelos', 'Amplitude curta'],
      tips: ['Cotovelos colados ao tronco'],
      synonyms: ['tríceps pulley'],
    ),
    Exercise(
      id: 'squat',
      name: 'Agachamento Livre',
      slug: 'agachamento-livre',
      primaryMuscle: Muscles.quads,
      secondaryMuscles: [Muscles.glutes, Muscles.hamstrings, Muscles.lowerBack],
      equipment: Equipments.barbell,
      category: ExerciseCategory.squat,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.advanced,
      pattern: MovementPattern.squat,
      execution: 'Desça flexionando quadril e joelhos até a coxa paralela, suba empurrando o chão.',
      breathing: 'Inspire na descida, expire na subida.',
      cadence: '2-0-1',
      commonErrors: ['Joelho valgo', 'Lombar arredondada'],
      tips: ['Peito alto, core firme'],
      synonyms: ['agachamento', 'squat'],
      alternatives: ['leg_press'],
      regressions: ['leg_press'],
    ),
    Exercise(
      id: 'leg_press',
      name: 'Leg Press',
      slug: 'leg-press',
      primaryMuscle: Muscles.quads,
      secondaryMuscles: [Muscles.glutes, Muscles.hamstrings],
      equipment: Equipments.machine,
      category: ExerciseCategory.squat,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.beginner,
      pattern: MovementPattern.squat,
      execution: 'Empurre a plataforma estendendo os joelhos sem travá-los.',
      breathing: 'Expire ao empurrar.',
      commonErrors: ['Descolar o quadril', 'Amplitude curta'],
      tips: ['Não trave os joelhos no topo'],
      alternatives: ['squat'],
    ),
    Exercise(
      id: 'romanian_deadlift',
      name: 'Levantamento Terra Romeno',
      slug: 'terra-romeno',
      primaryMuscle: Muscles.hamstrings,
      secondaryMuscles: [Muscles.glutes, Muscles.lowerBack],
      equipment: Equipments.barbell,
      category: ExerciseCategory.hinge,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      pattern: MovementPattern.hinge,
      execution: 'Empurre o quadril para trás descendo a barra rente às pernas, retorne contraindo glúteos.',
      breathing: 'Inspire na descida, expire ao subir.',
      commonErrors: ['Arredondar a lombar', 'Flexionar muito o joelho'],
      tips: ['Barra sempre próxima ao corpo'],
      synonyms: ['rdl', 'stiff'],
      alternatives: ['leg_curl'],
    ),
    Exercise(
      id: 'leg_curl',
      name: 'Mesa Flexora',
      slug: 'mesa-flexora',
      primaryMuscle: Muscles.hamstrings,
      equipment: Equipments.machine,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Flexione os joelhos trazendo o apoio em direção aos glúteos.',
      breathing: 'Expire ao flexionar.',
      commonErrors: ['Tirar o quadril do apoio'],
      tips: ['Controle a fase negativa'],
    ),
    Exercise(
      id: 'hip_thrust',
      name: 'Elevação Pélvica',
      slug: 'elevacao-pelvica',
      primaryMuscle: Muscles.glutes,
      secondaryMuscles: [Muscles.hamstrings],
      equipment: Equipments.barbell,
      category: ExerciseCategory.hinge,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      pattern: MovementPattern.hinge,
      execution: 'Apoie as costas no banco e eleve o quadril até a extensão completa contraindo os glúteos.',
      breathing: 'Expire ao subir.',
      commonErrors: ['Hiperextensão lombar', 'Amplitude curta'],
      tips: ['Queixo levemente para baixo'],
      synonyms: ['hip thrust'],
    ),
    Exercise(
      id: 'calf_raise',
      name: 'Panturrilha em Pé',
      slug: 'panturrilha-em-pe',
      primaryMuscle: Muscles.calves,
      equipment: Equipments.machine,
      category: ExerciseCategory.push,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Eleve os calcanhares ao máximo e desça controlando o alongamento.',
      breathing: 'Expire ao subir.',
      commonErrors: ['Amplitude curta', 'Rebote'],
      tips: ['Pausa de 1s no topo'],
      homeCompatible: true,
    ),
    Exercise(
      id: 'plank',
      name: 'Prancha',
      slug: 'prancha',
      primaryMuscle: Muscles.abs,
      secondaryMuscles: [Muscles.obliques, Muscles.lowerBack],
      equipment: Equipments.bodyweight,
      category: ExerciseCategory.stabilize,
      type: ExerciseType.isometric,
      difficulty: ExerciseDifficulty.beginner,
      pattern: MovementPattern.coreStability,
      homeCompatible: true,
      execution: 'Mantenha o corpo alinhado apoiado nos antebraços, contraindo abdômen e glúteos.',
      breathing: 'Respiração contínua.',
      commonErrors: ['Quadril alto ou baixo'],
      tips: ['Alinhe cabeça, quadril e calcanhares'],
    ),
    Exercise(
      id: 'push_up',
      name: 'Flexão de Braço',
      slug: 'flexao-de-braco',
      primaryMuscle: Muscles.chest,
      secondaryMuscles: [Muscles.triceps, Muscles.frontDelts],
      equipment: Equipments.bodyweight,
      category: ExerciseCategory.push,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.beginner,
      plane: MovementPlane.horizontal,
      pattern: MovementPattern.push,
      homeCompatible: true,
      execution: 'Desça o corpo flexionando os cotovelos e empurre até estender.',
      breathing: 'Inspire na descida, expire na subida.',
      commonErrors: ['Quadril caído', 'Amplitude curta'],
      tips: ['Corpo em linha reta'],
      synonyms: ['flexão', 'push up'],
      progressions: ['bench_press'],
    ),

    // ----- Trapézio -----
    Exercise(
      id: 'dumbbell_shrug',
      name: 'Encolhimento com Halteres',
      slug: 'encolhimento-halteres',
      primaryMuscle: Muscles.traps,
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution:
          'Segure halteres ao lado do corpo e eleve os ombros em direção às orelhas, sem girar. Segure no topo e desça controlado.',
      breathing: 'Expire ao elevar os ombros.',
      commonErrors: ['Girar os ombros', 'Usar impulso'],
      tips: ['Pausa de 1s no topo', 'Não projete a cabeça à frente'],
      synonyms: ['encolhimento', 'shrug', 'trapézio'],
    ),
    Exercise(
      id: 'upright_row',
      name: 'Remada Alta',
      slug: 'remada-alta',
      primaryMuscle: Muscles.traps,
      secondaryMuscles: [Muscles.sideDelts],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      pattern: MovementPattern.pull,
      execution:
          'Puxe os halteres para cima rente ao corpo até a altura do peito, com os cotovelos liderando o movimento.',
      breathing: 'Expire ao puxar.',
      commonErrors: ['Subir acima dos ombros', 'Afastar o peso do corpo'],
      tips: ['Cotovelos sempre acima das mãos'],
      synonyms: ['remada alta', 'upright row'],
    ),

    // ----- Deltoide posterior -----
    Exercise(
      id: 'reverse_fly',
      name: 'Crucifixo Inverso',
      slug: 'crucifixo-inverso',
      primaryMuscle: Muscles.rearDelts,
      secondaryMuscles: [Muscles.traps],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution:
          'Com o tronco inclinado à frente, abra os braços para os lados com leve flexão de cotovelo, contraindo a parte de trás dos ombros.',
      breathing: 'Expire ao abrir os braços.',
      commonErrors: ['Usar impulso', 'Arredondar a lombar'],
      tips: ['Movimento controlado', 'Aperte as escápulas'],
      synonyms: ['crucifixo inverso', 'reverse fly', 'voador inverso'],
      alternatives: ['face_pull'],
    ),
    Exercise(
      id: 'face_pull',
      name: 'Face Pull',
      slug: 'face-pull',
      primaryMuscle: Muscles.rearDelts,
      secondaryMuscles: [Muscles.traps],
      equipment: Equipments.cable,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution:
          'Puxe a corda em direção ao rosto, abrindo os cotovelos para fora e girando as mãos para trás.',
      breathing: 'Expire ao puxar.',
      commonErrors: ['Puxar com os braços em vez das costas', 'Cotovelos baixos'],
      tips: ['Cotovelos na altura dos ombros', 'Ótimo para a postura'],
      synonyms: ['face pull', 'puxada para o rosto'],
      alternatives: ['reverse_fly'],
    ),

    // ----- Antebraços -----
    Exercise(
      id: 'wrist_curl',
      name: 'Rosca de Punho',
      slug: 'rosca-de-punho',
      primaryMuscle: Muscles.forearms,
      equipment: Equipments.barbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution:
          'Com os antebraços apoiados no banco e as palmas para cima, flexione os punhos elevando a barra e desça controlando.',
      breathing: 'Expire ao subir.',
      commonErrors: ['Tirar os antebraços do apoio', 'Amplitude curta'],
      tips: ['Amplitude total no punho'],
      synonyms: ['rosca de punho', 'wrist curl', 'flexão de punho'],
    ),
    Exercise(
      id: 'reverse_curl',
      name: 'Rosca Inversa',
      slug: 'rosca-inversa',
      primaryMuscle: Muscles.forearms,
      secondaryMuscles: [Muscles.biceps],
      equipment: Equipments.barbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution:
          'Segure a barra com as palmas para baixo (pegada pronada) e flexione os cotovelos, mantendo os punhos firmes.',
      breathing: 'Expire ao subir.',
      commonErrors: ['Balançar o corpo', 'Soltar o punho'],
      tips: ['Cotovelos fixos ao lado do corpo'],
      synonyms: ['rosca inversa', 'reverse curl', 'pegada pronada'],
    ),

    // ----- Oblíquos -----
    Exercise(
      id: 'side_plank',
      name: 'Prancha Lateral',
      slug: 'prancha-lateral',
      primaryMuscle: Muscles.obliques,
      secondaryMuscles: [Muscles.abs],
      equipment: Equipments.bodyweight,
      category: ExerciseCategory.stabilize,
      type: ExerciseType.isometric,
      difficulty: ExerciseDifficulty.beginner,
      pattern: MovementPattern.coreStability,
      homeCompatible: true,
      execution:
          'Apoie o antebraço no chão e eleve o quadril, formando uma linha reta do ombro ao pé. Mantenha a posição.',
      breathing: 'Respiração contínua.',
      commonErrors: ['Deixar o quadril cair', 'Rotacionar o tronco'],
      tips: ['Contraia o abdômen e os glúteos', 'Alterne os lados'],
      synonyms: ['prancha lateral', 'side plank'],
      alternatives: ['plank'],
    ),
    Exercise(
      id: 'russian_twist',
      name: 'Rotação Russa',
      slug: 'rotacao-russa',
      primaryMuscle: Muscles.obliques,
      secondaryMuscles: [Muscles.abs],
      equipment: Equipments.bodyweight,
      category: ExerciseCategory.rotation,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      plane: MovementPlane.rotational,
      pattern: MovementPattern.rotation,
      homeCompatible: true,
      execution:
          'Sentado com o tronco inclinado para trás e os pés elevados, gire o tronco de um lado ao outro tocando as mãos ao lado do quadril.',
      breathing: 'Expire a cada rotação.',
      commonErrors: ['Mover só os braços', 'Arredondar demais a lombar'],
      tips: ['Gire a partir do tronco, não dos braços'],
      synonyms: ['rotação russa', 'russian twist', 'giro russo'],
    ),

    // ----- Lombar -----
    Exercise(
      id: 'hyperextension',
      name: 'Hiperextensão',
      slug: 'hiperextensao',
      primaryMuscle: Muscles.lowerBack,
      secondaryMuscles: [Muscles.glutes, Muscles.hamstrings],
      equipment: Equipments.machine,
      category: ExerciseCategory.hinge,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      pattern: MovementPattern.hinge,
      execution:
          'No banco romano, desça o tronco flexionando o quadril e suba até alinhar o corpo, contraindo lombar e glúteos.',
      breathing: 'Expire ao subir.',
      commonErrors: ['Hiperestender a coluna no topo', 'Usar impulso'],
      tips: ['Suba só até a linha do corpo', 'Movimento a partir do quadril'],
      synonyms: ['hiperextensão', 'extensão lombar', 'back extension'],
    ),
    Exercise(
      id: 'good_morning',
      name: 'Bom Dia',
      slug: 'bom-dia',
      primaryMuscle: Muscles.lowerBack,
      secondaryMuscles: [Muscles.hamstrings, Muscles.glutes],
      equipment: Equipments.barbell,
      category: ExerciseCategory.hinge,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.advanced,
      pattern: MovementPattern.hinge,
      execution:
          'Com a barra apoiada nos ombros, empurre o quadril para trás inclinando o tronco à frente com a lombar neutra, e retorne.',
      breathing: 'Inspire na descida, expire ao subir.',
      commonErrors: ['Arredondar a lombar', 'Flexionar demais os joelhos'],
      tips: ['Use carga leve', 'Lombar sempre neutra'],
      synonyms: ['bom dia', 'good morning'],
      alternatives: ['romanian_deadlift'],
    ),
    Exercise(
      id: 'db_bench_press',
      name: 'Supino Reto com Halteres',
      slug: 'supino-halteres',
      primaryMuscle: Muscles.chest,
      secondaryMuscles: [Muscles.triceps, Muscles.frontDelts],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.push,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      execution: 'Deitado no banco, empurre os halteres para cima até estender os cotovelos e desça controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Desça até sentir o peito alongar.'],
      synonyms: ['supino halteres', 'dumbbell press'],
    ),
    Exercise(
      id: 'decline_bench',
      name: 'Supino Declinado',
      slug: 'supino-declinado',
      primaryMuscle: Muscles.chest,
      secondaryMuscles: [Muscles.triceps],
      equipment: Equipments.barbell,
      category: ExerciseCategory.push,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      execution: 'No banco declinado, desça a barra até a parte baixa do peito e empurre para cima.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Foca a porção inferior do peitoral.'],
      synonyms: ['declinado', 'decline press'],
    ),
    Exercise(
      id: 'cable_crossover',
      name: 'Crossover na Polia',
      slug: 'crossover',
      primaryMuscle: Muscles.chest,
      equipment: Equipments.cable,
      category: ExerciseCategory.push,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Puxe as polias à frente do corpo em arco, cruzando levemente as mãos, e volte controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Aperte o peito no fim do movimento.'],
      synonyms: ['crossover', 'cross over'],
    ),
    Exercise(
      id: 'pec_deck',
      name: 'Voador (Peck Deck)',
      slug: 'voador',
      primaryMuscle: Muscles.chest,
      equipment: Equipments.machine,
      category: ExerciseCategory.push,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Sentado na máquina, junte os braços à frente contraindo o peito e volte devagar.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Cotovelos na linha dos ombros.'],
      synonyms: ['voador', 'peck deck', 'butterfly'],
    ),
    Exercise(
      id: 'machine_chest_press',
      name: 'Supino na Máquina',
      slug: 'supino-maquina',
      primaryMuscle: Muscles.chest,
      secondaryMuscles: [Muscles.triceps],
      equipment: Equipments.machine,
      category: ExerciseCategory.push,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Empurre as alavancas à frente até estender os cotovelos e volte controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Ótimo para iniciantes pela estabilidade.'],
      synonyms: ['supino máquina', 'chest press'],
    ),
    Exercise(
      id: 'chest_dips',
      name: 'Mergulho nas Paralelas',
      slug: 'mergulho-paralelas',
      primaryMuscle: Muscles.chest,
      secondaryMuscles: [Muscles.triceps, Muscles.frontDelts],
      equipment: Equipments.bodyweight,
      category: ExerciseCategory.push,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.advanced,
      homeCompatible: true,
      execution: 'Nas paralelas, incline o tronco à frente e desça flexionando os cotovelos, depois empurre para cima.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Inclinação à frente foca o peito.'],
      synonyms: ['paralelas', 'dips', 'mergulho'],
    ),
    Exercise(
      id: 'one_arm_db_row',
      name: 'Remada Unilateral',
      slug: 'remada-unilateral',
      primaryMuscle: Muscles.back,
      secondaryMuscles: [Muscles.lats, Muscles.biceps],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Apoiado no banco, puxe o halter em direção ao quadril mantendo a coluna neutra.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Puxe com as costas, não com o braço.'],
      synonyms: ['remada serrote', 'one arm row'],
    ),
    Exercise(
      id: 'seated_cable_row',
      name: 'Remada Baixa',
      slug: 'remada-baixa',
      primaryMuscle: Muscles.back,
      secondaryMuscles: [Muscles.lats, Muscles.biceps],
      equipment: Equipments.cable,
      category: ExerciseCategory.pull,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Sentado, puxe o triângulo em direção ao abdômen aproximando as escápulas.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Peito aberto, não curve as costas.'],
      synonyms: ['remada baixa', 'seated row'],
    ),
    Exercise(
      id: 'tbar_row',
      name: 'Remada Cavalinho',
      slug: 'remada-cavalinho',
      primaryMuscle: Muscles.back,
      secondaryMuscles: [Muscles.lats, Muscles.biceps],
      equipment: Equipments.machine,
      category: ExerciseCategory.pull,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      execution: 'Puxe a barra T em direção ao peito com o tronco inclinado, apertando as costas.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Coluna neutra durante todo o movimento.'],
      synonyms: ['cavalinho', 't-bar row'],
    ),
    Exercise(
      id: 'close_grip_pulldown',
      name: 'Puxada Triângulo',
      slug: 'puxada-triangulo',
      primaryMuscle: Muscles.lats,
      secondaryMuscles: [Muscles.biceps],
      equipment: Equipments.cable,
      category: ExerciseCategory.pull,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Puxe o triângulo até o peito descendo as escápulas, e retorne controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Inicie o movimento pelas costas.'],
      synonyms: ['puxada triângulo', 'close grip pulldown'],
    ),
    Exercise(
      id: 'db_pullover',
      name: 'Pullover',
      slug: 'pullover',
      primaryMuscle: Muscles.lats,
      secondaryMuscles: [Muscles.chest],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.intermediate,
      execution: 'Deitado, leve o halter atrás da cabeça com os braços semiflexionados e traga de volta sobre o peito.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Sinta o alongamento das costas e do peito.'],
      synonyms: ['pullover'],
    ),
    Exercise(
      id: 'db_shoulder_press',
      name: 'Desenvolvimento com Halteres',
      slug: 'desenvolvimento-halteres',
      primaryMuscle: Muscles.frontDelts,
      secondaryMuscles: [Muscles.sideDelts, Muscles.triceps],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.push,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Sentado, empurre os halteres acima da cabeça até estender os cotovelos e desça controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Não arqueie a lombar.'],
      synonyms: ['desenvolvimento halteres', 'shoulder press'],
    ),
    Exercise(
      id: 'arnold_press',
      name: 'Desenvolvimento Arnold',
      slug: 'desenvolvimento-arnold',
      primaryMuscle: Muscles.frontDelts,
      secondaryMuscles: [Muscles.sideDelts, Muscles.triceps],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.push,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      execution: 'Comece com as palmas voltadas para você e gire os halteres enquanto empurra para cima.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Movimento fluido e controlado.'],
      synonyms: ['arnold', 'arnold press'],
    ),
    Exercise(
      id: 'front_raise',
      name: 'Elevação Frontal',
      slug: 'elevacao-frontal',
      primaryMuscle: Muscles.frontDelts,
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.push,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Eleve os halteres à frente até a altura dos ombros e desça controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Sem balançar o tronco.'],
      synonyms: ['elevação frontal', 'front raise'],
    ),
    Exercise(
      id: 'cable_lateral_raise',
      name: 'Elevação Lateral na Polia',
      slug: 'elevacao-lateral-polia',
      primaryMuscle: Muscles.sideDelts,
      equipment: Equipments.cable,
      category: ExerciseCategory.push,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.intermediate,
      execution: 'Puxe a polia para o lado até a linha do ombro mantendo leve flexão de cotovelo.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Tensão constante do cabo.'],
      synonyms: ['elevação lateral polia', 'cable lateral'],
    ),
    Exercise(
      id: 'hammer_curl',
      name: 'Rosca Martelo',
      slug: 'rosca-martelo',
      primaryMuscle: Muscles.biceps,
      secondaryMuscles: [Muscles.forearms],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Com as palmas voltadas uma para a outra, flexione os cotovelos elevando os halteres.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Cotovelos fixos ao lado do corpo.'],
      synonyms: ['rosca martelo', 'hammer curl'],
    ),
    Exercise(
      id: 'preacher_curl',
      name: 'Rosca Scott',
      slug: 'rosca-scott',
      primaryMuscle: Muscles.biceps,
      equipment: Equipments.barbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'No banco Scott, flexione os cotovelos elevando a barra e desça controlando a fase negativa.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Não estenda totalmente para manter a tensão.'],
      synonyms: ['rosca scott', 'preacher curl'],
    ),
    Exercise(
      id: 'concentration_curl',
      name: 'Rosca Concentrada',
      slug: 'rosca-concentrada',
      primaryMuscle: Muscles.biceps,
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Sentado, apoie o cotovelo na coxa e flexione o braço concentrando no bíceps.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Contraia forte no topo.'],
      synonyms: ['rosca concentrada', 'concentration curl'],
    ),
    Exercise(
      id: 'incline_db_curl',
      name: 'Rosca Inclinada',
      slug: 'rosca-inclinada',
      primaryMuscle: Muscles.biceps,
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.intermediate,
      execution: 'No banco inclinado, deixe os braços estendidos para baixo e flexione alternando os halteres.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Alongamento maior do bíceps.'],
      synonyms: ['rosca inclinada', 'incline curl'],
    ),
    Exercise(
      id: 'skullcrusher',
      name: 'Tríceps Testa',
      slug: 'triceps-testa',
      primaryMuscle: Muscles.triceps,
      equipment: Equipments.barbell,
      category: ExerciseCategory.push,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.intermediate,
      execution: 'Deitado, flexione os cotovelos levando a barra até a testa e estenda de volta.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Cotovelos apontando para cima, fixos.'],
      synonyms: ['tríceps testa', 'skullcrusher'],
    ),
    Exercise(
      id: 'french_press',
      name: 'Tríceps Francês',
      slug: 'triceps-frances',
      primaryMuscle: Muscles.triceps,
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.push,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Sentado, leve o halter atrás da cabeça e estenda os cotovelos para cima.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Cotovelos próximos à cabeça.'],
      synonyms: ['tríceps francês', 'french press'],
    ),
    Exercise(
      id: 'triceps_kickback',
      name: 'Tríceps Coice',
      slug: 'triceps-coice',
      primaryMuscle: Muscles.triceps,
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.push,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Tronco inclinado, estenda o cotovelo para trás até o braço ficar reto e volte controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Mantenha o braço colado ao tronco.'],
      synonyms: ['tríceps coice', 'kickback'],
    ),
    Exercise(
      id: 'bench_dips',
      name: 'Mergulho no Banco',
      slug: 'mergulho-banco',
      primaryMuscle: Muscles.triceps,
      equipment: Equipments.bodyweight,
      category: ExerciseCategory.push,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.beginner,
      homeCompatible: true,
      execution: 'Apoiado no banco, desça o corpo flexionando os cotovelos e empurre de volta para cima.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Cotovelos para trás, não para os lados.'],
      synonyms: ['mergulho banco', 'bench dips'],
    ),
    Exercise(
      id: 'sumo_squat',
      name: 'Agachamento Sumô',
      slug: 'agachamento-sumo',
      primaryMuscle: Muscles.quads,
      secondaryMuscles: [Muscles.glutes, Muscles.adductors],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.squat,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Pés afastados e pontas para fora, desça segurando o halter entre as pernas e suba.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Joelhos acompanham a ponta dos pés.'],
      synonyms: ['sumô', 'plié', 'sumo squat'],
    ),
    Exercise(
      id: 'bulgarian_split',
      name: 'Agachamento Búlgaro',
      slug: 'agachamento-bulgaro',
      primaryMuscle: Muscles.quads,
      secondaryMuscles: [Muscles.glutes],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.squat,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      execution: 'Com um pé à frente, desça flexionando o joelho da frente e suba, trabalhando uma perna por vez.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Tronco levemente à frente, joelho estável.'],
      synonyms: ['búlgaro', 'bulgarian', 'afundo búlgaro'],
    ),
    Exercise(
      id: 'lunge',
      name: 'Afundo',
      slug: 'afundo',
      primaryMuscle: Muscles.quads,
      secondaryMuscles: [Muscles.glutes, Muscles.hamstrings],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.squat,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Dê um passo à frente e desça o joelho de trás em direção ao chão, depois volte.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Joelho da frente alinhado ao pé.'],
      synonyms: ['afundo', 'passada', 'lunge'],
    ),
    Exercise(
      id: 'leg_extension',
      name: 'Cadeira Extensora',
      slug: 'cadeira-extensora',
      primaryMuscle: Muscles.quads,
      equipment: Equipments.machine,
      category: ExerciseCategory.squat,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Sentado na máquina, estenda os joelhos elevando o apoio e desça controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Pausa curta no topo.'],
      synonyms: ['extensora', 'leg extension'],
    ),
    Exercise(
      id: 'hack_squat',
      name: 'Agachamento Hack',
      slug: 'agachamento-hack',
      primaryMuscle: Muscles.quads,
      secondaryMuscles: [Muscles.glutes],
      equipment: Equipments.machine,
      category: ExerciseCategory.squat,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      execution: 'Na máquina hack, desça flexionando os joelhos e empurre a plataforma para cima.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Costas apoiadas o tempo todo.'],
      synonyms: ['hack', 'hack squat', 'agachamento hammer'],
    ),
    Exercise(
      id: 'front_squat',
      name: 'Agachamento Frontal',
      slug: 'agachamento-frontal',
      primaryMuscle: Muscles.quads,
      secondaryMuscles: [Muscles.glutes],
      equipment: Equipments.barbell,
      category: ExerciseCategory.squat,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.advanced,
      execution: 'Com a barra à frente sobre os ombros, agache mantendo o tronco ereto e suba.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Cotovelos altos para segurar a barra.'],
      synonyms: ['frontal', 'front squat'],
    ),
    Exercise(
      id: 'seated_leg_curl',
      name: 'Cadeira Flexora',
      slug: 'cadeira-flexora',
      primaryMuscle: Muscles.hamstrings,
      equipment: Equipments.machine,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Sentado, flexione os joelhos trazendo o apoio para baixo e volte controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Controle a fase negativa.'],
      synonyms: ['cadeira flexora', 'seated leg curl'],
    ),
    Exercise(
      id: 'stiff_deadlift',
      name: 'Stiff',
      slug: 'stiff',
      primaryMuscle: Muscles.hamstrings,
      secondaryMuscles: [Muscles.glutes, Muscles.lowerBack],
      equipment: Equipments.dumbbell,
      category: ExerciseCategory.hinge,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.intermediate,
      execution: 'Com as pernas quase estendidas, desça os halteres rente às pernas empurrando o quadril para trás.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Lombar neutra, sinta o posterior alongar.'],
      synonyms: ['stiff', 'levantamento terra pernas retas'],
    ),
    Exercise(
      id: 'glute_bridge',
      name: 'Ponte de Glúteo',
      slug: 'ponte-gluteo',
      primaryMuscle: Muscles.glutes,
      secondaryMuscles: [Muscles.hamstrings],
      equipment: Equipments.barbell,
      category: ExerciseCategory.hinge,
      type: ExerciseType.compound,
      difficulty: ExerciseDifficulty.beginner,
      homeCompatible: true,
      execution: 'Deitado no chão, eleve o quadril contraindo os glúteos e desça controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Aperte os glúteos no topo.'],
      synonyms: ['ponte', 'glute bridge'],
    ),
    Exercise(
      id: 'glute_kickback',
      name: 'Coice de Glúteo',
      slug: 'coice-gluteo',
      primaryMuscle: Muscles.glutes,
      equipment: Equipments.bodyweight,
      category: ExerciseCategory.hinge,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      homeCompatible: true,
      execution: 'Apoiado nos quatro apoios, estenda a perna para trás e para cima contraindo o glúteo.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Sem arquear a lombar.'],
      synonyms: ['coice', 'glute kickback'],
    ),
    Exercise(
      id: 'hip_abduction',
      name: 'Cadeira Abdutora',
      slug: 'cadeira-abdutora',
      primaryMuscle: Muscles.abductors,
      secondaryMuscles: [Muscles.glutes],
      equipment: Equipments.machine,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Sentado na máquina, abra as pernas contra a resistência e volte controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Movimento controlado, sem impulso.'],
      synonyms: ['abdutora', 'abdução'],
    ),
    Exercise(
      id: 'hip_adduction',
      name: 'Cadeira Adutora',
      slug: 'cadeira-adutora',
      primaryMuscle: Muscles.adductors,
      equipment: Equipments.machine,
      category: ExerciseCategory.pull,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Sentado na máquina, feche as pernas contra a resistência e volte devagar.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Aperte a parte interna da coxa.'],
      synonyms: ['adutora', 'adução'],
    ),
    Exercise(
      id: 'seated_calf',
      name: 'Panturrilha Sentado',
      slug: 'panturrilha-sentado',
      primaryMuscle: Muscles.calves,
      equipment: Equipments.machine,
      category: ExerciseCategory.push,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      execution: 'Sentado, eleve os calcanhares ao máximo e desça alongando a panturrilha.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Amplitude total, pausa no topo.'],
      synonyms: ['panturrilha sentado', 'seated calf'],
    ),
    Exercise(
      id: 'crunch',
      name: 'Abdominal (Crunch)',
      slug: 'abdominal-crunch',
      primaryMuscle: Muscles.abs,
      equipment: Equipments.bodyweight,
      category: ExerciseCategory.stabilize,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.beginner,
      homeCompatible: true,
      execution: 'Deitado, eleve o tronco contraindo o abdômen e desça controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Não puxe o pescoço com as mãos.'],
      synonyms: ['abdominal', 'crunch'],
    ),
    Exercise(
      id: 'hanging_leg_raise',
      name: 'Elevação de Pernas',
      slug: 'elevacao-de-pernas',
      primaryMuscle: Muscles.abs,
      secondaryMuscles: [Muscles.obliques],
      equipment: Equipments.bodyweight,
      category: ExerciseCategory.stabilize,
      type: ExerciseType.isolation,
      difficulty: ExerciseDifficulty.intermediate,
      homeCompatible: true,
      execution: 'Pendurado na barra, eleve as pernas à frente contraindo o abdômen e desça controlando.',
      breathing: 'Expire na fase de esforço.',
      tips: ['Evite balançar o corpo.'],
      synonyms: ['elevação de pernas', 'leg raise'],
    ),
  ];

  /// Músculos que possuem ao menos um exercício no catálogo — usado para
  /// esconder filtros vazios na Biblioteca.
  static final Set<String> coveredMuscles =
      all.map((e) => e.primaryMuscle).toSet();
}
DARTEOF_SEED

echo "    - lib/features/exercise/presentation/exercise_library_screen.dart"
cat > lib/features/exercise/presentation/exercise_library_screen.dart <<'DARTEOF_LIBSCREEN'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/exercise_catalog_seed.dart';
import '../data/exercise_media.dart';
import '../domain/exercise_enums.dart';
import '../providers/exercise_providers.dart';

/// Biblioteca de exercícios — busca, filtros e favoritos (PROMPT 05).
class ExerciseLibraryScreen extends ConsumerWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exerciseLibraryControllerProvider);
    final c = ref.read(exerciseLibraryControllerProvider.notifier);

    return Scaffold(
      appBar: const VisAppBar(title: 'Biblioteca', accent: AppColors.primary),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: SearchField(
              hint: 'Buscar exercício...',
              onChanged: c.setQuery,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              children: [
                VisChip(
                  label: 'Favoritos',
                  selected: state.filter.favoritesOnly,
                  onTap: () => c.setFavoritesOnly(!state.filter.favoritesOnly),
                ),
                const SizedBox(width: 8),
                VisChip(
                  label: 'Casa',
                  selected: state.filter.homeOnly,
                  onTap: () => c.setHomeOnly(!state.filter.homeOnly),
                ),
                const SizedBox(width: 8),
                for (final m
                    in Muscles.all.where(ExerciseCatalogSeed.coveredMuscles.contains)) ...[
                  VisChip(
                    label: m,
                    selected: state.filter.muscle == m,
                    onTap: () =>
                        c.setMuscle(state.filter.muscle == m ? null : m),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Expanded(
            child: state.results.when(
              loading: () => const LoadingWidget(),
              error: (_, __) => ErrorState(onRetry: c.reload),
              data: (exercises) {
                if (exercises.isEmpty) {
                  return const EmptyState(
                    title: 'Nenhum exercício encontrado',
                    description: 'Ajuste a busca ou os filtros.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  itemCount: exercises.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.s),
                  itemBuilder: (_, i) {
                    final ex = exercises[i];
                    return ExerciseCard(
                      name: ex.name,
                      muscle: ex.primaryMuscle,
                      equipment: ex.equipment,
                      imageUrl: ex.imageUrl,
                      frames: ExerciseMedia.framesFor(ex.id),
                      onTap: () =>
                          context.pushNamed('exercise-detail', extra: ex),
                      // Consumer isolado: favoritar rebuilda só este ícone,
                      // não a lista inteira (Regra 009 — rebuild mínimo).
                      trailing: Consumer(
                        builder: (context, ref, _) {
                          final isFav = ref.watch(
                              exerciseFavoritesControllerProvider
                                  .select((s) => s.contains(ex.id)));
                          return IconButton(
                            icon: Icon(
                              LucideIcons.heart,
                              color:
                                  isFav ? AppColors.danger : AppColors.disabled,
                              size: 20,
                            ),
                            onPressed: () => ref
                                .read(exerciseFavoritesControllerProvider
                                    .notifier)
                                .toggle(ex.id),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
DARTEOF_LIBSCREEN

echo "    - lib/features/exercise/presentation/exercise_detail_screen.dart"
cat > lib/features/exercise/presentation/exercise_detail_screen.dart <<'DARTEOF_DETAILSCREEN'
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/exercise_media.dart';
import '../models/exercise.dart';
import '../models/exercise_history.dart';
import '../providers/exercise_providers.dart';

/// Tela de detalhe do exercício (PROMPT 05).
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({required this.exercise, super.key});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(exerciseFavoritesControllerProvider);
    final isFav = favorites.contains(exercise.id);
    final repo = ref.read(exerciseRepositoryProvider);
    final history = repo.historyFor(exercise.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.heart,
                color: isFav ? AppColors.danger : null),
            onPressed: () => ref
                .read(exerciseFavoritesControllerProvider.notifier)
                .toggle(exercise.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Builder(
                builder: (_) {
                  final placeholder = Container(
                    color: AppColors.card,
                    child: const Icon(LucideIcons.dumbbell,
                        size: 40, color: AppColors.disabled),
                  );
                  final frames = ExerciseMedia.framesFor(exercise.id);
                  if (frames.isNotEmpty) {
                    return AnimatedExerciseImage(
                        frames: frames, placeholder: placeholder);
                  }
                  final url = exercise.gifUrl ?? exercise.imageUrl;
                  if (url != null) {
                    return CachedNetworkImage(imageUrl: url, fit: BoxFit.cover);
                  }
                  return placeholder;
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              VisBadge(label: exercise.primaryMuscle),
              VisBadge(label: exercise.equipment, color: AppColors.secondary),
              VisBadge(label: exercise.difficulty.label, color: AppColors.warning),
              VisBadge(label: exercise.type.label, color: AppColors.success),
            ],
          ),
          if (exercise.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            Text(exercise.description, style: AppTypography.body),
          ],
          _section('Execução', exercise.execution),
          _section('Respiração', exercise.breathing),
          _section('Cadência', exercise.cadence),
          _section('Amplitude', exercise.amplitude),
          _bullets('Erros comuns', exercise.commonErrors),
          _bullets('Dicas', exercise.tips),
          _history(history),
          _Related(exercise: exercise),
          const SizedBox(height: AppSpacing.l),
          PrimaryButton(
            label: 'Adicionar ao treino',
            icon: LucideIcons.plus,
            onPressed: () => AppSnackBar.show(
              context,
              'Adicione este exercício pelo editor de treino.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.subtitle),
          const SizedBox(height: 4),
          Text(text, style: AppTypography.body),
        ],
      ),
    );
  }

  Widget _bullets(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.subtitle),
          const SizedBox(height: 4),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('•  $it', style: AppTypography.body),
            ),
        ],
      ),
    );
  }

  Widget _history(ExerciseHistorySummary? history) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l),
      child: CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seu histórico', style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.s),
            if (history == null || history.isEmpty)
              Text('Sem registros ainda. Execute este exercício em um treino.',
                  style: AppTypography.caption)
            else
              Text(
                'Maior carga: ${history.maxWeight ?? '-'} kg · '
                'Maior volume: ${history.maxVolume ?? '-'} · '
                'Execuções: ${history.timesPerformed}',
                style: AppTypography.body,
              ),
          ],
        ),
      ),
    );
  }
}

class _Related extends ConsumerStatefulWidget {
  const _Related({required this.exercise});
  final Exercise exercise;

  @override
  ConsumerState<_Related> createState() => _RelatedState();
}

class _RelatedState extends ConsumerState<_Related> {
  // O future é criado uma única vez (não em build) para não re-disparar
  // getByIds a cada rebuild do pai (ex.: ao favoritar).
  Future<List<Exercise>>? _future;

  @override
  void initState() {
    super.initState();
    final ex = widget.exercise;
    final ids = {
      ...ex.alternatives,
      ...ex.progressions,
      ...ex.regressions,
    }.where((id) => id != ex.id).toList();
    if (ids.isNotEmpty) {
      _future = ref.read(exerciseRepositoryProvider).getByIds(ids);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_future == null) return const SizedBox.shrink();

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        final related = snapshot.data ?? const [];
        if (related.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Relacionados', style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.s),
              for (final ex in related)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s),
                  child: ExerciseCard(
                    name: ex.name,
                    muscle: ex.primaryMuscle,
                    equipment: ex.equipment,
                    onTap: () =>
                        context.pushNamed('exercise-detail', extra: ex),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
DARTEOF_DETAILSCREEN

echo "    - lib/features/nutrition/widgets/add_meal_sheet.dart"
cat > lib/features/nutrition/widgets/add_meal_sheet.dart <<'DARTEOF_MEALSHEET'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/nutrition_enums.dart';
import '../models/food_item.dart';
import '../models/macro_nutrients.dart';
import '../providers/nutrition_providers.dart';

/// Bottom sheet de registro manual de refeição (PROMPT 10).
///
/// Entrada manual: você digita os valores totais do alimento (calorias e
/// macros) que pesquisou. O app apenas soma os itens.
class AddMealSheet extends ConsumerStatefulWidget {
  const AddMealSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddMealSheet(),
    );
  }

  @override
  ConsumerState<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<AddMealSheet> {
  final Uuid _uuid = const Uuid();
  MealType _type = MealType.lunch;
  final List<FoodItem> _items = [];

  final _name = TextEditingController();
  final _qty = TextEditingController(text: '100');
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fats = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _qty, _kcal, _protein, _carbs, _fats]) {
      c.dispose();
    }
    super.dispose();
  }

  double _d(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  FoodItem? _buildItem() {
    if (_name.text.trim().isEmpty) return null;
    return FoodItem(
      id: _uuid.v4(),
      name: _name.text.trim(),
      quantity: _d(_qty),
      unit: MeasureUnit.grams,
      macros: MacroNutrients(
        calories: _d(_kcal),
        protein: _d(_protein),
        carbs: _d(_carbs),
        fats: _d(_fats),
      ),
    );
  }

  void _addItem() {
    final item = _buildItem();
    if (item == null) {
      AppSnackBar.show(context, 'Informe o nome do alimento.',
          type: SnackType.warning);
      return;
    }
    setState(() {
      _items.add(item);
      for (final c in [_name, _kcal, _protein, _carbs, _fats]) {
        c.clear();
      }
      _qty.text = '100';
    });
  }

  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    final pending = _buildItem();
    final all = [..._items, if (pending != null) pending];
    if (all.isEmpty) {
      AppSnackBar.show(context, 'Adicione ao menos um alimento.',
          type: SnackType.warning);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(nutritionControllerProvider.notifier)
          .addMeal(type: _type, items: all);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.show(context, 'Não foi possível salvar a refeição.',
          type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _items.fold(MacroNutrients.zero, (s, i) => s + i.macros);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nova refeição', style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.m),
            DropdownButtonFormField<MealType>(
              value: _type,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Refeição'),
              items: [
                for (final t in MealType.values)
                  DropdownMenuItem(value: t, child: Text(t.label)),
              ],
              onChanged: (t) => setState(() => _type = t ?? _type),
            ),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: ListView(
                children: [
                  for (final it in _items)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(it.name, style: AppTypography.body),
                      subtitle: Text(
                        '${it.macros.calories.toStringAsFixed(0)} kcal · '
                        'P ${it.macros.protein.toStringAsFixed(0)}g',
                        style: AppTypography.small,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _items.remove(it)),
                      ),
                    ),
                  VisTextField(label: 'Alimento', controller: _name),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      Expanded(child: _num('Qtd (g)', _qty)),
                      const SizedBox(width: 8),
                      Expanded(child: _num('Calorias', _kcal)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      Expanded(child: _num('Proteína', _protein)),
                      const SizedBox(width: 8),
                      Expanded(child: _num('Carbo', _carbs)),
                      const SizedBox(width: 8),
                      Expanded(child: _num('Gordura', _fats)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  SecondaryButton(
                    label: 'Adicionar item',
                    onPressed: _addItem,
                  ),
                ],
              ),
            ),
            if (_items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Total: ${total.calories.toStringAsFixed(0)} kcal · '
                  'P ${total.protein.toStringAsFixed(0)}g',
                  style: AppTypography.caption,
                ),
              ),
            PrimaryButton(
                label: 'Salvar refeição', isLoading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }

  Widget _num(String label, TextEditingController c) => VisTextField(
        label: label,
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );
}
DARTEOF_MEALSHEET

echo "    - lib/features/nutrition/presentation/nutrition_screen.dart"
cat > lib/features/nutrition/presentation/nutrition_screen.dart <<'DARTEOF_NUTRISCREEN'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/nutrition_enums.dart';
import '../models/macro_nutrients.dart';
import '../models/nutrition_goal.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/add_meal_sheet.dart';

/// Tela de nutrição — resumo do dia, água e refeições (PROMPT 10).
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(nutritionControllerProvider);
    final goal = ref.watch(nutritionGoalProvider);
    final macros = day.macros;

    return Scaffold(
      appBar: const VisAppBar(title: 'Nutrição', accent: AppColors.accentGreen),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddMealSheet.show(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Refeição'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          _summary(macros, goal),
          const SizedBox(height: AppSpacing.m),
          _water(context, ref, day.waterMl, goal.waterMl ?? 2500),
          const SizedBox(height: AppSpacing.m),
          Text('Refeições de hoje', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          if (day.meals.isEmpty)
            Text('Nenhuma refeição registrada hoje.',
                style: AppTypography.caption)
          else
            for (final m in day.meals)
              CardContainer(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(LucideIcons.utensils,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.type.label, style: AppTypography.body),
                          Text(
                            m.items.map((i) => i.name).join(', '),
                            style: AppTypography.small,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text('${m.macros.calories.toStringAsFixed(0)} kcal',
                        style: AppTypography.small),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _summary(MacroNutrients macros, NutritionGoal goal) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumo do dia', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          _bar('Calorias', macros.calories, goal.calories ?? 2200, 'kcal',
              AppColors.primary),
          _bar('Proteína', macros.protein, goal.protein ?? 140, 'g',
              AppColors.success),
          _bar('Carboidrato', macros.carbs, goal.carbs ?? 250, 'g',
              AppColors.warning),
          _bar('Gordura', macros.fats, goal.fats ?? 70, 'g', AppColors.secondary),
        ],
      ),
    );
  }

  Widget _bar(
    String label,
    double current,
    double goal,
    String unit,
    Color color,
  ) {
    final progress = goal <= 0 ? 0.0 : (current / goal).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTypography.body)),
              Text('${current.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit',
                  style: AppTypography.small),
            ],
          ),
          const SizedBox(height: 4),
          VisProgressBar(value: progress, color: color),
        ],
      ),
    );
  }

  Widget _water(BuildContext context, WidgetRef ref, int current, int goal) {
    final progress = goal <= 0 ? 0.0 : (current / goal).clamp(0.0, 1.0);
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.droplet, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Água', style: AppTypography.subtitle)),
              Text('$current / $goal ml', style: AppTypography.small),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          VisProgressBar(value: progress, color: AppColors.primary),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: 8,
            children: [
              for (final w in WaterContainer.values)
                ActionChip(
                  label: Text(w.label),
                  onPressed: () => ref
                      .read(nutritionControllerProvider.notifier)
                      .addWater(w.ml),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
DARTEOF_NUTRISCREEN

echo "    - lib/features/cardio/presentation/cardio_screen.dart"
cat > lib/features/cardio/presentation/cardio_screen.dart <<'DARTEOF_CARDIOSCREEN'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/cardio_session.dart';
import '../models/cardio_stats.dart';
import '../providers/cardio_providers.dart';
import '../widgets/add_cardio_sheet.dart';

/// Módulo de cardio: resumo, recordes e histórico (PROMPT 09).
class CardioScreen extends ConsumerWidget {
  const CardioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(cardioControllerProvider);
    final repo = ref.watch(cardioRepositoryProvider);
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final week = repo.statsSince(startOfWeek);
    final records = repo.records();

    return Scaffold(
      appBar: const VisAppBar(title: 'Cardio', accent: AppColors.accentOrange),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddCardioSheet.show(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Registrar cardio'),
      ),
      body: sessions.isEmpty
          ? const EmptyState(
              icon: LucideIcons.heartPulse,
              title: 'Nenhum cardio registrado',
              description: 'Registre suas atividades para acompanhar.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.m),
              children: [
                _WeeklyCard(stats: week),
                const SizedBox(height: AppSpacing.m),
                _RecordsCard(records: records),
                const SizedBox(height: AppSpacing.m),
                Text('Histórico', style: AppTypography.subtitle),
                const SizedBox(height: AppSpacing.s),
                for (final s in sessions.take(20)) _SessionRow(session: s),
              ],
            ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.stats});
  final CardioStats stats;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Esta semana', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            runSpacing: AppSpacing.m,
            children: [
              _metric('Sessões', '${stats.sessions}'),
              _metric('Tempo', '${stats.totalMinutes} min'),
              _metric('Distância', '${stats.totalDistance.toStringAsFixed(1)} km'),
              _metric('Calorias', '${stats.totalCalories.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) => SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.title),
            Text(label, style: AppTypography.small),
          ],
        ),
      );
}

class _RecordsCard extends StatelessWidget {
  const _RecordsCard({required this.records});
  final CardioRecords records;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      if (records.maxDistanceKm != null)
        ('Maior distância', '${records.maxDistanceKm!.toStringAsFixed(1)} km'),
      if (records.maxDurationSeconds != null)
        ('Maior tempo', '${(records.maxDurationSeconds! / 60).round()} min'),
      if (records.maxSpeedKmh != null)
        ('Maior velocidade', '${records.maxSpeedKmh!.toStringAsFixed(1)} km/h'),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recordes', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(it.$1, style: AppTypography.body)),
                  Text(it.$2,
                      style: AppTypography.body
                          .copyWith(color: AppColors.primary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});
  final CardioSession session;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      '${session.minutes} min',
      if (session.distanceKm != null)
        '${session.distanceKm!.toStringAsFixed(1)} km',
      if (session.paceLabel != null) session.paceLabel!,
      if (session.calories != null) '${session.calories!.toStringAsFixed(0)} kcal',
    ];
    return CardContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(LucideIcons.heartPulse, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.type.label, style: AppTypography.body),
                Text(parts.join(' · '), style: AppTypography.small),
              ],
            ),
          ),
          Text(_date(session.performedAt), style: AppTypography.small),
        ],
      ),
    );
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}
DARTEOF_CARDIOSCREEN

echo "    - lib/features/ai_workout/data/local_ai_workout_service.dart"
cat > lib/features/ai_workout/data/local_ai_workout_service.dart <<'DARTEOF_LOCALAISVC'
import 'dart:math';

import '../../ai/domain/ai_context.dart';
import '../../exercise/data/exercise_catalog_seed.dart';
import '../../exercise/domain/exercise_enums.dart';
import '../../exercise/models/exercise.dart';
import '../domain/ai_workout_enums.dart';
import '../models/generated_workout.dart';
import '../models/generation_result.dart';
import '../models/workout_request.dart';
import '../services/ai_workout_service.dart';

/// Gerador de treino LOCAL (sem IA paga / sem internet obrigatória).
///
/// Monta um treino real e equilibrado a partir do catálogo de exercícios
/// do próprio app, respeitando objetivo, dias por semana, tempo, local,
/// nível e exercícios que o usuário evita. Substitui a Edge Function de IA.
final class LocalAIWorkoutService implements IAIWorkoutService {
  LocalAIWorkoutService([Random? random]) : _rng = random ?? Random();

  final Random _rng;

  @override
  Future<WorkoutGenerationResult> generate({
    required WorkoutRequest request,
    required AIContext context,
  }) async {
    final split = _splitFor(request.daysPerWeek);
    final days = _buildDays(request);
    final workout = GeneratedWorkout(
      name: '${request.goal.label} • ${split.label}',
      goal: request.goal,
      split: split,
      days: days,
      notes:
          'Treino montado automaticamente pelo VIS a partir da sua biblioteca '
          'de exercícios. Ajuste as cargas conforme sua evolução.',
    );
    return WorkoutGenerationResult(
      workout: workout,
      estimatedMinutes: request.minutesPerWorkout,
      recommendations: _recommendations(request, split),
    );
  }

  @override
  Future<GeneratedExercise> regenerateExercise({
    required WorkoutRequest request,
    required AIContext context,
    required String dayName,
    required String exerciseName,
  }) async {
    final matches =
        ExerciseCatalogSeed.all.where((e) => e.name == exerciseName).toList();
    final muscles =
        matches.isNotEmpty ? [matches.first.primaryMuscle] : _allMuscles;
    final pool = <Exercise>[];
    for (final m in muscles) {
      pool.addAll(_candidatesForMuscle(request, m));
    }
    final options = pool.where((e) => e.name != exerciseName).toList();
    final chosen = options.isNotEmpty
        ? options[_rng.nextInt(options.length)]
        : (matches.isNotEmpty ? matches.first : ExerciseCatalogSeed.all.first);
    return _toGenerated(chosen, request);
  }

  @override
  Future<GeneratedWorkoutDay> regenerateDay({
    required WorkoutRequest request,
    required AIContext context,
    required String dayName,
  }) async {
    final days = _buildDays(request);
    final target = dayName.toLowerCase();
    for (final d in days) {
      if (d.name.toLowerCase() == target ||
          (target.isNotEmpty && d.name.toLowerCase().contains(target))) {
        return d;
      }
    }
    return days.isNotEmpty
        ? days.first
        : const GeneratedWorkoutDay(name: 'Treino', exercises: []);
  }

  // ---------------------------------------------------------------------
  // Montagem
  // ---------------------------------------------------------------------
  List<GeneratedWorkoutDay> _buildDays(WorkoutRequest request) {
    final templates = _dayTemplates(request.daysPerWeek);
    final perDay = _exercisesPerDay(request);
    return [
      for (final t in templates)
        GeneratedWorkoutDay(
          name: t.name,
          focus: t.focus,
          warmup: const [
            '5 min de aquecimento leve (esteira, bike ou polichinelo)',
            'Séries de aproximação no primeiro exercício',
          ],
          exercises: [
            for (final e in _pickForDay(request, t.muscles, perDay))
              _toGenerated(e, request),
          ],
        ),
    ];
  }

  List<Exercise> _pickForDay(
    WorkoutRequest req,
    List<String> muscles,
    int perDay,
  ) {
    final chosen = <Exercise>[];
    final used = <String>{};

    // 1) Um exercício por músculo (composto primeiro).
    for (final m in muscles) {
      if (chosen.length >= perDay) break;
      final cands = _candidatesForMuscle(req, m)
        ..sort(_compoundFirst);
      final fresh = cands.where((e) => !used.contains(e.name)).toList();
      if (fresh.isNotEmpty) {
        chosen.add(fresh.first);
        used.add(fresh.first.name);
      }
    }

    // 2) Completa até o alvo, variando entre os músculos do dia.
    var guard = 0;
    var i = 0;
    while (chosen.length < perDay && guard < muscles.length * 4) {
      final m = muscles[i % muscles.length];
      final fresh = _candidatesForMuscle(req, m)
          .where((e) => !used.contains(e.name))
          .toList();
      if (fresh.isNotEmpty) {
        final e = fresh[_rng.nextInt(fresh.length)];
        chosen.add(e);
        used.add(e.name);
      }
      i++;
      guard++;
    }
    return chosen;
  }

  List<Exercise> _candidatesForMuscle(WorkoutRequest req, String muscle) {
    var list =
        ExerciseCatalogSeed.all.where((e) => e.primaryMuscle == muscle).toList();

    // Local: em casa, prioriza o que dá pra fazer em casa (se houver).
    if (req.location == WorkoutLocation.home) {
      final home = list.where(_isHomeFriendly).toList();
      if (home.isNotEmpty) list = home;
    }

    // Remove exercícios que o usuário pediu para evitar.
    final disliked = req.preferences.dislikedExercises
        .map((e) => e.toLowerCase().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (disliked.isNotEmpty) {
      list = list
          .where((e) => !disliked.any((d) => e.name.toLowerCase().contains(d)))
          .toList();
    }
    return list;
  }

  bool _isHomeFriendly(Exercise e) {
    if (e.homeCompatible) return true;
    const homeEquip = {
      Equipments.bodyweight,
      Equipments.dumbbell,
      Equipments.band,
      Equipments.kettlebell,
    };
    return homeEquip.contains(e.equipment);
  }

  int _compoundFirst(Exercise a, Exercise b) {
    int rank(Exercise e) => e.type == ExerciseType.compound ? 0 : 1;
    return rank(a).compareTo(rank(b));
  }

  GeneratedExercise _toGenerated(Exercise e, WorkoutRequest req) {
    final rx = _prescription(req);
    final isIso = e.type == ExerciseType.isolation;
    return GeneratedExercise(
      name: e.name,
      muscleGroup: e.primaryMuscle,
      sets: isIso ? rx.isoSets : rx.sets,
      targetReps: rx.reps,
      equipment: e.equipment,
      suggestedRpe: rx.rpe,
      restSeconds: rx.rest,
      notes: e.tips.isNotEmpty ? e.tips.first : null,
    );
  }

  int _exercisesPerDay(WorkoutRequest req) {
    var n = (req.minutesPerWorkout / 11).round();
    if (req.experience == WorkoutExperience.beginner && n > 6) n = 6;
    return n.clamp(4, 8);
  }

  _Rx _prescription(WorkoutRequest req) {
    final adv = req.experience == WorkoutExperience.advanced;
    final beg = req.experience == WorkoutExperience.beginner;
    final base = beg ? 3 : (adv ? 4 : 3);
    switch (req.goal) {
      case WorkoutGoal.strength:
        return _Rx(base + 1, base, '4-6', 150, 8);
      case WorkoutGoal.hypertrophy:
        return _Rx(base, max(2, base - 1), '8-12', 75, 8);
      case WorkoutGoal.weightLoss:
        return _Rx(base, base, '12-15', 45, 7);
      case WorkoutGoal.endurance:
        return _Rx(base, base, '15-20', 40, 7);
      case WorkoutGoal.conditioning:
        return _Rx(base, base, '12-15', 45, 7);
      case WorkoutGoal.health:
        return _Rx(max(2, base - 1), max(2, base - 1), '10-12', 60, 6);
      case WorkoutGoal.custom:
        return _Rx(base, base, '8-12', 75, 7);
    }
  }

  List<WorkoutRecommendation> _recommendations(
    WorkoutRequest req,
    WorkoutSplit split,
  ) {
    return [
      WorkoutRecommendation(
        message: 'Divisão ${split.label} para ${req.daysPerWeek}x na semana.',
        reason: 'Equilibra volume e recuperação para o seu número de dias.',
      ),
      WorkoutRecommendation(
        message: 'Faixa de ${_prescription(req).reps} repetições por série.',
        reason:
            'É a faixa mais indicada para o objetivo de ${req.goal.label.toLowerCase()}.',
      ),
      if (req.location == WorkoutLocation.home)
        const WorkoutRecommendation(
          message: 'Exercícios priorizando o que dá para fazer em casa.',
          reason: 'Preferimos peso corporal, halteres e elásticos.',
        ),
    ];
  }

  WorkoutSplit _splitFor(int days) {
    switch (days.clamp(1, 6)) {
      case 1:
      case 2:
        return WorkoutSplit.fullBody;
      case 3:
        return WorkoutSplit.abc;
      case 4:
        return WorkoutSplit.abcd;
      case 5:
        return WorkoutSplit.abcde;
      default:
        return WorkoutSplit.pushPullLegs;
    }
  }

  static String _letter(int i) => String.fromCharCode(65 + i);

  List<_DayTpl> _dayTemplates(int daysRaw) {
    final days = daysRaw.clamp(1, 6);
    const push = [
      Muscles.chest,
      Muscles.frontDelts,
      Muscles.sideDelts,
      Muscles.triceps,
    ];
    const pull = [
      Muscles.lats,
      Muscles.back,
      Muscles.traps,
      Muscles.rearDelts,
      Muscles.biceps,
      Muscles.forearms,
    ];
    const legs = [
      Muscles.quads,
      Muscles.hamstrings,
      Muscles.glutes,
      Muscles.calves,
      Muscles.abs,
    ];
    const fullBody = [
      Muscles.quads,
      Muscles.chest,
      Muscles.lats,
      Muscles.hamstrings,
      Muscles.sideDelts,
      Muscles.biceps,
      Muscles.triceps,
      Muscles.abs,
    ];

    switch (days) {
      case 1:
      case 2:
        return [
          for (var i = 0; i < days; i++)
            _DayTpl('Treino ${_letter(i)} — Corpo inteiro', 'Full body',
                fullBody),
        ];
      case 3:
        return [
          _DayTpl('Treino A — Empurrar', 'Peito, ombro e tríceps', push),
          _DayTpl('Treino B — Puxar', 'Costas e bíceps', pull),
          _DayTpl('Treino C — Pernas', 'Pernas e core', legs),
        ];
      case 4:
        return [
          _DayTpl('Treino A — Superior', 'Peito, costas e braços',
              [Muscles.chest, Muscles.lats, Muscles.back, Muscles.biceps, Muscles.triceps]),
          _DayTpl('Treino B — Inferior', 'Pernas e glúteos',
              [Muscles.quads, Muscles.hamstrings, Muscles.glutes, Muscles.calves]),
          _DayTpl('Treino C — Superior', 'Ombros e braços',
              [Muscles.sideDelts, Muscles.frontDelts, Muscles.rearDelts, Muscles.biceps, Muscles.triceps, Muscles.chest]),
          _DayTpl('Treino D — Inferior', 'Pernas e core',
              [Muscles.quads, Muscles.hamstrings, Muscles.glutes, Muscles.calves, Muscles.abs, Muscles.obliques]),
        ];
      case 5:
        return [
          _DayTpl('Treino A — Peito', 'Peito e tríceps',
              [Muscles.chest, Muscles.triceps]),
          _DayTpl('Treino B — Costas', 'Costas e bíceps',
              [Muscles.lats, Muscles.back, Muscles.traps, Muscles.biceps, Muscles.forearms]),
          _DayTpl('Treino C — Pernas', 'Pernas e glúteos',
              [Muscles.quads, Muscles.hamstrings, Muscles.glutes, Muscles.calves]),
          _DayTpl('Treino D — Ombros', 'Ombros e trapézio',
              [Muscles.sideDelts, Muscles.frontDelts, Muscles.rearDelts, Muscles.traps]),
          _DayTpl('Treino E — Braços e core', 'Braços e abdômen',
              [Muscles.biceps, Muscles.triceps, Muscles.forearms, Muscles.abs, Muscles.obliques]),
        ];
      default:
        return [
          _DayTpl('Treino A — Empurrar', 'Peito, ombro e tríceps', push),
          _DayTpl('Treino B — Puxar', 'Costas e bíceps', pull),
          _DayTpl('Treino C — Pernas', 'Pernas e core', legs),
          _DayTpl('Treino D — Empurrar', 'Peito, ombro e tríceps', push),
          _DayTpl('Treino E — Puxar', 'Costas e bíceps', pull),
          _DayTpl('Treino F — Pernas', 'Pernas e core', legs),
        ];
    }
  }

  static const List<String> _allMuscles = [
    Muscles.chest,
    Muscles.back,
    Muscles.lats,
    Muscles.traps,
    Muscles.frontDelts,
    Muscles.sideDelts,
    Muscles.rearDelts,
    Muscles.biceps,
    Muscles.triceps,
    Muscles.forearms,
    Muscles.abs,
    Muscles.obliques,
    Muscles.lowerBack,
    Muscles.glutes,
    Muscles.quads,
    Muscles.hamstrings,
    Muscles.calves,
  ];
}

/// Modelo de um dia do treino (nome, foco e músculos-alvo em prioridade).
class _DayTpl {
  const _DayTpl(this.name, this.focus, this.muscles);
  final String name;
  final String focus;
  final List<String> muscles;
}

/// Prescrição de séries/repetições/descanso.
class _Rx {
  const _Rx(this.sets, this.isoSets, this.reps, this.rest, this.rpe);
  final int sets;
  final int isoSets;
  final String reps;
  final int rest;
  final double rpe;
}
DARTEOF_LOCALAISVC

echo "    - lib/features/ai_workout/providers/ai_workout_providers.dart"
cat > lib/features/ai_workout/providers/ai_workout_providers.dart <<'DARTEOF_AIWKPROV'
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/connection_provider.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/supabase/supabase_provider.dart';
import '../../ai/providers/ai_providers.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../controllers/ai_workout_controller.dart';
import '../data/ai_workout_repository_impl.dart';
import '../data/local_ai_workout_service.dart';
import '../repositories/ai_workout_repository.dart';
import '../services/ai_workout_service.dart';

/// Re-exporta o contrato para consumidores do controller.
export '../repositories/ai_workout_repository.dart' show AIWorkoutRepository;

/// Providers do gerador de treinos (PROMPT 12).

// Gerador LOCAL (grátis, sem IA paga). Para voltar à IA via Edge Function,
// troque por: EdgeFunctionAIWorkoutService(ref.watch(edgeFunctionsServiceProvider)).
final aiWorkoutServiceProvider = Provider<IAIWorkoutService>(
  (ref) => LocalAIWorkoutService(),
);

final aiWorkoutRepositoryProvider = Provider<AIWorkoutRepository>((ref) {
  return AIWorkoutRepositoryImpl(
    service: ref.watch(aiWorkoutServiceProvider),
    database: ref.watch(databaseServiceProvider),
    storage: const LocalStorageService(),
    connection: ref.watch(connectionCheckerProvider),
    buildContext: ref.watch(aiContextBuilderProvider),
    currentUserId: () =>
        ref.read(authenticationRepositoryProvider).currentUser?.id,
  );
});

final aiWorkoutControllerProvider =
    NotifierProvider<AIWorkoutController, AIWorkoutState>(
  AIWorkoutController.new,
);
DARTEOF_AIWKPROV

echo "    - lib/features/dashboard/presentation/dashboard_sections.dart"
cat > lib/features/dashboard/presentation/dashboard_sections.dart <<'DARTEOF_DASHSECT'
part of 'dashboard_screen.dart';

/// Cartões do Dashboard extraídos de dashboard_screen.dart (mantidos
/// privados via `part`; compartilham os imports da biblioteca).

class _NextWorkoutCard extends ConsumerWidget {
  const _NextWorkoutCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final up = data.upcoming;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.dumbbell, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Próximo treino', style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          if (up == null)
            Text('Você ainda não tem um treino ativo.',
                style: AppTypography.body)
          else ...[
            Text('${up.dayName} · ${up.planName}',
                style: AppTypography.subtitle),
            const SizedBox(height: 4),
            Text(
              '${up.exerciseCount} exercícios'
              '${up.muscleGroups.isNotEmpty ? ' · ${up.muscleGroups.take(3).join(', ')}' : ''}',
              style: AppTypography.caption,
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          PrimaryButton(
            label: up == null ? 'Criar treino' : 'Iniciar treino',
            icon: up == null ? LucideIcons.plus : LucideIcons.play,
            onPressed: () {
              if (data.activePlan != null) {
                context.pushNamed('workout-detail', extra: data.activePlan);
              } else {
                context.goNamed('workout');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SequenceCard extends StatelessWidget {
  const _SequenceCard({required this.sequence});
  final TrainingSequence sequence;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Row(
        children: [
          Text('🔥', style: AppTypography.display.copyWith(fontSize: 34)),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${sequence.current} dias em sequência',
                    style: AppTypography.subtitle),
                Text(
                  'Maior sequência: ${sequence.longest} · '
                  'Semana: ${sequence.weekCount}/${sequence.weekGoal}',
                  style: AppTypography.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutsRow extends StatelessWidget {
  const _ShortcutsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _shortcut(context, LucideIcons.heartPulse, 'Cardio', 'cardio'),
        const SizedBox(width: AppSpacing.s),
        _shortcut(context, LucideIcons.utensils, 'Nutrição', 'nutrition'),
        const SizedBox(width: AppSpacing.s),
        _shortcut(context, LucideIcons.zap, 'Treino IA', 'ai-workout'),
      ],
    );
  }

  Widget _shortcut(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return Expanded(
      child: CardContainer(
        onTap: () => context.pushNamed(route),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label, style: AppTypography.small, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({
    required this.sequence,
    this.cardioMinutes = 0,
    this.todayProtein = 0,
    this.todayWaterMl = 0,
  });
  final TrainingSequence sequence;
  final int cardioMinutes;
  final double todayProtein;
  final int todayWaterMl;

  @override
  Widget build(BuildContext context) {
    final goal = sequence.weekGoal == 0 ? 1 : sequence.weekGoal;
    final progress = (sequence.weekCount / goal).clamp(0.0, 1.0);
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Objetivos da semana', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Expanded(child: Text('Treinos', style: AppTypography.body)),
              Text('${sequence.weekCount} / ${sequence.weekGoal}',
                  style: AppTypography.body),
            ],
          ),
          const SizedBox(height: 6),
          VisProgressBar(value: progress, color: AppColors.success),
          const SizedBox(height: AppSpacing.s),
          Text(
            _summaryLine(),
            style: AppTypography.small,
          ),
        ],
      ),
    );
  }

  String _summaryLine() {
    final parts = <String>[
      if (cardioMinutes > 0) 'Cardio $cardioMinutes min',
      if (todayProtein > 0) 'Proteína ${todayProtein.toStringAsFixed(0)}g hoje',
      if (todayWaterMl > 0) 'Água ${todayWaterMl}ml hoje',
    ];
    return parts.isEmpty
        ? 'Cardio, peso e proteína aparecem quando você registrar.'
        : parts.join(' · ');
  }
}

class _EvolutionCard extends StatelessWidget {
  const _EvolutionCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      onTap: () => context.goNamed('progress'),
      child: Row(
        children: [
          const Icon(LucideIcons.trendingUp, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Evolução corporal', style: AppTypography.subtitle),
                Text(
                  data.latestWeight != null
                      ? 'Peso atual: ${data.latestWeight!.toStringAsFixed(1)} kg'
                      : 'Registre seu peso, medidas e fotos.',
                  style: AppTypography.small,
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.weekly});
  final WeeklyStats weekly;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Resumo semanal',
      child: Wrap(
        runSpacing: AppSpacing.m,
        children: [
          _metric('Treinos', '${weekly.workouts}'),
          _metric('Tempo', '${weekly.totalMinutes} min'),
          _metric('Volume', '${weekly.totalVolume.toStringAsFixed(0)} kg'),
          _metric('Séries', '${weekly.totalSets}'),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) => SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.title),
            Text(label, style: AppTypography.small),
          ],
        ),
      );
}

class _CalendarStrip extends StatelessWidget {
  const _CalendarStrip({required this.activity});
  final List<RecentActivity> activity;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final trained = activity
        .map((a) => DateTime(a.date.year, a.date.month, a.date.day))
        .toSet();
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return _SectionCard(
      title: 'Calendário',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 7; i++)
            _day(
              labels[i],
              startOfWeek.add(Duration(days: i)),
              trained,
              now,
            ),
        ],
      ),
    );
  }

  Widget _day(String label, DateTime date, Set<DateTime> trained, DateTime now) {
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final didTrain = trained.contains(date);
    return Column(
      children: [
        Text(label, style: AppTypography.small),
        const SizedBox(height: 6),
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: didTrain ? AppColors.primary : AppColors.card,
            border: isToday
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Text('${date.day}',
              style: AppTypography.small.copyWith(
                color: didTrain ? AppColors.onPrimary : AppColors.textSecondary,
              )),
        ),
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.activity});
  final List<RecentActivity> activity;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Últimos treinos',
      child: activity.isEmpty
          ? Text('Nenhum treino ainda.', style: AppTypography.caption)
          : Column(
              children: [
                for (final a in activity.take(5))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.checkCircle2,
                            size: 18, color: AppColors.success),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.title, style: AppTypography.body),
                              if (a.subtitle != null)
                                Text(a.subtitle!, style: AppTypography.small),
                            ],
                          ),
                        ),
                        Text(_date(a.date), style: AppTypography.small),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          child,
        ],
      ),
    );
  }
}
DARTEOF_DASHSECT

echo "    - lib/features/dashboard/presentation/dashboard_screen.dart"
cat > lib/features/dashboard/presentation/dashboard_screen.dart <<'DARTEOF_DASHSCREEN'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../models/dashboard_data.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/muscle_volume_bars.dart';

part 'dashboard_sections.dart';

/// Dashboard Inteligente — primeira tela após o login (PROMPT 07).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardControllerProvider);
    final name = ref.watch(currentUserProvider).value?.name?.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting(name),
                style: AppTypography.subtitle.copyWith(color: Colors.white)),
            Text(_todayLabel(),
                style: AppTypography.small.copyWith(color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () => context.pushNamed('notifications'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const DashboardSkeleton(),
        error: (_, __) => ErrorState(
          onRetry: () =>
              ref.read(dashboardControllerProvider.notifier).refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: _cards(context, ref, data),
          ),
        ),
      ),
    );
  }

  List<Widget> _cards(BuildContext context, WidgetRef ref, DashboardData d) {
    return [
      if (d.insight != null) ...[
        InsightCard(
          message: '${d.insight!.message}'
              '${d.insight!.reason != null ? '\n\n${d.insight!.reason}' : ''}',
          onDetails: () => context.pushNamed('insights'),
        ),
        const SizedBox(height: AppSpacing.m),
      ],
      _NextWorkoutCard(data: d),
      const SizedBox(height: AppSpacing.m),
      const _ShortcutsRow(),
      const SizedBox(height: AppSpacing.m),
      _SequenceCard(sequence: d.sequence),
      const SizedBox(height: AppSpacing.m),
      _GoalsCard(
        sequence: d.sequence,
        cardioMinutes: d.weeklyCardioMinutes,
        todayProtein: d.todayProtein,
        todayWaterMl: d.todayWaterMl,
      ),
      const SizedBox(height: AppSpacing.m),
      _EvolutionCard(data: d),
      const SizedBox(height: AppSpacing.m),
      _WeeklyCard(weekly: d.weekly),
      const SizedBox(height: AppSpacing.m),
      _CalendarStrip(activity: d.recentActivity),
      const SizedBox(height: AppSpacing.m),
      _SectionCard(
        title: 'Volume muscular (30 dias)',
        child: MuscleVolumeBars(data: d.muscleVolume),
      ),
      const SizedBox(height: AppSpacing.m),
      _RecentCard(activity: d.recentActivity),
    ];
  }

  String _greeting(String? name) {
    final h = DateTime.now().hour;
    final part = h < 12 ? 'Bom dia' : (h < 18 ? 'Boa tarde' : 'Boa noite');
    return name == null ? '$part 👋' : '$part, $name 👋';
  }

  String _todayLabel() {
    const days = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];
    return 'Hoje é ${days[DateTime.now().weekday - 1]}.';
  }
}

DARTEOF_DASHSCREEN

echo "    - lib/features/ai_workout/presentation/ai_workout_screen.dart"
cat > lib/features/ai_workout/presentation/ai_workout_screen.dart <<'DARTEOF_AIWKSCREEN'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../onboarding/domain/onboarding_options.dart';
import '../../workout/widgets/exercise_picker_sheet.dart';
import '../controllers/ai_workout_controller.dart';
import '../domain/ai_workout_enums.dart';
import '../models/generated_workout.dart';
import '../providers/ai_workout_providers.dart';
import '../widgets/generated_workout_view.dart';

/// Gerador Inteligente de Treinos (PROMPT 12).
class AIWorkoutScreen extends ConsumerWidget {
  const AIWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiWorkoutControllerProvider);
    final c = ref.read(aiWorkoutControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerar treino com IA'),
        leading: state.phase == GenerationPhase.result
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: c.backToForm,
              )
            : null,
      ),
      body: switch (state.phase) {
        GenerationPhase.form => _Form(state: state, c: c),
        GenerationPhase.generating => const LoadingWidget(
            message: 'Montando seu treino com base no seu histórico...',
          ),
        GenerationPhase.error => ErrorState(
            message: state.error ?? 'Não foi possível gerar o treino.',
            onRetry: c.backToForm,
          ),
        GenerationPhase.result => _Result(state: state, c: c),
      },
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.state, required this.c});
  final AIWorkoutState state;
  final AIWorkoutController c;

  @override
  Widget build(BuildContext context) {
    final r = state.request;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        _group(
          'Objetivo',
          [
            for (final g in WorkoutGoal.values)
              VisChip(
                label: g.label,
                selected: r.goal == g,
                onTap: () => c.setGoal(g),
              ),
          ],
        ),
        _group(
          'Dias por semana',
          [
            for (final d in const [2, 3, 4, 5, 6, 7])
              VisChip(
                label: '$d',
                selected: r.daysPerWeek == d,
                onTap: () => c.setDays(d),
              ),
          ],
        ),
        _group(
          'Tempo por treino',
          [
            for (final m in const [30, 45, 60, 75, 90])
              VisChip(
                label: '$m min',
                selected: r.minutesPerWorkout == m,
                onTap: () => c.setMinutes(m),
              ),
          ],
        ),
        _group(
          'Onde treina',
          [
            for (final l in WorkoutLocation.values)
              VisChip(
                label: l.label,
                selected: r.location == l,
                onTap: () => c.setLocation(l),
              ),
          ],
        ),
        _group(
          'Experiência',
          [
            for (final e in WorkoutExperience.values)
              VisChip(
                label: e.label,
                selected: r.experience == e,
                onTap: () => c.setExperience(e),
              ),
          ],
        ),
        _group(
          'Equipamentos disponíveis',
          [
            for (final eq in OnboardingOptions.equipment)
              VisChip(
                label: eq,
                selected: r.equipment.contains(eq),
                onTap: () => c.toggleEquipment(eq),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.m),
          child: VisTextField(
            label: 'Lesões / limitações (opcional)',
            hint: 'ex.: dor no ombro, cirurgia no joelho',
            onChanged: c.setRestrictionNotes,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.m),
          child: VisTextField(
            label: 'Exercícios que você evita (opcional)',
            hint: 'ex.: agachamento, barra fixa',
            onChanged: c.setAvoidExercises,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        PrimaryButton(
          label: 'Gerar treino',
          icon: Icons.auto_awesome,
          onPressed: c.generate,
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          'O VIS monta o treino a partir dos seus objetivos, tempo, nível e equipamentos.',
          style: AppTypography.small,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _group(String title, List<Widget> chips) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.s),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
          ],
        ),
      );
}

class _Result extends StatelessWidget {
  const _Result({required this.state, required this.c});
  final AIWorkoutState state;
  final AIWorkoutController c;

  @override
  Widget build(BuildContext context) {
    final result = state.result!;
    final workout = state.workout!;
    return Column(
      children: [
        Expanded(
          child: GeneratedWorkoutView(
            result: result,
            workout: workout,
            onRename: c.renameWorkout,
            onExerciseChanged: c.updateExercise,
            onExerciseRemoved: c.removeExercise,
            onRegenerate: c.regenerateExercise,
            onAddExercise: (dayIndex) async {
              final ref = await ExercisePickerSheet.show(context);
              if (ref != null) {
                c.addExercise(
                  dayIndex,
                  GeneratedExercise(
                    name: ref.name,
                    muscleGroup: ref.muscleGroup,
                    sets: 3,
                    targetReps: '8-12',
                    equipment: ref.equipment,
                    restSeconds: 90,
                  ),
                );
              }
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Avaliar',
                    onPressed: () => _feedback(context, c),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: PrimaryButton(
                    label: 'Salvar treino',
                    isLoading: state.isSaving,
                    onPressed: () async {
                      final ok = await c.save();
                      if (ok && context.mounted) {
                        AppSnackBar.show(context, 'Treino salvo!',
                            type: SnackType.success);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _feedback(BuildContext context, AIWorkoutController c) async {
    GenerationRating? selected;
    final comment = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.l,
            right: AppSpacing.l,
            top: AppSpacing.l,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Como foi o treino?', style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.m),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in GenerationRating.values)
                    VisChip(
                      label: r.label,
                      selected: selected == r,
                      onTap: () => setModalState(() => selected = r),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              VisTextField(
                label: 'Comentário (opcional)',
                controller: comment,
              ),
              const SizedBox(height: AppSpacing.l),
              PrimaryButton(
                label: 'Enviar avaliação',
                onPressed: selected == null
                    ? null
                    : () {
                        c.submitFeedback(selected!, comment.text.trim());
                        Navigator.pop(ctx);
                        AppSnackBar.show(context, 'Obrigado pela avaliação!',
                            type: SnackType.success);
                      },
              ),
            ],
          ),
        ),
      ),
    );
    comment.dispose();
  }
}
DARTEOF_AIWKSCREEN

echo "    - lib/features/workout_session/presentation/workout_session_screen.dart"
cat > lib/features/workout_session/presentation/workout_session_screen.dart <<'DARTEOF_SESSIONSCREEN'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../controllers/workout_session_controller.dart';
import '../domain/session_enums.dart';
import '../providers/workout_session_providers.dart';
import '../widgets/rest_timer_bar.dart';
import '../widgets/session_set_row.dart';

String formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

/// Tela de execução do treino (PROMPT 06).
class WorkoutSessionScreen extends ConsumerWidget {
  const WorkoutSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActive =
        ref.watch(workoutSessionControllerProvider.select((s) => s.hasActive));
    final c = ref.read(workoutSessionControllerProvider.notifier);

    if (!hasActive) {
      return const Scaffold(
        body: EmptyState(
          icon: LucideIcons.dumbbell,
          title: 'Nenhum treino em andamento',
        ),
      );
    }

    final session = ref.read(workoutSessionControllerProvider).session!;
    final paused = ref.watch(
        workoutSessionControllerProvider.select((s) => s.session?.isPaused ?? false));

    return Scaffold(
      appBar: AppBar(
        title: Text(session.dayName),
        actions: [
          IconButton(
            icon: Icon(paused ? LucideIcons.play : LucideIcons.pause),
            tooltip: paused ? 'Retomar' : 'Pausar',
            onPressed: () => paused ? c.resume() : c.pause(),
          ),
          TextButton(
            onPressed: () => _finish(context, ref),
            child: const Text('Finalizar'),
          ),
        ],
      ),
      body: Column(
        children: [
          const _SessionHeader(),
          const Expanded(child: _ExerciseList()),
          const _RestBar(),
        ],
      ),
    );
  }

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    final c = ref.read(workoutSessionControllerProvider.notifier);
    WorkoutMood? mood;
    int? energy;
    final noteCtrl = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.l,
            right: AppSpacing.l,
            top: AppSpacing.l,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Como foi o treino?', style: AppTypography.subtitle),
              const SizedBox(height: 4),
              Text('Tudo aqui é opcional — ajuda o app a acompanhar sua recuperação.',
                  style: AppTypography.small),
              const SizedBox(height: AppSpacing.m),
              Text('Humor', style: AppTypography.caption),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in WorkoutMood.values)
                    VisChip(
                      label: m.label,
                      selected: mood == m,
                      onTap: () => setModal(() => mood = m),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Text('Energia', style: AppTypography.caption),
              const SizedBox(height: 2),
              Text('Quanta disposição você teve no treino? 1 = pouca · 5 = muita',
                  style: AppTypography.small),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (var i = 1; i <= 5; i++)
                    VisChip(
                      label: '$i',
                      selected: energy == i,
                      onTap: () => setModal(() => energy = i),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              VisTextField(label: 'Observações (opcional)', controller: noteCtrl),
              const SizedBox(height: AppSpacing.l),
              PrimaryButton(
                label: 'Concluir treino',
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) {
      noteCtrl.dispose();
      return;
    }
    final note = noteCtrl.text.trim();
    noteCtrl.dispose();
    final summary = await c.finish(
      mood: mood,
      energy: energy,
      notes: note.isEmpty ? null : note,
    );
    if (summary != null && context.mounted) {
      context.pushReplacementNamed('workout-summary', extra: summary);
    }
  }
}

class _SessionHeader extends ConsumerWidget {
  const _SessionHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsed = ref.watch(workoutSessionControllerProvider
        .select((s) => s.session?.elapsedSeconds ?? 0));
    final volume = ref.watch(workoutSessionControllerProvider
        .select((s) => s.session?.totalVolume ?? 0));
    final sets = ref.watch(workoutSessionControllerProvider
        .select((s) => s.session?.completedSets ?? 0));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metric(LucideIcons.clock, formatDuration(elapsed), 'Tempo'),
          _metric(LucideIcons.dumbbell, '${volume.toStringAsFixed(0)} kg', 'Volume'),
          _metric(LucideIcons.checkCheck, '$sets', 'Séries'),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label) => Column(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.subtitle),
          Text(label, style: AppTypography.small),
        ],
      );
}

class _ExerciseList extends ConsumerWidget {
  const _ExerciseList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(
        workoutSessionControllerProvider.select((s) => s.session?.exercises)) ??
        const [];
    final c = ref.read(workoutSessionControllerProvider.notifier);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: exercises.length,
      itemBuilder: (_, exIndex) {
        final ex = exercises[exIndex];
        return CardContainer(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(ex.exercise.name,
                        style: AppTypography.subtitle),
                  ),
                  Text('${ex.completedSets}/${ex.totalSets}',
                      style: AppTypography.small),
                ],
              ),
              Text(ex.exercise.muscleGroup, style: AppTypography.small),
              const SizedBox(height: 6),
              _ExerciseNoteField(
                key: ValueKey('note_${ex.id}'),
                initial: ex.note ?? '',
                onChanged: (v) => c.setExerciseNote(exIndex, v),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < ex.sets.length; i++)
                SessionSetRow(
                  key: ValueKey(ex.sets[i].id),
                  set: ex.sets[i],
                  onChanged: ({double? weight, int? reps}) =>
                      c.updateSet(exIndex, i, weight: weight, reps: reps),
                  onToggleDone: () => ex.sets[i].completed
                      ? c.uncompleteSet(exIndex, i)
                      : c.completeSet(exIndex, i),
                ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () => c.addSet(exIndex),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Adicionar série'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Campo de anotações do exercício (mantém o controller entre rebuilds da
/// lista, que acontecem a cada segundo do cronômetro).
class _ExerciseNoteField extends StatefulWidget {
  const _ExerciseNoteField({
    required this.initial,
    required this.onChanged,
    super.key,
  });

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_ExerciseNoteField> createState() => _ExerciseNoteFieldState();
}

class _ExerciseNoteFieldState extends State<_ExerciseNoteField> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      onChanged: widget.onChanged,
      minLines: 1,
      maxLines: 3,
      style: AppTypography.small,
      decoration: const InputDecoration(
        isDense: true,
        prefixIcon: Icon(LucideIcons.pencil, size: 16),
        hintText: 'Anotações (ex.: altura do banco, pegada…)',
      ),
    );
  }
}

class _RestBar extends ConsumerWidget {
  const _RestBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(
        workoutSessionControllerProvider.select((s) => s.restRemaining));
    if (remaining <= 0) return const SizedBox.shrink();
    final total =
        ref.watch(workoutSessionControllerProvider.select((s) => s.restTotal));
    final c = ref.read(workoutSessionControllerProvider.notifier);
    return RestTimerBar(
      remaining: remaining,
      total: total,
      onAdjust: c.addRest,
      onSkip: c.skipRest,
    );
  }
}
DARTEOF_SESSIONSCREEN

echo "    - lib/features/workout_session/controllers/workout_session_controller.dart"
cat > lib/features/workout_session/controllers/workout_session_controller.dart <<'DARTEOF_SESSIONCTRL'
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/providers/authentication_providers.dart';
import '../../workout/models/workout_day.dart';
import '../../workout/models/workout_plan.dart';
import '../domain/session_enums.dart';
import '../models/workout_exercise_session.dart';
import '../models/workout_session.dart';
import '../models/workout_set_session.dart';
import '../models/workout_summary.dart';
import '../providers/workout_session_providers.dart';

/// Estado de runtime da sessão: a sessão + o cronômetro de descanso.
class SessionState {
  const SessionState({
    this.session,
    this.restRemaining = 0,
    this.restTotal = 0,
  });

  final WorkoutSession? session;
  final int restRemaining;
  final int restTotal;

  bool get isResting => restRemaining > 0;
  bool get hasActive => session != null && !session!.isFinished;

  SessionState copyWith({
    WorkoutSession? session,
    int? restRemaining,
    int? restTotal,
  }) {
    return SessionState(
      session: session ?? this.session,
      restRemaining: restRemaining ?? this.restRemaining,
      restTotal: restTotal ?? this.restTotal,
    );
  }
}

/// Controller da execução de treino (PROMPT 06).
class WorkoutSessionController extends Notifier<SessionState> {
  final Uuid _uuid = const Uuid();
  Timer? _ticker;
  int _ticks = 0;

  @override
  SessionState build() {
    // Retoma uma sessão pausada/ativa persistida (sobrevive ao fechar o app).
    final active = ref.read(workoutSessionRepositoryProvider).loadActive();
    ref.onDispose(() => _ticker?.cancel());
    if (active != null) {
      _startTicker();
      return SessionState(session: active);
    }
    return const SessionState();
  }

  String _newId() => _uuid.v4();

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final s = state.session;
    if (s == null || s.isFinished) return;

    if (state.restRemaining > 0) {
      state = state.copyWith(
        restRemaining: state.restRemaining - 1,
        session: s.copyWith(restSeconds: s.restSeconds + 1),
      );
    } else if (!s.isPaused) {
      state = state.copyWith(
        session: s.copyWith(elapsedSeconds: s.elapsedSeconds + 1),
      );
    }

    if (++_ticks % 5 == 0) _save();
  }

  // ---------- Início ----------
  Future<void> start(WorkoutPlan plan, WorkoutDay day) async {
    final uid = ref.read(authenticationRepositoryProvider).currentUser?.id ?? '';
    final repo = ref.read(workoutSessionRepositoryProvider);
    final exercises = day.exercises.map((we) {
      // Pré-preenche com peso, repetições e anotação do último treino.
      final lastWeight = repo.lastWeightFor(we.exercise.id);
      final lastReps = repo.lastRepsFor(we.exercise.id);
      final lastNote = repo.lastNoteFor(we.exercise.id);
      return WorkoutExerciseSession(
        id: _newId(),
        exercise: we.exercise,
        note: lastNote,
        sets: we.sets
            .map((ps) => WorkoutSetSession(
                  id: _newId(),
                  setNumber: ps.setNumber,
                  type: ps.type,
                  targetReps: ps.targetReps,
                  restSeconds: ps.restSeconds,
                  weight: lastWeight,
                  reps: lastReps,
                ))
            .toList(),
      );
    }).toList();

    final session = WorkoutSession(
      id: _newId(),
      userId: uid,
      planId: plan.id,
      planName: plan.name,
      dayName: day.name,
      startedAt: DateTime.now(),
      exercises: exercises,
    );

    state = SessionState(session: session);
    await _save();
    _startTicker();
  }

  // ---------- Edição das séries ----------
  void updateSet(
    int exIndex,
    int setIndex, {
    double? weight,
    int? reps,
    double? rpe,
    String? note,
  }) {
    _mutateSet(exIndex, setIndex,
        (s) => s.copyWith(weight: weight, reps: reps, rpe: rpe, note: note));
  }

  void completeSet(int exIndex, int setIndex) {
    final s = state.session;
    if (s == null) return;
    final set = s.exercises[exIndex].sets[setIndex];
    _mutateSet(exIndex, setIndex, (x) => x.copyWith(completed: true));
    if (!set.isWarmup) startRest(set.restSeconds);
    _save();
  }

  void uncompleteSet(int exIndex, int setIndex) {
    _mutateSet(exIndex, setIndex, (x) => x.copyWith(completed: false));
  }

  void addSet(int exIndex) {
    final s = state.session;
    if (s == null) return;
    final ex = s.exercises[exIndex];
    final last = ex.sets.isNotEmpty ? ex.sets.last : null;
    final newSet = WorkoutSetSession(
      id: _newId(),
      setNumber: ex.sets.length + 1,
      targetReps: last?.targetReps ?? '',
      restSeconds: last?.restSeconds ?? 90,
      weight: last?.weight,
    );
    _mutateExercise(exIndex, (e) => e.copyWith(sets: [...e.sets, newSet]));
    _save();
  }

  void setExerciseNote(int exIndex, String note) =>
      _mutateExercise(exIndex, (e) => e.copyWith(note: note));

  // ---------- Descanso ----------
  void startRest(int seconds) =>
      state = state.copyWith(restRemaining: seconds, restTotal: seconds);
  void addRest(int delta) => state = state.copyWith(
      restRemaining: (state.restRemaining + delta).clamp(0, 3600));
  void skipRest() => state = state.copyWith(restRemaining: 0);

  // ---------- Pausar / retomar ----------
  Future<void> pause() async {
    final s = state.session;
    if (s == null) return;
    state = state.copyWith(session: s.copyWith(status: SessionStatus.paused));
    await _save();
  }

  Future<void> resume() async {
    final s = state.session;
    if (s == null) return;
    state = state.copyWith(session: s.copyWith(status: SessionStatus.active));
    await _save();
  }

  // ---------- Finalizar ----------
  Future<WorkoutSummary?> finish({
    WorkoutMood? mood,
    int? energy,
    String? notes,
  }) async {
    final s = state.session;
    if (s == null) return null;
    _ticker?.cancel();
    final withMeta = s.copyWith(mood: mood, energy: energy, notes: notes);
    final summary =
        await ref.read(workoutSessionRepositoryProvider).finish(withMeta);
    state = state.copyWith(session: summary.session, restRemaining: 0);
    return summary;
  }

  Future<void> discard() async {
    _ticker?.cancel();
    await ref.read(workoutSessionRepositoryProvider).clearActive();
    state = const SessionState();
  }

  // ---------- Helpers ----------
  Future<void> _save() async {
    final s = state.session;
    if (s == null || s.isFinished) return;
    await ref.read(workoutSessionRepositoryProvider).saveActive(s);
  }

  void _mutateSet(
    int exIndex,
    int setIndex,
    WorkoutSetSession Function(WorkoutSetSession) fn,
  ) {
    _mutateExercise(exIndex, (e) {
      final sets = [...e.sets];
      sets[setIndex] = fn(sets[setIndex]);
      return e.copyWith(sets: sets);
    });
  }

  void _mutateExercise(
    int exIndex,
    WorkoutExerciseSession Function(WorkoutExerciseSession) fn,
  ) {
    final s = state.session;
    if (s == null) return;
    final exercises = [...s.exercises];
    exercises[exIndex] = fn(exercises[exIndex]);
    state = state.copyWith(session: s.copyWith(exercises: exercises));
  }
}
DARTEOF_SESSIONCTRL

echo "    - lib/features/workout_session/repositories/workout_session_repository.dart"
cat > lib/features/workout_session/repositories/workout_session_repository.dart <<'DARTEOF_SESSIONREPO'
import '../models/workout_session.dart';
import '../models/workout_summary.dart';

/// Contrato do repositório da sessão de treino (PROMPT 06).
///
/// Offline-first: a sessão ativa é persistida para sobreviver ao
/// fechamento do app; ao finalizar, calcula PRs, grava a sessão e
/// atualiza o histórico consumido pela Biblioteca.
abstract interface class WorkoutSessionRepository {
  /// Sessão ativa/pausada persistida (para retomar), ou null.
  WorkoutSession? loadActive();

  /// Autosave do progresso atual.
  Future<void> saveActive(WorkoutSession session);

  Future<void> clearActive();

  /// Finaliza: computa PRs, persiste a sessão, atualiza histórico e
  /// limpa a sessão ativa. Retorna o resumo.
  Future<WorkoutSummary> finish(WorkoutSession session);

  /// Sessões concluídas mais recentes (para Dashboard/Analytics).
  List<WorkoutSession> recentSessions({int limit});

  /// Último peso usado no exercício informado (para pré-preencher a
  /// próxima sessão). Retorna null se nunca foi treinado.
  double? lastWeightFor(String exerciseId);

  /// Últimas repetições registradas no exercício informado.
  int? lastRepsFor(String exerciseId);

  /// Última anotação salva para o exercício (ex.: altura do banco).
  String? lastNoteFor(String exerciseId);
}
DARTEOF_SESSIONREPO

echo "    - lib/features/workout_session/data/workout_session_repository_impl.dart"
cat > lib/features/workout_session/data/workout_session_repository_impl.dart <<'DARTEOF_SESSIONREPOIMPL'
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../exercise/domain/exercise_user_data_store.dart';
import '../../exercise/models/exercise_history.dart';
import '../domain/session_enums.dart';
import '../models/workout_pr.dart';
import '../models/workout_session.dart';
import '../models/workout_summary.dart';
import '../repositories/workout_session_repository.dart';

/// Implementação offline-first do [WorkoutSessionRepository].
final class WorkoutSessionRepositoryImpl implements WorkoutSessionRepository {
  WorkoutSessionRepositoryImpl({
    required LocalStorageService storage,
    required ExerciseUserDataStore exerciseStore,
    required String? Function() currentUserId,
  })  : _storage = storage,
        _exerciseStore = exerciseStore,
        _currentUserId = currentUserId;

  final LocalStorageService _storage;
  final ExerciseUserDataStore _exerciseStore;
  final String? Function() _currentUserId;

  String get _uid => _currentUserId() ?? 'local';
  String get _box => AppConstants.boxWorkouts;
  String get _activeKey => 'active_session_$_uid';
  String get _sessionsKey => 'sessions_$_uid';

  @override
  WorkoutSession? loadActive() {
    final raw = _storage.get<Map<dynamic, dynamic>>(_box, _activeKey);
    if (raw == null) return null;
    final session = WorkoutSession.fromMap(Map<String, dynamic>.from(raw));
    return session.isFinished ? null : session;
  }

  @override
  Future<void> saveActive(WorkoutSession session) =>
      _storage.put(_box, _activeKey, session.toMap());

  @override
  Future<void> clearActive() => _storage.delete(_box, _activeKey);

  @override
  Future<WorkoutSummary> finish(WorkoutSession session) async {
    final finished = session.copyWith(
      status: SessionStatus.finished,
      finishedAt: DateTime.now(),
    );

    final history = {..._exerciseStore.history(_uid)};
    final prs = <WorkoutPR>[];

    for (final ex in finished.exercises) {
      if (ex.completedSets == 0) continue;
      final prev = history[ex.exercise.id];
      final newMaxWeight = ex.maxWeight;
      final newMaxReps = ex.maxReps;
      final newVolume = ex.volume;

      // Detecção de PRs (comparado ao histórico anterior).
      if (newMaxWeight != null &&
          newMaxWeight > (prev?.maxWeight ?? 0)) {
        prs.add(WorkoutPR(
          exerciseId: ex.exercise.id,
          exerciseName: ex.exercise.name,
          kind: PRKind.maxWeight,
          value: newMaxWeight,
        ));
      }
      if (newVolume > (prev?.maxVolume ?? 0)) {
        prs.add(WorkoutPR(
          exerciseId: ex.exercise.id,
          exerciseName: ex.exercise.name,
          kind: PRKind.maxVolume,
          value: newVolume,
        ));
      }
      if (newMaxReps != null && newMaxReps > (prev?.maxReps ?? 0)) {
        prs.add(WorkoutPR(
          exerciseId: ex.exercise.id,
          exerciseName: ex.exercise.name,
          kind: PRKind.maxReps,
          value: newMaxReps.toDouble(),
        ));
      }

      // Atualiza o histórico agregado (nunca reduz os máximos).
      history[ex.exercise.id] = ExerciseHistorySummary(
        exerciseId: ex.exercise.id,
        lastPerformedAt: finished.finishedAt,
        maxWeight: _max(prev?.maxWeight, newMaxWeight),
        maxVolume: _max(prev?.maxVolume, newVolume),
        maxReps: _maxInt(prev?.maxReps, newMaxReps),
        timesPerformed: (prev?.timesPerformed ?? 0) + 1,
        lastNote: ex.note ?? prev?.lastNote,
      );
    }

    await _exerciseStore.writeHistory(_uid, history);
    await _appendSession(finished);
    await clearActive();

    return WorkoutSummary(
      session: finished,
      stats: WorkoutStats.fromSession(finished),
      personalRecords: prs,
    );
  }

  @override
  List<WorkoutSession> recentSessions({int limit = 20}) {
    final raw = _storage.get<List<dynamic>>(_box, _sessionsKey) ?? const [];
    final list = raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => WorkoutSession.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) =>
          (b.finishedAt ?? b.startedAt).compareTo(a.finishedAt ?? a.startedAt));
    return list.take(limit).toList();
  }

  @override
  double? lastWeightFor(String exerciseId) {
    for (final session in recentSessions(limit: 40)) {
      for (final ex in session.exercises) {
        if (ex.exercise.id != exerciseId) continue;
        for (final set in ex.sets.reversed) {
          final w = set.weight;
          if (w != null && w > 0) return w;
        }
      }
    }
    return null;
  }

  @override
  int? lastRepsFor(String exerciseId) {
    for (final session in recentSessions(limit: 40)) {
      for (final ex in session.exercises) {
        if (ex.exercise.id != exerciseId) continue;
        for (final set in ex.sets.reversed) {
          final r = set.reps;
          if (r != null && r > 0) return r;
        }
      }
    }
    return null;
  }

  @override
  String? lastNoteFor(String exerciseId) {
    for (final session in recentSessions(limit: 40)) {
      for (final ex in session.exercises) {
        if (ex.exercise.id != exerciseId) continue;
        final n = ex.note;
        if (n != null && n.trim().isNotEmpty) return n;
      }
    }
    return null;
  }

  Future<void> _appendSession(WorkoutSession session) async {
    final raw = _storage.get<List<dynamic>>(_box, _sessionsKey) ?? const [];
    final list = [session.toMap(), ...raw].take(100).toList();
    await _storage.put(_box, _sessionsKey, list);
  }

  double? _max(double? a, double? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a > b ? a : b;
  }

  int? _maxInt(int? a, int? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a > b ? a : b;
  }
}
DARTEOF_SESSIONREPOIMPL

echo "    - lib/features/body_progress/presentation/body_progress_screen.dart"
cat > lib/features/body_progress/presentation/body_progress_screen.dart <<'DARTEOF_BODYSCREEN'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/graphs_tab.dart';
import '../widgets/measurements_tab.dart';
import '../widgets/photos_tab.dart';
import '../widgets/weight_tab.dart';

/// Evolução corporal — peso, medidas, fotos e gráficos (PROMPT 08).
class BodyProgressScreen extends StatelessWidget {
  const BodyProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: VisAppBar(
          title: 'Evolução',
          accent: AppColors.secondary,
          actions: [
            IconButton(
              tooltip: 'Estatísticas',
              icon: const Icon(LucideIcons.barChart3),
              onPressed: () => context.pushNamed('analytics'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Peso'),
              Tab(text: 'Medidas'),
              Tab(text: 'Fotos'),
              Tab(text: 'Gráficos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WeightTab(),
            MeasurementsTab(),
            PhotosTab(),
            GraphsTab(),
          ],
        ),
      ),
    );
  }
}
DARTEOF_BODYSCREEN

echo "    - lib/features/body_progress/repositories/body_progress_repository.dart"
cat > lib/features/body_progress/repositories/body_progress_repository.dart <<'DARTEOF_BODYREPO'
import '../domain/body_enums.dart';
import '../models/body_goal.dart';
import '../models/body_photo.dart';
import '../models/measurement_record.dart';
import '../models/weight_record.dart';

/// Contrato do repositório de evolução corporal (PROMPT 08).
///
/// Regra 001/003: nada é sobrescrito — cada registro é novo e datado.
/// Offline-first.
abstract interface class BodyProgressRepository {
  // ----- Peso -----
  Future<void> addWeight(WeightRecord record);
  List<WeightRecord> weightHistory();
  WeightRecord? latestWeight();

  // ----- Medidas -----
  Future<void> addMeasurement(MeasurementRecord record);
  List<MeasurementRecord> measurementHistory();
  MeasurementRecord? latestMeasurement();

  // ----- Fotos -----
  Future<void> addPhoto(BodyPhoto photo);
  List<BodyPhoto> photos({PhotoType? type});
  Future<void> removePhoto(String id);

  // ----- Metas -----
  Future<void> addGoal(BodyGoal goal);
  List<BodyGoal> goals();
  Future<void> removeGoal(String id);
}
DARTEOF_BODYREPO

echo "    - lib/features/body_progress/data/body_progress_repository_impl.dart"
cat > lib/features/body_progress/data/body_progress_repository_impl.dart <<'DARTEOF_BODYREPOIMPL'
import '../domain/body_enums.dart';
import '../domain/body_progress_local_store.dart';
import '../models/body_goal.dart';
import '../models/body_photo.dart';
import '../models/measurement_record.dart';
import '../models/weight_record.dart';
import '../repositories/body_progress_repository.dart';

/// Implementação offline-first do [BodyProgressRepository].
final class BodyProgressRepositoryImpl implements BodyProgressRepository {
  BodyProgressRepositoryImpl({
    required BodyProgressLocalStore store,
    required String? Function() currentUserId,
  })  : _store = store,
        _currentUserId = currentUserId;

  final BodyProgressLocalStore _store;
  final String? Function() _currentUserId;

  String get _uid => _currentUserId() ?? 'local';

  static const _weight = 'weight';
  static const _measurements = 'measurements';
  static const _photos = 'photos';
  static const _goals = 'goals';

  // ----- Peso -----
  @override
  Future<void> addWeight(WeightRecord record) async {
    final list = _store.read(_uid, _weight)..add(record.toMap());
    await _store.write(_uid, _weight, list);
  }

  @override
  List<WeightRecord> weightHistory() {
    final list = _store.read(_uid, _weight).map(WeightRecord.fromMap).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return list;
  }

  @override
  WeightRecord? latestWeight() {
    final h = weightHistory();
    return h.isEmpty ? null : h.first;
  }

  // ----- Medidas -----
  @override
  Future<void> addMeasurement(MeasurementRecord record) async {
    final list = _store.read(_uid, _measurements)..add(record.toMap());
    await _store.write(_uid, _measurements, list);
  }

  @override
  List<MeasurementRecord> measurementHistory() {
    final list = _store
        .read(_uid, _measurements)
        .map(MeasurementRecord.fromMap)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return list;
  }

  @override
  MeasurementRecord? latestMeasurement() {
    final h = measurementHistory();
    return h.isEmpty ? null : h.first;
  }

  // ----- Fotos -----
  @override
  Future<void> addPhoto(BodyPhoto photo) async {
    final list = _store.read(_uid, _photos)..add(photo.toMap());
    await _store.write(_uid, _photos, list);
  }

  @override
  List<BodyPhoto> photos({PhotoType? type}) {
    final list = _store.read(_uid, _photos).map(BodyPhoto.fromMap).toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return type == null ? list : list.where((p) => p.type == type).toList();
  }

  @override
  Future<void> removePhoto(String id) async {
    final list = _store.read(_uid, _photos)
      ..removeWhere((m) => m['id'] == id);
    await _store.write(_uid, _photos, list);
  }

  // ----- Metas -----
  @override
  Future<void> addGoal(BodyGoal goal) async {
    final list = _store.read(_uid, _goals)..add(goal.toMap());
    await _store.write(_uid, _goals, list);
  }

  @override
  List<BodyGoal> goals() =>
      _store.read(_uid, _goals).map(BodyGoal.fromMap).toList();

  @override
  Future<void> removeGoal(String id) async {
    final list = _store.read(_uid, _goals)
      ..removeWhere((m) => m['id'] == id);
    await _store.write(_uid, _goals, list);
  }
}
DARTEOF_BODYREPOIMPL

echo "    - lib/features/photo_analysis/controllers/photo_controller.dart"
cat > lib/features/photo_analysis/controllers/photo_controller.dart <<'DARTEOF_PHOTOCTRL'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/providers/authentication_providers.dart';
import '../../body_progress/domain/body_enums.dart';
import '../../body_progress/models/body_photo.dart';
import '../../body_progress/providers/body_progress_providers.dart';
import '../providers/photo_providers.dart';
import '../services/photo_capture_service.dart';

/// Controller das fotos de progresso (PROMPT 13).
///
/// Usa o repositório de evolução corporal (módulo 08) para persistência.
class PhotoController extends Notifier<List<BodyPhoto>> {
  final Uuid _uuid = const Uuid();

  @override
  List<BodyPhoto> build() =>
      ref.read(bodyProgressRepositoryProvider).photos();

  List<BodyPhoto> ofType(PhotoType type) =>
      state.where((p) => p.type == type).toList();

  /// Remove uma foto (exige confirmação na tela).
  Future<void> remove(String id) async {
    await ref.read(bodyProgressRepositoryProvider).removePhoto(id);
    state = ref.read(bodyProgressRepositoryProvider).photos();
  }

  /// Captura (câmera/galeria) e registra a foto na pose informada.
  /// Retorna `false` se o usuário cancelar a captura.
  Future<bool> capture({
    required PhotoType type,
    required PhotoSourceKind source,
  }) async {
    final path = await ref.read(photoCaptureServiceProvider).capture(source);
    if (path == null) return false;

    final uid =
        ref.read(authenticationRepositoryProvider).currentUser?.id ?? '';
    await ref.read(bodyProgressRepositoryProvider).addPhoto(
          BodyPhoto(
            id: _uuid.v4(),
            userId: uid,
            type: type,
            takenAt: DateTime.now(),
            localPath: path,
          ),
        );
    state = ref.read(bodyProgressRepositoryProvider).photos();
    return true;
  }
}
DARTEOF_PHOTOCTRL

echo "    - lib/features/photo_analysis/services/photo_capture_service.dart"
cat > lib/features/photo_analysis/services/photo_capture_service.dart <<'DARTEOF_PHOTOCAPT'
import 'dart:convert';

import 'package:image_picker/image_picker.dart';

/// Origem da captura de foto.
enum PhotoSourceKind { camera, gallery }

/// Serviço de captura de fotos (PROMPT 13).
///
/// Encapsula o `image_picker`. A foto é lida como bytes e devolvida como
/// data URL (`data:image/jpeg;base64,...`), formato que funciona tanto no
/// app nativo quanto na web e que persiste no armazenamento local (não
/// depende de um caminho de arquivo, que não existe no navegador).
/// O upload para o Supabase Storage entra na camada de sincronização.
abstract interface class IPhotoCaptureService {
  Future<String?> capture(PhotoSourceKind source);
}

final class PhotoCaptureService implements IPhotoCaptureService {
  PhotoCaptureService([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> capture(PhotoSourceKind source) async {
    final file = await _picker.pickImage(
      source: source == PhotoSourceKind.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }
}
DARTEOF_PHOTOCAPT

echo "    - lib/features/photo_analysis/presentation/photos_gallery_screen.dart"
cat > lib/features/photo_analysis/presentation/photos_gallery_screen.dart <<'DARTEOF_PHOTOGAL'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/logger/app_logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../body_progress/domain/body_enums.dart';
import '../../body_progress/models/body_photo.dart';
import '../providers/photo_providers.dart';
import '../services/photo_capture_service.dart';

/// Galeria de fotos de progresso por pose (PROMPT 13).
class PhotosGalleryScreen extends ConsumerWidget {
  const PhotosGalleryScreen({super.key});

  static const _poses = [
    PhotoType.frontRelaxed,
    PhotoType.frontFlexed,
    PhotoType.sideRight,
    PhotoType.sideLeft,
    PhotoType.backRelaxed,
    PhotoType.backFlexed,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photoControllerProvider);

    return Scaffold(
      appBar: const VisAppBar(
          title: 'Fotos de progresso', accent: AppColors.accentTeal),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSheet(context, ref),
        icon: const Icon(LucideIcons.camera),
        label: const Text('Adicionar foto'),
      ),
      body: photos.isEmpty
          ? const EmptyState(
              icon: LucideIcons.camera,
              title: 'Nenhuma foto ainda',
              description:
                  'Adicione fotos das poses para acompanhar a evolução.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.m),
              children: [
                for (final pose in _poses)
                  _PoseSection(
                    pose: pose,
                    photos: photos.where((p) => p.type == pose).toList(),
                    onDelete: (ctx, p) => _confirmDelete(ctx, ref, p),
                  ),
              ],
            ),
    );
  }

  Future<void> _addSheet(BuildContext context, WidgetRef ref) async {
    PhotoType selected = PhotoType.frontRelaxed;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adicionar foto', style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.m),
              Text('Pose', style: AppTypography.caption),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in _poses)
                    VisChip(
                      label: p.label,
                      selected: selected == p,
                      onTap: () => setModal(() => selected = p),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Galeria',
                      icon: LucideIcons.image,
                      onPressed: () => _capture(
                          ctx, ref, selected, PhotoSourceKind.gallery),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Câmera',
                      icon: LucideIcons.camera,
                      onPressed: () => _capture(
                          ctx, ref, selected, PhotoSourceKind.camera),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BodyPhoto photo,
  ) async {
    final ok = await ConfirmationDialog.show(
      context,
      title: 'Apagar foto?',
      message: 'Esta foto será removida da sua evolução. Não é possível desfazer.',
      confirmLabel: 'Apagar',
      danger: true,
    );
    if (ok) {
      await ref.read(photoControllerProvider.notifier).remove(photo.id);
    }
  }

  Future<void> _capture(
    BuildContext ctx,
    WidgetRef ref,
    PhotoType type,
    PhotoSourceKind source,
  ) async {
    Navigator.pop(ctx);
    try {
      await ref
          .read(photoControllerProvider.notifier)
          .capture(type: type, source: source);
    } catch (e, st) {
      AppLogger.e('[Photos] falha ao capturar imagem',
          error: e, stackTrace: st);
      if (ctx.mounted) {
        AppSnackBar.show(ctx, 'Não foi possível acessar a imagem.',
            type: SnackType.error);
      }
    }
  }
}

class _PoseSection extends StatelessWidget {
  const _PoseSection({
    required this.pose,
    required this.photos,
    required this.onDelete,
  });
  final PhotoType pose;
  final List<BodyPhoto> photos;
  final void Function(BuildContext, BodyPhoto) onDelete;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(pose.label, style: AppTypography.subtitle)),
              if (photos.length >= 2)
                TextButton.icon(
                  icon: const Icon(LucideIcons.arrowLeftRight, size: 16),
                  label: const Text('Comparar'),
                  onPressed: () =>
                      context.pushNamed('photos-compare', extra: pose),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
              itemBuilder: (ctx, i) {
                final p = photos[i];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: p.displayPath != null
                          ? ProgressPhotoView(
                              source: p.displayPath!,
                              width: 110,
                              height: 140,
                            )
                          : Container(
                              width: 110,
                              height: 140,
                              color: AppColors.card,
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onDelete(ctx, p),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(LucideIcons.trash2,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
DARTEOF_PHOTOGAL

echo "    - lib/features/photo_analysis/presentation/photo_compare_screen.dart"
cat > lib/features/photo_analysis/presentation/photo_compare_screen.dart <<'DARTEOF_PHOTOCOMPARE'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../body_progress/domain/body_enums.dart';
import '../providers/photo_providers.dart';
import '../widgets/before_after_slider.dart';

/// Comparação antes/depois de uma pose (PROMPT 13).
class PhotoCompareScreen extends ConsumerWidget {
  const PhotoCompareScreen({required this.pose, super.key});

  final PhotoType pose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Considera apenas fotos com imagem disponível localmente, para que
    // `first`/`last` sejam sempre válidas no slider (evita null-check crash).
    // Considera só fotos com imagem realmente exibível (data URL ou http).
    // Fotos antigas salvas como caminho de arquivo/blob não renderizam na web.
    bool renderable(String? p) =>
        p != null && (p.startsWith('data:') || p.startsWith('http'));
    final photos = ref
        .watch(photoControllerProvider)
        .where((p) => p.type == pose && renderable(p.displayPath))
        .toList()
      ..sort((a, b) => a.takenAt.compareTo(b.takenAt));

    return Scaffold(
      appBar: AppBar(title: Text('Comparar · ${pose.label}')),
      body: photos.length < 2
          ? const EmptyState(
              icon: LucideIcons.arrowLeftRight,
              title: 'Fotos insuficientes',
              description: 'Adicione ao menos duas fotos desta pose.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                BeforeAfterSlider(
                  beforePath: photos.first.displayPath!,
                  afterPath: photos.last.displayPath!,
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_date(photos.first.takenAt),
                        style: AppTypography.small),
                    Text(_date(photos.last.takenAt),
                        style: AppTypography.small),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                CardContainer(
                  child: Row(
                    children: [
                      const Icon(LucideIcons.sparkles, color: null, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'A análise por IA (definição, simetria, evolução por '
                          'região) será gerada aqui após o upload das fotos.',
                          style: AppTypography.small,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
DARTEOF_PHOTOCOMPARE

echo "    - lib/features/photo_analysis/widgets/before_after_slider.dart"
cat > lib/features/photo_analysis/widgets/before_after_slider.dart <<'DARTEOF_BASLIDER'
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/media/progress_photo_view.dart';

/// Slider de comparação antes/depois (PROMPT 13).
///
/// A foto "antes" é revelada sobre a "depois" conforme o controle desliza.
/// Usa um recorte por fração (CustomClipper) para funcionar de forma
/// consistente também na web.
class BeforeAfterSlider extends StatefulWidget {
  const BeforeAfterSlider({
    required this.beforePath,
    required this.afterPath,
    super.key,
  });

  final String beforePath;
  final String afterPath;

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final v = _value.clamp(0.0, 1.0);
                return Stack(
                  children: [
                    // Base: foto "depois" ocupa todo o espaço.
                    Positioned.fill(
                      child: ProgressPhotoView(
                        source: widget.afterPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Topo: foto "antes", recortada à fração da esquerda.
                    Positioned.fill(
                      child: ClipRect(
                        clipper: _LeftRevealClipper(v),
                        child: ProgressPhotoView(
                          source: widget.beforePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Linha divisória.
                    Positioned(
                      left: (w * v) - 1,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 2, color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Slider(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Antes', style: TextStyle(color: AppColors.textSecondary)),
            Text('Depois', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

/// Recorta o widget à fração [fraction] da largura (a partir da esquerda).
class _LeftRevealClipper extends CustomClipper<Rect> {
  const _LeftRevealClipper(this.fraction);
  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_LeftRevealClipper old) => old.fraction != fraction;
}
DARTEOF_BASLIDER

echo "    - lib/features/analytics/data/analytics_service.dart"
cat > lib/features/analytics/data/analytics_service.dart <<'DARTEOF_ANALYTICSSVC'
import '../../body_progress/repositories/body_progress_repository.dart';
import '../../cardio/repositories/cardio_repository.dart';
import '../../workout_session/models/workout_session.dart';
import '../../workout_session/repositories/workout_session_repository.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/analytics_enums.dart';
import '../models/analytics_report.dart';

/// Motor de estatísticas (PROMPT 16).
///
/// Consolida dados já registrados (treino, cardio, peso) em relatórios por
/// período. Determinístico e sem efeitos colaterais — `now` é injetável
/// para testes. Cardio e peso são opcionais: o relatório funciona só com
/// as sessões de treino.
final class AnalyticsService {
  AnalyticsService({
    required WorkoutSessionRepository sessionRepository,
    CardioRepository? cardioRepository,
    BodyProgressRepository? bodyRepository,
    DateTime Function()? now,
  })  : _sessions = sessionRepository,
        _cardio = cardioRepository,
        _body = bodyRepository,
        _now = now ?? DateTime.now;

  final WorkoutSessionRepository _sessions;
  final CardioRepository? _cardio;
  final BodyProgressRepository? _body;
  final DateTime Function() _now;

  DateTime _sessionDate(WorkoutSession s) =>
      dateOnly(s.finishedAt ?? s.startedAt);

  AnalyticsReport buildReport(AnalyticsPeriod period) {
    final today = dateOnly(_now());
    final DateTime? from = period.days == null
        ? null
        : today.subtract(Duration(days: period.days! - 1));

    bool inWindow(DateTime d) => from == null || !d.isBefore(from);

    final sessions = _sessions
        .recentSessions(limit: 1000)
        .where((s) => inWindow(_sessionDate(s)))
        .toList();

    final activeDays = sessions.map(_sessionDate).toSet().length;
    var volume = 0.0;
    var sets = 0;
    var minutes = 0;
    for (final s in sessions) {
      volume += s.totalVolume;
      sets += s.completedSets;
      minutes += (s.elapsedSeconds / 60).round();
    }

    return AnalyticsReport(
      period: period,
      workouts: sessions.length,
      activeDays: activeDays,
      totalVolume: volume,
      totalSets: sets,
      totalMinutes: minutes,
      weeklyFrequency: _weeklyFrequency(sessions, period, today),
      muscleDistribution: _muscleDistribution(sessions),
      personalRecords: _personalRecords(sessions),
      volumeTrend: _volumeTrend(sessions, period, today, from),
      cardio: _cardioSummary(inWindow),
      weight: _weightTrend(inWindow),
    );
  }

  double _weeklyFrequency(
    List<WorkoutSession> sessions,
    AnalyticsPeriod period,
    DateTime today,
  ) {
    if (sessions.isEmpty) return 0;
    var weeks = period.weeks;
    if (weeks == null) {
      // "Tudo": usa o intervalo real entre o primeiro treino e hoje.
      final earliest = sessions.map(_sessionDate).reduce(
            (a, b) => a.isBefore(b) ? a : b,
          );
      final spanDays = today.difference(earliest).inDays + 1;
      weeks = spanDays / 7;
    }
    if (weeks < 1) weeks = 1;
    return sessions.length / weeks;
  }

  /// Distribuição por músculo baseada no NÚMERO DE SÉRIES realizadas
  /// (não no peso). Assim o percentual reflete a atenção dada a cada
  /// grupo — cargas altas de perna não distorcem o resultado. O campo
  /// `volume` carrega a contagem de séries.
  List<MuscleDistribution> _muscleDistribution(List<WorkoutSession> sessions) {
    final setsByMuscle = <String, int>{};
    var totalSets = 0;
    for (final s in sessions) {
      for (final e in s.exercises) {
        final g = e.exercise.muscleGroup;
        if (g.isEmpty) continue;
        final done =
            e.sets.where((x) => x.completed && !x.isWarmup).length;
        if (done == 0) continue;
        setsByMuscle[g] = (setsByMuscle[g] ?? 0) + done;
        totalSets += done;
      }
    }
    final entries = setsByMuscle.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in entries)
        MuscleDistribution(
          muscle: e.key,
          volume: e.value.toDouble(),
          percent: totalSets > 0 ? e.value / totalSets : 0,
        ),
    ];
  }

  /// Recordes por exercício: maior carga concluída (não aquecimento),
  /// melhor volume de série e 1RM estimado (Epley).
  List<PersonalRecord> _personalRecords(List<WorkoutSession> sessions) {
    final best = <String, PersonalRecord>{};
    for (final s in sessions) {
      final date = _sessionDate(s);
      for (final e in s.exercises) {
        for (final set in e.sets) {
          if (!set.completed || set.isWarmup) continue;
          final w = set.weight;
          final r = set.reps;
          if (w == null || w <= 0 || r == null || r <= 0) continue;
          final setVolume = w * r;
          final oneRm = w * (1 + r / 30);
          final current = best[e.exercise.id];
          if (current == null || w > current.maxWeight) {
            best[e.exercise.id] = PersonalRecord(
              exerciseId: e.exercise.id,
              exerciseName: e.exercise.name,
              muscleGroup: e.exercise.muscleGroup,
              maxWeight: w,
              repsAtMaxWeight: r,
              bestSetVolume:
                  current == null ? setVolume : (setVolume > current.bestSetVolume ? setVolume : current.bestSetVolume),
              estimatedOneRm: oneRm,
              achievedAt: date,
            );
          } else if (setVolume > current.bestSetVolume) {
            best[e.exercise.id] = PersonalRecord(
              exerciseId: current.exerciseId,
              exerciseName: current.exerciseName,
              muscleGroup: current.muscleGroup,
              maxWeight: current.maxWeight,
              repsAtMaxWeight: current.repsAtMaxWeight,
              bestSetVolume: setVolume,
              estimatedOneRm: current.estimatedOneRm,
              achievedAt: current.achievedAt,
            );
          }
        }
      }
    }
    final list = best.values.toList()
      ..sort((a, b) => b.estimatedOneRm.compareTo(a.estimatedOneRm));
    return list;
  }

  /// Série temporal de volume, com granularidade adequada ao período.
  List<TrendPoint> _volumeTrend(
    List<WorkoutSession> sessions,
    AnalyticsPeriod period,
    DateTime today,
    DateTime? from,
  ) {
    if (sessions.isEmpty) return const [];

    switch (period) {
      case AnalyticsPeriod.week:
        return _dailyTrend(sessions, today, 7);
      case AnalyticsPeriod.month:
        return _weeklyTrend(sessions, today, 5);
      case AnalyticsPeriod.quarter:
        return _weeklyTrend(sessions, today, 13);
      case AnalyticsPeriod.year:
      case AnalyticsPeriod.all:
        return _monthlyTrend(sessions, today, 12);
    }
  }

  List<TrendPoint> _dailyTrend(
    List<WorkoutSession> sessions,
    DateTime today,
    int days,
  ) {
    const weekdays = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final points = <TrendPoint>[];
    for (var i = days - 1; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final vol = sessions
          .where((s) => _sessionDate(s) == day)
          .fold(0.0, (sum, s) => sum + s.totalVolume);
      points.add(TrendPoint(label: weekdays[day.weekday - 1], value: vol));
    }
    return points;
  }

  List<TrendPoint> _weeklyTrend(
    List<WorkoutSession> sessions,
    DateTime today,
    int weeks,
  ) {
    final points = <TrendPoint>[];
    // Semana termina hoje; blocos de 7 dias para trás.
    for (var i = weeks - 1; i >= 0; i--) {
      final end = today.subtract(Duration(days: i * 7));
      final start = end.subtract(const Duration(days: 6));
      final vol = sessions.where((s) {
        final d = _sessionDate(s);
        return !d.isBefore(start) && !d.isAfter(end);
      }).fold(0.0, (sum, s) => sum + s.totalVolume);
      points.add(TrendPoint(label: 'S${weeks - i}', value: vol));
    }
    return points;
  }

  List<TrendPoint> _monthlyTrend(
    List<WorkoutSession> sessions,
    DateTime today,
    int months,
  ) {
    const names = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    final points = <TrendPoint>[];
    for (var i = months - 1; i >= 0; i--) {
      final month = DateTime(today.year, today.month - i, 1);
      final vol = sessions.where((s) {
        final d = _sessionDate(s);
        return d.year == month.year && d.month == month.month;
      }).fold(0.0, (sum, s) => sum + s.totalVolume);
      points.add(TrendPoint(label: names[month.month - 1], value: vol));
    }
    return points;
  }

  CardioSummary _cardioSummary(bool Function(DateTime) inWindow) {
    final cardio = _cardio;
    if (cardio == null) return const CardioSummary();
    final list = cardio
        .history()
        .where((c) => inWindow(dateOnly(c.performedAt)))
        .toList();
    if (list.isEmpty) return const CardioSummary();
    var minutes = 0;
    var distance = 0.0;
    var calories = 0.0;
    for (final c in list) {
      minutes += c.minutes;
      distance += c.distanceKm ?? 0;
      calories += c.calories ?? 0;
    }
    return CardioSummary(
      sessions: list.length,
      minutes: minutes,
      distanceKm: distance,
      calories: calories,
    );
  }

  WeightTrend _weightTrend(bool Function(DateTime) inWindow) {
    final body = _body;
    if (body == null) return const WeightTrend();
    // weightHistory() é ordenado do mais recente para o mais antigo.
    final inRange = body
        .weightHistory()
        .where((w) => inWindow(dateOnly(w.recordedAt)))
        .toList();
    if (inRange.isEmpty) return const WeightTrend();
    final end = inRange.first.weight; // mais recente
    final start = inRange.last.weight; // mais antigo do período
    return WeightTrend(start: start, end: end, records: inRange.length);
  }
}
DARTEOF_ANALYTICSSVC

echo "    - lib/features/analytics/widgets/analytics_sections.dart"
cat > lib/features/analytics/widgets/analytics_sections.dart <<'DARTEOF_ANALYTICSSEC'
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/analytics_report.dart';
import 'analytics_format.dart';

/// Grade de KPIs do período (treinos, volume, séries, tempo).
class AnalyticsSummaryGrid extends StatelessWidget {
  const AnalyticsSummaryGrid({required this.report, super.key});
  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      MetricCard(
        title: 'Treinos',
        value: '${report.workouts}',
        delta: '${report.weeklyFrequency.toStringAsFixed(1)}/semana',
        icon: LucideIcons.dumbbell,
      ),
      MetricCard(
        title: 'Volume total',
        value: AnalyticsFormat.kg(report.totalVolume),
        delta: '${AnalyticsFormat.kg(report.avgSessionVolume)}/treino',
        icon: LucideIcons.trendingUp,
      ),
      MetricCard(
        title: 'Séries',
        value: '${report.totalSets}',
        icon: LucideIcons.listChecks,
      ),
      MetricCard(
        title: 'Tempo treinado',
        value: AnalyticsFormat.minutes(report.totalMinutes),
        delta: '${report.avgSessionMinutes.round()} min/treino',
        icon: LucideIcons.clock,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.s;
        final width = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items) SizedBox(width: width, child: item),
          ],
        );
      },
    );
  }
}

/// Gráfico de tendência de volume ao longo do período.
class VolumeTrendCard extends StatelessWidget {
  const VolumeTrendCard({required this.report, super.key});
  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    final points = report.volumeTrend;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tendência de volume', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          if (points.isEmpty)
            Text('Sem dados suficientes no período.',
                style: AppTypography.caption)
          else ...[
            ProgressChart(
              points: [
                for (var i = 0; i < points.length; i++)
                  (x: i.toDouble(), y: points[i].value),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final p in points)
                  Expanded(
                    child: Text(
                      p.label,
                      textAlign: TextAlign.center,
                      style: AppTypography.small
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Distribuição de volume por grupo muscular (barras proporcionais).
class MuscleDistributionCard extends StatelessWidget {
  const MuscleDistributionCard({required this.report, super.key});
  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    final items = report.muscleDistribution;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribuição por músculo', style: AppTypography.subtitle),
          Text('Percentual das séries feitas em cada grupo no período.',
              style: AppTypography.caption),
          const SizedBox(height: AppSpacing.s),
          if (items.isEmpty)
            Text('Nenhuma série registrada no período.',
                style: AppTypography.caption)
          else
            for (final m in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: _MuscleBar(item: m),
              ),
        ],
      ),
    );
  }
}

class _MuscleBar extends StatelessWidget {
  const _MuscleBar({required this.item});
  final MuscleDistribution item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.muscle, style: AppTypography.small),
            Text('${(item.percent * 100).round()}% · ${item.volume.round()} séries',
                style: AppTypography.small
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: item.percent.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.divider,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
DARTEOF_ANALYTICSSEC

echo "==> Baixando dependencias e compilando…"
flutter pub get
flutter build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"

echo "==> Build concluido: build/web"
