import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/connection_provider.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/supabase/supabase_provider.dart';
import '../../ai/providers/ai_providers.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../controllers/ai_workout_controller.dart';
import '../data/ai_workout_repository_impl.dart';
import '../repositories/ai_workout_repository.dart';
import '../services/ai_workout_service.dart';

/// Re-exporta o contrato para consumidores do controller.
export '../repositories/ai_workout_repository.dart' show AIWorkoutRepository;

/// Providers do gerador de treinos (PROMPT 12).

final aiWorkoutServiceProvider = Provider<IAIWorkoutService>(
  (ref) => EdgeFunctionAIWorkoutService(ref.watch(edgeFunctionsServiceProvider)),
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
