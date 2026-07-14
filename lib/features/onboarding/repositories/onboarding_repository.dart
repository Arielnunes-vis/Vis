import '../models/onboarding_model.dart';

/// Contrato do repositório de onboarding (PROMPT 03).
abstract interface class OnboardingRepository {
  /// Persiste as respostas do onboarding e marca como concluído.
  Future<void> save({required String userId, required OnboardingData data});

  /// Indica se o usuário já concluiu o onboarding (guarda de rota).
  Future<bool> isCompleted(String userId);
}
