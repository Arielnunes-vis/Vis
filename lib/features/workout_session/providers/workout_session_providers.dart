import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../../exercise/providers/exercise_providers.dart'
    show exerciseUserDataStoreProvider;
import '../controllers/workout_session_controller.dart';
import '../data/workout_session_repository_impl.dart';
import '../repositories/workout_session_repository.dart';

/// Re-exporta o contrato.
export '../repositories/workout_session_repository.dart'
    show WorkoutSessionRepository;

/// Providers do módulo de sessão de treino (PROMPT 06).

final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository>(
  (ref) => WorkoutSessionRepositoryImpl(
    storage: const LocalStorageService(),
    exerciseStore: ref.watch(exerciseUserDataStoreProvider),
    currentUserId: () =>
        ref.read(authenticationRepositoryProvider).currentUser?.id,
  ),
);

final workoutSessionControllerProvider =
    NotifierProvider<WorkoutSessionController, SessionState>(
  WorkoutSessionController.new,
);
