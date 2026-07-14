import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../body_progress/providers/body_progress_providers.dart';
import '../../cardio/providers/cardio_providers.dart';
import '../../nutrition/providers/nutrition_providers.dart';
import '../../workout_session/providers/workout_session_providers.dart';
import '../data/insight_engine.dart';

/// Providers do módulo de insights (PROMPT 14).

final insightEngineProvider = Provider<InsightEngine>(
  (ref) => InsightEngine(
    sessionRepository: ref.watch(workoutSessionRepositoryProvider),
    bodyRepository: ref.watch(bodyProgressRepositoryProvider),
    cardioRepository: ref.watch(cardioRepositoryProvider),
    nutritionRepository: ref.watch(nutritionRepositoryProvider),
  ),
);

/// Insights + resumo semanal calculados a partir dos dados atuais.
final insightBundleProvider = Provider<InsightBundle>(
  (ref) => ref.watch(insightEngineProvider).build(),
);
