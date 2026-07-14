import 'package:image_picker/image_picker.dart';

/// Origem da captura de foto.
enum PhotoSourceKind { camera, gallery }

/// Serviço de captura de fotos (PROMPT 13).
///
/// Encapsula o `image_picker` com compressão/redimensionamento. O upload
/// para o Supabase Storage (bucket `progress_photos`) entra na camada de
/// sincronização; aqui a foto é referenciada pelo caminho local.
abstract interface class IPhotoCaptureService {
  Future<String?> capture(PhotoSourceKind source);
}

final class PhotoCaptureService implements IPhotoCaptureService {
  PhotoCaptureService([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> capture(PhotoSourceKind source) async {
    final file = await _picker.pickImage(
      source: source == PhotoSourceKind.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
    );
    return file?.path;
  }
}
