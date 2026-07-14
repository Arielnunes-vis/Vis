/// Contrato do armazenamento local das configurações (PROMPT 17).
///
/// Abstraído para permitir uma implementação Hive (produção) e uma em
/// memória (testes), sem acoplar o repositório ao Hive.
abstract interface class SettingsLocalStore {
  /// Lê o mapa de configurações persistido (ou `null` se nunca salvo).
  Map<String, dynamic>? read();

  /// Persiste o mapa de configurações.
  Future<void> write(Map<String, dynamic> data);
}
