import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/providers/authentication_providers.dart';
import '../../body_progress/domain/body_enums.dart';
import '../../body_progress/models/body_photo.dart';
import '../../body_progress/providers/body_progress_providers.dart';
import '../providers/photo_providers.dart';
import '../services/photo_capture_service.dart';

/// Controller das fotos de progresso (PROMPT 13).
///
/// Usa o repositório de evolução corporal (módulo 08) para persistência.
class PhotoController extends Notifier<List<BodyPhoto>> {
  final Uuid _uuid = const Uuid();

  @override
  List<BodyPhoto> build() =>
      ref.read(bodyProgressRepositoryProvider).photos();

  List<BodyPhoto> ofType(PhotoType type) =>
      state.where((p) => p.type == type).toList();

  /// Captura (câmera/galeria) e registra a foto na pose informada.
  /// Retorna `false` se o usuário cancelar a captura.
  Future<bool> capture({
    required PhotoType type,
    required PhotoSourceKind source,
  }) async {
    final path = await ref.read(photoCaptureServiceProvider).capture(source);
    if (path == null) return false;

    final uid =
        ref.read(authenticationRepositoryProvider).currentUser?.id ?? '';
    await ref.read(bodyProgressRepositoryProvider).addPhoto(
          BodyPhoto(
            id: _uuid.v4(),
            userId: uid,
            type: type,
            takenAt: DateTime.now(),
            localPath: path,
          ),
        );
    state = ref.read(bodyProgressRepositoryProvider).photos();
    return true;
  }
}
