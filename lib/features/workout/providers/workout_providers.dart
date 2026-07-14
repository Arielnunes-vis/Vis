import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../controllers/workout_editor_controller.dart';
import '../controllers/workout_list_controller.dart';
import '../data/hive_workout_local_store.dart';
import '../data/workout_repository_impl.dart';
import '../domain/workout_local_store.dart';
import '../models/workout_plan.dart';
import '../repositories/workout_repository.dart';

/// Re-exporta o contrato para consumidores.
export '../repositories/workout_repository.dart' show WorkoutRepository;

/// Providers do Workout Engine (PROMPT 04).

final workoutLocalStoreProvider = Provider<WorkoutLocalStore>(
  (ref) => const HiveWorkoutLocalStore(LocalStorageService()),
);

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepositoryImpl(
    store: ref.watch(workoutLocalStoreProvider),
    currentUserId: () =>
        ref.read(authenticationRepositoryProvider).currentUser?.id,
  ),
);

final workoutListControllerProvider =
    AsyncNotifierProvider<WorkoutListController, List<WorkoutPlan>>(
  WorkoutListController.new,
);

final workoutEditorControllerProvider =
    NotifierProvider<WorkoutEditorController, WorkoutPlan>(
  WorkoutEditorController.new,
);
