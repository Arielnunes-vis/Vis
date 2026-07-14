import '../domain/body_enums.dart';

/// Diferença de uma medida entre duas medições (para comparação).
class MeasurementDelta {
  const MeasurementDelta({
    required this.field,
    required this.current,
    this.previous,
  });

  final MeasurementField field;
  final double current;
  final double? previous;

  double? get delta => previous == null ? null : current - previous!;

  /// -1 reduziu, 0 igual, 1 aumentou, null sem comparação.
  int? get direction {
    final d = delta;
    if (d == null) return null;
    if (d.abs() < 0.05) return 0;
    return d > 0 ? 1 : -1;
  }
}

/// Registro de medidas corporais (PROMPT 08 / body_measurements).
///
/// Guarda um mapa campo→valor (cm). Nunca sobrescreve — cada medição
/// é um novo registro datado.
class MeasurementRecord {
  const MeasurementRecord({
    required this.id,
    required this.userId,
    required this.recordedAt,
    this.values = const {},
    this.weight,
    this.bodyFat,
    this.note,
  });

  final String id;
  final String userId;
  final DateTime recordedAt;

  /// Chave = MeasurementField.name; valor em cm.
  final Map<String, double> values;
  final double? weight;
  final double? bodyFat;
  final String? note;

  double? value(MeasurementField f) => values[f.name];

  /// Compara este registro (atual) com [previous], campo a campo.
  List<MeasurementDelta> compareTo(MeasurementRecord? previous) {
    return [
      for (final f in MeasurementField.values)
        if (values.containsKey(f.name))
          MeasurementDelta(
            field: f,
            current: values[f.name]!,
            previous: previous?.values[f.name],
          ),
    ];
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'values': values,
        'weight': weight,
        'body_fat': bodyFat,
        'note': note,
        'created_at': recordedAt.toIso8601String(),
      };

  factory MeasurementRecord.fromMap(Map<String, dynamic> m) => MeasurementRecord(
        id: m['id'] as String,
        userId: (m['user_id'] ?? '') as String,
        values: {
          for (final e in (m['values'] as Map? ?? {}).entries)
            e.key as String: (e.value as num).toDouble(),
        },
        weight: (m['weight'] as num?)?.toDouble(),
        bodyFat: (m['body_fat'] as num?)?.toDouble(),
        note: m['note'] as String?,
        recordedAt: DateTime.parse(m['created_at'] as String),
      );
}
