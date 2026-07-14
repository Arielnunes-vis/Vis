import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../controllers/goals_controller.dart';
import '../controllers/measurements_controller.dart';
import '../controllers/weight_controller.dart';
import '../data/body_progress_repository_impl.dart';
import '../data/hive_body_progress_local_store.dart';
import '../models/body_goal.dart';
import '../models/measurement_record.dart';
import '../models/weight_record.dart';
import '../repositories/body_progress_repository.dart';

/// Re-exporta o contrato.
export '../repositories/body_progress_repository.dart'
    show BodyProgressRepository;

/// Providers da evolução corporal (PROMPT 08).

final bodyProgressRepositoryProvider = Provider<BodyProgressRepository>(
  (ref) => BodyProgressRepositoryImpl(
    store: const HiveBodyProgressLocalStore(LocalStorageService()),
    currentUserId: () =>
        ref.read(authenticationRepositoryProvider).currentUser?.id,
  ),
);

final weightControllerProvider =
    NotifierProvider<WeightController, List<WeightRecord>>(
  WeightController.new,
);

final measurementsControllerProvider =
    NotifierProvider<MeasurementsController, List<MeasurementRecord>>(
  MeasurementsController.new,
);

final goalsControllerProvider =
    NotifierProvider<GoalsController, List<BodyGoal>>(
  GoalsController.new,
);
