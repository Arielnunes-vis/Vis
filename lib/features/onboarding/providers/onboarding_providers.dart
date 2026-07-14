import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../../core/supabase/supabase_provider.dart';
import '../controllers/onboarding_controller.dart';
import '../data/onboarding_repository_impl.dart';
import '../repositories/onboarding_repository.dart';

/// Providers do módulo de onboarding (PROMPT 03).

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepositoryImpl(
    database: ref.watch(databaseServiceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  ),
);

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);
