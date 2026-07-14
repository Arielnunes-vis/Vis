import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_provider.dart';
import '../../body_progress/models/body_photo.dart';
import '../controllers/photo_controller.dart';
import '../services/photo_analysis_service.dart';
import '../services/photo_capture_service.dart';

/// Providers do módulo de fotos (PROMPT 13).

final photoCaptureServiceProvider = Provider<IPhotoCaptureService>(
  (ref) => PhotoCaptureService(),
);

/// Análise por IA — estrutura preparada (Edge Function).
final photoAnalysisServiceProvider = Provider<IPhotoAnalysisService>(
  (ref) => EdgeFunctionPhotoAnalysisService(
    ref.watch(edgeFunctionsServiceProvider),
  ),
);

final photoControllerProvider =
    NotifierProvider<PhotoController, List<BodyPhoto>>(
  PhotoController.new,
);
