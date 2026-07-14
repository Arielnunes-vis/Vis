import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../controllers/exercise_favorites_controller.dart';
import '../controllers/exercise_library_controller.dart';
import '../data/exercise_repository_impl.dart';
import '../data/hive_exercise_user_data_store.dart';
import '../data/local_catalog_source.dart';
import '../domain/exercise_catalog_source.dart';
import '../domain/exercise_user_data_store.dart';
import '../repositories/exercise_repository.dart';

/// Re-exporta o contrato para consumidores.
export '../repositories/exercise_repository.dart' show ExerciseRepository;

/// Providers da Biblioteca de Exercícios (PROMPT 05).

final exerciseCatalogSourceProvider = Provider<ExerciseCatalogSource>(
  (ref) => const LocalCatalogSource(),
);

final exerciseUserDataStoreProvider = Provider<ExerciseUserDataStore>(
  (ref) => const HiveExerciseUserDataStore(LocalStorageService()),
);

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => ExerciseRepositoryImpl(
    source: ref.watch(exerciseCatalogSourceProvider),
    userStore: ref.watch(exerciseUserDataStoreProvider),
    currentUserId: () =>
        ref.read(authenticationRepositoryProvider).currentUser?.id,
  ),
);

final exerciseLibraryControllerProvider =
    NotifierProvider<ExerciseLibraryController, ExerciseLibraryState>(
  ExerciseLibraryController.new,
);

final exerciseFavoritesControllerProvider =
    NotifierProvider<ExerciseFavoritesController, Set<String>>(
  ExerciseFavoritesController.new,
);
