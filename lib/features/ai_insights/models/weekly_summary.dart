/// Resumo semanal (PROMPT 14).
class WeeklySummary {
  const WeeklySummary({
    this.workouts = 0,
    this.totalMinutes = 0,
    this.totalVolume = 0,
    this.cardioSessions = 0,
    this.cardioMinutes = 0,
    this.highlights = const [],
    this.attentionPoints = const [],
  });

  final int workouts;
  final int totalMinutes;
  final double totalVolume;
  final int cardioSessions;
  final int cardioMinutes;
  final List<String> highlights;
  final List<String> attentionPoints;

  bool get isEmpty =>
      workouts == 0 && cardioSessions == 0 && totalVolume == 0;
}
