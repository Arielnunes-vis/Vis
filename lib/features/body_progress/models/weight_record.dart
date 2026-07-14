import '../domain/body_enums.dart';

/// Registro de peso corporal (PROMPT 08 / weight_history).
///
/// Regra 001/003: nunca sobrescrever — cada pesagem é um novo registro
/// com data/hora.
class WeightRecord {
  const WeightRecord({
    required this.id,
    required this.userId,
    required this.weight,
    required this.recordedAt,
    this.bodyFat,
    this.muscleMass,
    this.note,
    this.source = WeightSource.manual,
  });

  final String id;
  final String userId;
  final double weight;
  final DateTime recordedAt;
  final double? bodyFat;
  final double? muscleMass;
  final String? note;
  final WeightSource source;

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'weight': weight,
        'body_fat': bodyFat,
        'muscle_mass': muscleMass,
        'note': note,
        'source': source.name,
        'created_at': recordedAt.toIso8601String(),
      };

  factory WeightRecord.fromMap(Map<String, dynamic> m) => WeightRecord(
        id: m['id'] as String,
        userId: (m['user_id'] ?? '') as String,
        weight: (m['weight'] as num?)?.toDouble() ?? 0,
        bodyFat: (m['body_fat'] as num?)?.toDouble(),
        muscleMass: (m['muscle_mass'] as num?)?.toDouble(),
        note: m['note'] as String?,
        source: WeightSource.fromName(m['source'] as String?),
        recordedAt: DateTime.parse(m['created_at'] as String),
      );
}
