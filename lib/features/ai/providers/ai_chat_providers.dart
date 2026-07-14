import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../controllers/ai_chat_controller.dart';
import '../data/conversation_repository_impl.dart';
import '../data/hive_conversation_store.dart';
import '../repositories/conversation_repository.dart';

/// Providers do chat do VIS Coach (PROMPT 11).

final conversationRepositoryProvider = Provider<ConversationRepository>(
  (ref) => ConversationRepositoryImpl(
    store: const HiveConversationStore(LocalStorageService()),
    currentUserId: () =>
        ref.read(authenticationRepositoryProvider).currentUser?.id,
  ),
);

final aiChatControllerProvider =
    NotifierProvider<AIChatController, AIChatState>(
  AIChatController.new,
);
