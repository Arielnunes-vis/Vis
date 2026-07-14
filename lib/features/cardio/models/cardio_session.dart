import '../domain/cardio_enums.dart';

/// Sessão de cardio (PROMPT 09 / cardio_sessions).
class CardioSession {
  const CardioSession({
    required this.id,
    required this.userId,
    required this.type,
    required this.performedAt,
    required this.durationSeconds,
    this.distanceKm,
    this.incline,
    this.calories,
    this.avgHeartRate,
    this.rpe,
    this.note,
  });

  final String id;
  final String userId;
  final CardioType type;
  final DateTime performedAt;
  final int durationSeconds;
  final double? distanceKm;
  final double? incline;
  final double? calories;
  final int? avgHeartRate;
  final double? rpe;
  final String? note;

  int get minutes => (durationSeconds / 60).round();

  /// Velocidade média (km/h), quando há distância.
  double? get speedKmh {
    if (distanceKm == null || durationSeconds <= 0) return null;
    return distanceKm! / (durationSeconds / 3600);
  }

  /// Pace (segundos por km), quando há distância.
  int? get paceSecondsPerKm {
    if (distanceKm == null || distanceKm! <= 0) return null;
    return (durationSeconds / distanceKm!).round();
  }

  String? get paceLabel {
    final p = paceSecondsPerKm;
    if (p == null) return null;
    final m = p ~/ 60;
    final s = p % 60;
    return '$m:${s.toString().padLeft(2, '0')}/km';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'type': type.name,
        'duration': durationSeconds,
        'distance': distanceKm,
        'incline': incline,
        'calories': calories,
        'avg_heart_rate': avgHeartRate,
        'rpe': rpe,
        'note': note,
        'performed_at': performedAt.toIso8601String(),
      };

  factory CardioSession.fromMap(Map<String, dynamic> m) => CardioSession(
        id: m['id'] as String,
        userId: (m['user_id'] ?? '') as String,
        type: CardioType.fromName(m['type'] as String?),
        durationSeconds: (m['duration'] as num?)?.toInt() ?? 0,
        distanceKm: (m['distance'] as num?)?.toDouble(),
        incline: (m['incline'] as num?)?.toDouble(),
        calories: (m['calories'] as num?)?.toDouble(),
        avgHeartRate: (m['avg_heart_rate'] as num?)?.toInt(),
        rpe: (m['rpe'] as num?)?.toDouble(),
        note: m['note'] as String?,
        performedAt: DateTime.parse(m['performed_at'] as String),
      );
}
