import '../domain/conversation_store.dart';
import '../models/ai_model.dart';
import '../repositories/conversation_repository.dart';

/// Implementação do [ConversationRepository] (persistência local).
final class ConversationRepositoryImpl implements ConversationRepository {
  ConversationRepositoryImpl({
    required ConversationStore store,
    required String? Function() currentUserId,
  })  : _store = store,
        _currentUserId = currentUserId;

  final ConversationStore _store;
  final String? Function() _currentUserId;

  String get _uid => _currentUserId() ?? 'local';

  @override
  List<AIMessage> messages() =>
      _store.read(_uid).map(AIMessage.fromMap).toList();

  @override
  Future<void> append(AIMessage message) async {
    final list = _store.read(_uid)..add(message.toMap());
    // Mantém as últimas 200 mensagens.
    final trimmed =
        list.length > 200 ? list.sublist(list.length - 200) : list;
    await _store.write(_uid, trimmed);
  }

  @override
  Future<void> clear() => _store.clear(_uid);
}
