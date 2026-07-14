import '../models/dashboard_data.dart';

/// Contrato do repositório do Dashboard (PROMPT 07).
abstract interface class DashboardRepository {
  /// Carrega os dados agregados (offline-first: usa sessões/planos locais).
  Future<DashboardData> load();
}
