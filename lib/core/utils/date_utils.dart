/// Utilitários de data compartilhados (Regra 002 — não duplicar código).

/// Normaliza um [DateTime] para o início do dia (00:00), descartando a
/// hora. Usado para comparar/agrupar registros por dia em vários módulos
/// (dashboard, insights, analytics).
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
