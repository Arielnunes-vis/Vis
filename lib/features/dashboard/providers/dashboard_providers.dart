import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai_insights/providers/insight_providers.dart';
import '../../body_progress/providers/body_progress_providers.dart';
import '../../cardio/providers/cardio_providers.dart';
import '../../nutrition/providers/nutrition_providers.dart';
import '../../workout/providers/workout_providers.dart';
import '../../workout_session/providers/workout_session_providers.dart';
import '../controllers/dashboard_controller.dart';
import '../data/dashboard_repository_impl.dart';
import '../models/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

/// Providers do Dashboard (PROMPT 07).

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepositoryImpl(
    workoutRepository: ref.watch(workoutRepositoryProvider),
    sessionRepository: ref.watch(workoutSessionRepositoryProvider),
    bodyProgressRepository: ref.watch(bodyProgressRepositoryProvider),
    cardioRepository: ref.watch(cardioRepositoryProvider),
    nutritionRepository: ref.watch(nutritionRepositoryProvider),
    insightEngine: ref.watch(insightEngineProvider),
  ),
);

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardData>(
  DashboardController.new,
);
