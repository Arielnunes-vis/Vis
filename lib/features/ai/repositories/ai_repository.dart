import '../domain/ai_context.dart';
import '../models/ai_model.dart';
import '../services/ai_service.dart';

/// Repositório da IA — ponto único que as features usam para falar
/// com o VIS Coach. Responsável por montar o [AIContext] (a partir
/// dos demais repositórios) e delegar ao [IAIService].
///
/// A montagem do contexto real será conectada quando os módulos de
/// dados existirem; a assinatura já reflete o contrato final.
abstract interface class IAIRepository {
  Future<AIResponse> ask(String question);
  Future<AIResponse> createWorkout();
  Future<AIResponse> analyzeProgress();
}

final class AIRepository implements IAIRepository {
  const AIRepository(this._service, this._buildContext);

  final IAIService _service;

  /// Função que monta o contexto do usuário autenticado.
  /// Injetada para desacoplar a IA dos repositórios de dados.
  final Future<AIContext> Function() _buildContext;

  @override
  Future<AIResponse> ask(String question) async {
    final context = await _buildContext();
    return _service.ask(question: question, context: context);
  }

  @override
  Future<AIResponse> createWorkout() async {
    final context = await _buildContext();
    return _service.generateWorkout(context);
  }

  @override
  Future<AIResponse> analyzeProgress() async {
    final context = await _buildContext();
    return _service.analyzeProgress(context);
  }
}
