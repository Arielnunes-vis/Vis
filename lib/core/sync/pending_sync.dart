/// Representa uma operação pendente de sincronização (offline-first).
///
/// PROMPT 01: estrutura preparada. A execução real (envio ao Supabase)
/// será implementada junto aos módulos que gravam offline (treinos,
/// peso, medidas, cardio).
enum SyncOperation { insert, update, softDelete }

class PendingSync {
  const PendingSync({
    required this.id,
    required this.table,
    required this.operation,
    required this.payload,
    required this.createdAt,
    this.retries = 0,
  });

  final String id;
  final String table;
  final SyncOperation operation;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retries;

  PendingSync copyWith({int? retries}) => PendingSync(
        id: id,
        table: table,
        operation: operation,
        payload: payload,
        createdAt: createdAt,
        retries: retries ?? this.retries,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'table': table,
        'operation': operation.name,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
        'retries': retries,
      };

  factory PendingSync.fromMap(Map<String, dynamic> map) => PendingSync(
        id: map['id'] as String,
        table: map['table'] as String,
        operation: SyncOperation.values.byName(map['operation'] as String),
        payload: Map<String, dynamic>.from(map['payload'] as Map),
        createdAt: DateTime.parse(map['created_at'] as String),
        retries: (map['retries'] as int?) ?? 0,
      );
}
