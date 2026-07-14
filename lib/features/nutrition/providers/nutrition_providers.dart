import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../controllers/nutrition_controller.dart';
import '../data/hive_nutrition_local_store.dart';
import '../data/nutrition_repository_impl.dart';
import '../models/daily_nutrition.dart';
import '../models/nutrition_goal.dart';
import '../repositories/nutrition_repository.dart';

/// Re-exporta o contrato.
export '../repositories/nutrition_repository.dart' show NutritionRepository;

/// Providers do módulo de nutrição (PROMPT 10).

final nutritionRepositoryProvider = Provider<NutritionRepository>(
  (ref) => NutritionRepositoryImpl(
    store: const HiveNutritionLocalStore(LocalStorageService()),
    currentUserId: () =>
        ref.read(authenticationRepositoryProvider).currentUser?.id,
  ),
);

final nutritionGoalProvider = Provider<NutritionGoal>(
  (ref) => ref.watch(nutritionRepositoryProvider).goal(),
);

final nutritionControllerProvider =
    NotifierProvider<NutritionController, DailyNutrition>(
  NutritionController.new,
);
