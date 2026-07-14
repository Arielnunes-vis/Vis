import '../domain/app_settings.dart';

/// Contrato do repositório de configurações (PROMPT 17). Offline-first.
abstract interface class SettingsRepository {
  /// Carrega as configurações atuais (ou os padrões, se nunca salvas).
  AppSettings load();

  /// Persiste as configurações.
  Future<void> save(AppSettings settings);
}
