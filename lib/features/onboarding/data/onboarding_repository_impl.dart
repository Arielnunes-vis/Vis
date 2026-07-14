import '../../../core/logger/app_logger.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/supabase/services/database_service.dart';
import '../models/onboarding_model.dart';
import '../repositories/onboarding_repository.dart';

/// Implementação do [OnboardingRepository].
///
/// Persiste os dados no perfil do usuário (tabela `users`) e as
/// preferências/equipamentos na memória da IA (`ai_memory`), seguindo
/// 03_DATABASE.md. Guarda também uma flag local para checagem rápida.
///
/// Regra 001/003: nunca sobrescrever histórico de evolução — aqui
/// gravamos apenas dados de perfil (não históricos).
final class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl({
    required IDatabaseService database,
    required ISecureStorageService secureStorage,
  })  : _database = database,
        _secureStorage = secureStorage;

  final IDatabaseService _database;
  final ISecureStorageService _secureStorage;

  @override
  Future<void> save({
    required String userId,
    required OnboardingData data,
  }) async {
    final map = data.toMap();

    // Perfil (users)
    await _database.from('users').update({
      'goal': (data.goals.isNotEmpty) ? data.goals.first : null,
      'experience_level': data.experience,
      'training_location': data.location,
      'height': data.height,
      'current_weight': data.weight,
      'onboarding_completed': true,
    }).eq('id', userId);

    // Memória da IA (ai_memory) — upsert
    await _database.from('ai_memory').upsert({
      'user_id': userId,
      'available_equipment': data.equipment,
      'training_days': data.trainingDays,
      'goal': (data.goals.isNotEmpty) ? data.goals.first : null,
      'limitations': data.restrictions,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');

    // O cache local guarda o ID do usuário (não apenas "true"), para
    // que um segundo usuário no mesmo dispositivo não herde a flag.
    await _secureStorage.write(SecureKeys.onboardingCompleted, userId);
    AppLogger.i('[Onboarding] concluído para $userId: $map');
  }

  @override
  Future<bool> isCompleted(String userId) async {
    // Checagem rápida local — válida apenas para o MESMO usuário.
    final local = await _secureStorage.read(SecureKeys.onboardingCompleted);
    if (local == userId) return true;

    try {
      final rows = await _database
          .from('users')
          .select('onboarding_completed')
          .eq('id', userId)
          .limit(1);
      if (rows is List && rows.isNotEmpty) {
        final done = (rows.first as Map)['onboarding_completed'] == true;
        if (done) {
          await _secureStorage.write(SecureKeys.onboardingCompleted, userId);
        }
        return done;
      }
    } catch (e) {
      AppLogger.w('[Onboarding] isCompleted falhou, assumindo pendente.');
    }
    return false;
  }
}
