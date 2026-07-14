import '../models/ai_model.dart';

/// Contrato do histórico de conversa com o VIS Coach (PROMPT 11).
abstract interface class ConversationRepository {
  List<AIMessage> messages();
  Future<void> append(AIMessage message);
  Future<void> clear();
}
