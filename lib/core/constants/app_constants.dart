/// Constantes globais do aplicativo VIS.
abstract final class AppConstants {
  const AppConstants._();

  static const String appName = 'VIS';
  static const String appTagline =
      'Plataforma inteligente para acompanhamento de evolução física.';
  static const String appVersion = '0.1.0';

  // ----- Performance (03/09 docs) -----
  static const Duration dashboardBudget = Duration(seconds: 2);
  static const Duration screenTransition = Duration(milliseconds: 300);

  // ----- UX -----
  static const int minPasswordLength = 8;
  static const int undoWindowSeconds = 5; // Regra 005 — desfazer exclusão.

  // ----- Hive boxes (offline) -----
  static const String boxWorkouts = 'vis_workouts';
  static const String boxWeight = 'vis_weight';
  static const String boxMeasurements = 'vis_measurements';
  static const String boxCardio = 'vis_cardio';
  static const String boxCache = 'vis_cache';
  static const String boxSyncQueue = 'vis_sync_queue';
}
