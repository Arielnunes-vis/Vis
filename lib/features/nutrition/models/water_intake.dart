/// Registro de consumo de água (PROMPT 10).
class WaterIntake {
  const WaterIntake({
    required this.id,
    required this.userId,
    required this.amountMl,
    required this.at,
  });

  final String id;
  final String userId;
  final int amountMl;
  final DateTime at;

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'amount_ml': amountMl,
        'at': at.toIso8601String(),
      };

  factory WaterIntake.fromMap(Map<String, dynamic> m) => WaterIntake(
        id: m['id'] as String,
        userId: (m['user_id'] ?? '') as String,
        amountMl: (m['amount_ml'] as num?)?.toInt() ?? 0,
        at: DateTime.parse(m['at'] as String),
      );
}
