import '../domain/insight_enums.dart';

/// Insight / alerta / recomendação (PROMPT 14).
///
/// Nunca aleatório: sempre derivado de dados reais e acompanhado do
/// motivo (Regra 008). Nesta fase é gerado por regras locais; o
/// provedor pode ser trocado por IA sem mudar este modelo.
class Insight {
  const Insight({
    required this.category,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    this.reason,
    this.createdAt,
  });

  final InsightCategory category;
  final InsightType type;
  final InsightPriority priority;
  final String title;
  final String message;
  final String? reason;
  final DateTime? createdAt;

  bool get isAlert => type == InsightType.alert;

  int get priorityWeight => switch (priority) {
        InsightPriority.critical => 4,
        InsightPriority.high => 3,
        InsightPriority.medium => 2,
        InsightPriority.low => 1,
      };
}
