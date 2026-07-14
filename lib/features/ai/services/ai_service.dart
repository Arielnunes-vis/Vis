import '../../../core/supabase/services/edge_functions_service.dart';
import '../domain/ai_context.dart';
import '../models/ai_model.dart';

/// Interface da camada de IA (VIS Coach).
///
/// Abstrai a origem das respostas. A implementação padrão consome
/// Supabase Edge Functions — o app nunca fala com o OpenAI direto.
abstract interface class IAIService {
  Future<AIResponse> ask({
    required String question,
    required AIContext context,
  });

  Future<AIResponse> generateWorkout(AIContext context);
  Future<AIResponse> analyzeProgress(AIContext context);
}

/// Implementação via Edge Functions (estrutura preparada — PROMPT 01/05).
///
/// Os nomes das funções seguem 09_SUPABASE_SQL.md. As chamadas reais
/// serão ativadas quando as Edge Functions existirem no backend.
final class EdgeFunctionAIService implements IAIService {
  const EdgeFunctionAIService(this._functions);

  final IEdgeFunctionsService _functions;

  static const String _fnAsk = 'ai-answer';
  static const String _fnWorkout = 'ai-create-workout';
  static const String _fnProgress = 'ai-analyze-progress';

  @override
  Future<AIResponse> ask({
    required String question,
    required AIContext context,
  }) async {
    final data = await _functions.invoke(
      _fnAsk,
      body: {'question': question, 'context': context.toJson()},
    );
    return AIResponse.fromMap(data);
  }

  @override
  Future<AIResponse> generateWorkout(AIContext context) async {
    final data = await _functions.invoke(
      _fnWorkout,
      body: {'context': context.toJson()},
    );
    return AIResponse.fromMap(data);
  }

  @override
  Future<AIResponse> analyzeProgress(AIContext context) async {
    final data = await _functions.invoke(
      _fnProgress,
      body: {'context': context.toJson()},
    );
    return AIResponse.fromMap(data);
  }
}
