import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../controllers/cardio_controller.dart';
import '../data/cardio_repository_impl.dart';
import '../data/hive_cardio_local_store.dart';
import '../models/cardio_session.dart';
import '../repositories/cardio_repository.dart';

/// Re-exporta o contrato.
export '../repositories/cardio_repository.dart' show CardioRepository;

/// Providers do módulo de cardio (PROMPT 09).

final cardioRepositoryProvider = Provider<CardioRepository>(
  (ref) => CardioRepositoryImpl(
    store: const HiveCardioLocalStore(LocalStorageService()),
    currentUserId: () =>
        ref.read(authenticationRepositoryProvider).currentUser?.id,
  ),
);

final cardioControllerProvider =
    NotifierProvider<CardioController, List<CardioSession>>(
  CardioController.new,
);
