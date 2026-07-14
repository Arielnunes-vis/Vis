import '../../../core/supabase/services/edge_functions_service.dart';
import '../models/photo_analysis_result.dart';

/// Serviço de análise de fotos por IA (PROMPT 13).
///
/// ESTRUTURA PREPARADA: consome a Edge Function `ai-analyze-photos`.
/// NÃO implementa lógica de modelo de visão — apenas envia as
/// referências e recebe o resultado. As regiões previstas: peitoral,
/// ombros, braços, costas, abdômen, glúteos, quadríceps, posteriores,
/// panturrilhas.
abstract interface class IPhotoAnalysisService {
  Future<PhotoAnalysisResult> compare({
    required String beforeRef,
    required String afterRef,
  });
}

final class EdgeFunctionPhotoAnalysisService implements IPhotoAnalysisService {
  const EdgeFunctionPhotoAnalysisService(this._functions);

  final IEdgeFunctionsService _functions;

  @override
  Future<PhotoAnalysisResult> compare({
    required String beforeRef,
    required String afterRef,
  }) async {
    final data = await _functions.invoke(
      'ai-analyze-photos',
      body: {'before': beforeRef, 'after': afterRef},
    );
    return PhotoAnalysisResult.fromMap(data);
  }
}
