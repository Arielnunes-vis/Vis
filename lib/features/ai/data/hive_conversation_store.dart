import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../domain/conversation_store.dart';

/// Implementação Hive do [ConversationStore] (box `vis_cache`).
final class HiveConversationStore implements ConversationStore {
  const HiveConversationStore(this._storage);

  final LocalStorageService _storage;

  String _key(String userId) => 'ai_chat_$userId';

  @override
  List<Map<String, dynamic>> read(String userId) {
    final raw =
        _storage.get<List<dynamic>>(AppConstants.boxCache, _key(userId)) ??
            const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<void> write(String userId, List<Map<String, dynamic>> messages) =>
      _storage.put(AppConstants.boxCache, _key(userId), messages);

  @override
  Future<void> clear(String userId) =>
      _storage.delete(AppConstants.boxCache, _key(userId));
}
