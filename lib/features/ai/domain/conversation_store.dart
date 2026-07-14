/// Armazenamento local da conversa com o VIS Coach (PROMPT 11).
///
/// Persiste o histórico por usuário para funcionar offline (leitura).
abstract interface class ConversationStore {
  List<Map<String, dynamic>> read(String userId);
  Future<void> write(String userId, List<Map<String, dynamic>> messages);
  Future<void> clear(String userId);
}
