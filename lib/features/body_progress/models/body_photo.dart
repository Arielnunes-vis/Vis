import '../domain/body_enums.dart';

/// Foto de progresso (PROMPT 08 / progress_photos).
///
/// A captura/compressão/upload real (câmera, Supabase Storage) entra na
/// integração de mídia; aqui fica o modelo, que nunca é sobrescrito.
class BodyPhoto {
  const BodyPhoto({
    required this.id,
    required this.userId,
    required this.type,
    required this.takenAt,
    this.storagePath,
    this.localPath,
    this.thumbnailPath,
    this.note,
  });

  final String id;
  final String userId;
  final PhotoType type;
  final DateTime takenAt;
  final String? storagePath;
  final String? localPath;
  final String? thumbnailPath;
  final String? note;

  String? get displayPath => localPath ?? storagePath;

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'photo_type': type.name,
        'storage_path': storagePath,
        'local_path': localPath,
        'thumbnail': thumbnailPath,
        'note': note,
        'created_at': takenAt.toIso8601String(),
      };

  factory BodyPhoto.fromMap(Map<String, dynamic> m) => BodyPhoto(
        id: m['id'] as String,
        userId: (m['user_id'] ?? '') as String,
        type: PhotoType.fromName(m['photo_type'] as String?),
        storagePath: m['storage_path'] as String?,
        localPath: m['local_path'] as String?,
        thumbnailPath: m['thumbnail'] as String?,
        note: m['note'] as String?,
        takenAt: DateTime.parse(m['created_at'] as String),
      );
}
