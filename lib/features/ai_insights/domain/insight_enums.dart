/// Enums do módulo de insights (PROMPT 14).

/// Categoria do insight.
enum InsightCategory {
  training('Treino'),
  nutrition('Nutrição'),
  cardio('Cardio'),
  recovery('Recuperação'),
  evolution('Evolução'),
  consistency('Consistência'),
  performance('Performance'),
  goals('Metas'),
  health('Saúde');

  const InsightCategory(this.label);
  final String label;
}

/// Prioridade do insight.
enum InsightPriority { low, medium, high, critical }

/// Tipo do insight.
enum InsightType {
  insight('Insight'),
  alert('Alerta'),
  achievement('Conquista'),
  recommendation('Recomendação'),
  summary('Resumo');

  const InsightType(this.label);
  final String label;
}
