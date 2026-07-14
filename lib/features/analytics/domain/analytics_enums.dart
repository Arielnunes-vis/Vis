/// Enums do módulo de Analytics (PROMPT 16).

/// Período de análise dos relatórios. `days == null` significa "tudo".
enum AnalyticsPeriod {
  week('7 dias', 7),
  month('30 dias', 30),
  quarter('90 dias', 90),
  year('12 meses', 365),
  all('Tudo', null);

  const AnalyticsPeriod(this.label, this.days);

  /// Rótulo curto para os seletores de período.
  final String label;

  /// Janela em dias; `null` = sem limite (todo o histórico).
  final int? days;

  /// Quantidade aproximada de semanas no período (para médias).
  /// Para [AnalyticsPeriod.all] retorna `null` (calculado pelos dados).
  double? get weeks => days == null ? null : days! / 7;
}
