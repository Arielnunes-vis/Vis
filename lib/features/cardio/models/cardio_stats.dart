import 'cardio_session.dart';

/// Resumo de cardio de um período (PROMPT 09).
class CardioStats {
  const CardioStats({
    this.sessions = 0,
    this.totalMinutes = 0,
    this.totalDistance = 0,
    this.totalCalories = 0,
  });

  final int sessions;
  final int totalMinutes;
  final double totalDistance;
  final double totalCalories;

  factory CardioStats.from(Iterable<CardioSession> list) {
    var minutes = 0;
    var distance = 0.0;
    var calories = 0.0;
    var count = 0;
    for (final s in list) {
      count++;
      minutes += s.minutes;
      distance += s.distanceKm ?? 0;
      calories += s.calories ?? 0;
    }
    return CardioStats(
      sessions: count,
      totalMinutes: minutes,
      totalDistance: distance,
      totalCalories: calories,
    );
  }
}

/// Recordes de cardio (PROMPT 09).
class CardioRecords {
  const CardioRecords({
    this.maxDistanceKm,
    this.maxDurationSeconds,
    this.maxSpeedKmh,
    this.bestPaceSecondsPerKm,
  });

  final double? maxDistanceKm;
  final int? maxDurationSeconds;
  final double? maxSpeedKmh;
  final int? bestPaceSecondsPerKm;

  factory CardioRecords.from(Iterable<CardioSession> list) {
    double? maxDist;
    int? maxDur;
    double? maxSpeed;
    int? bestPace;
    for (final s in list) {
      if (s.distanceKm != null &&
          (maxDist == null || s.distanceKm! > maxDist)) {
        maxDist = s.distanceKm;
      }
      if (maxDur == null || s.durationSeconds > maxDur) {
        maxDur = s.durationSeconds;
      }
      final speed = s.speedKmh;
      if (speed != null && (maxSpeed == null || speed > maxSpeed)) {
        maxSpeed = speed;
      }
      final pace = s.paceSecondsPerKm;
      if (pace != null && (bestPace == null || pace < bestPace)) {
        bestPace = pace;
      }
    }
    return CardioRecords(
      maxDistanceKm: maxDist,
      maxDurationSeconds: maxDur,
      maxSpeedKmh: maxSpeed,
      bestPaceSecondsPerKm: bestPace,
    );
  }
}
