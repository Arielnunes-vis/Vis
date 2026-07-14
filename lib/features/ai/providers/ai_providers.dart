import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_provider.dart';
import '../../body_progress/providers/body_progress_providers.dart';
import '../../cardio/providers/cardio_providers.dart';
import '../../nutrition/providers/nutrition_providers.dart';
import '../../workout/providers/workout_providers.dart';
import '../../workout_session/providers/workout_session_providers.dart';
import '../data/ai_context_builder.dart';
import '../domain/ai_context.dart';
import '../repositories/ai_repository.dart';
import '../services/ai_service.dart';

/// Providers da camada de IA (VIS Coach) — PROMPT 11.

final aiServiceProvider = Provider<IAIService>(
  (ref) => EdgeFunctionAIService(ref.watch(edgeFunctionsServiceProvider)),
);

/// Builder que reúne o contexto real do usuário (todos os módulos).
final aiContextBuilderInstanceProvider = Provider<AIContextBuilder>(
  (ref) => AIContextBuilder(
    workoutRepository: ref.watch(workoutRepositoryProvider),
    sessionRepository: ref.watch(workoutSessionRepositoryProvider),
    bodyRepository: ref.watch(bodyProgressRepositoryProvider),
    cardioRepository: ref.watch(cardioRepositoryProvider),
    nutritionRepository: ref.watch(nutritionRepositoryProvider),
  ),
);

/// Função consumida pelo [AIRepository] para montar o contexto antes
/// de cada resposta (Regra 026).
final aiContextBuilderProvider = Provider<Future<AIContext> Function()>((ref) {
  return () => ref.read(aiContextBuilderInstanceProvider).build();
});

final aiRepositoryProvider = Provider<IAIRepository>(
  (ref) => AIRepository(
    ref.watch(aiServiceProvider),
    ref.watch(aiContextBuilderProvider),
  ),
);
