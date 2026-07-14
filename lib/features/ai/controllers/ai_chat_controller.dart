import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../core/logger/app_logger.dart';
import '../models/ai_model.dart';
import '../providers/ai_chat_providers.dart';
import '../providers/ai_providers.dart';

/// Estado do chat com o VIS Coach.
class AIChatState {
  const AIChatState({
    this.messages = const [],
    this.sending = false,
    this.error,
  });

  final List<AIMessage> messages;
  final bool sending;
  final String? error;

  AIChatState copyWith({
    List<AIMessage>? messages,
    bool? sending,
    String? error,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      error: error,
    );
  }
}

/// Controller do chat (PROMPT 11).
///
/// Antes de responder, o [AIRepository] monta o contexto real do
/// usuário (Regra 026) e chama a Edge Function. Offline / backend
/// indisponível → mensagem amigável, sem travar o histórico.
class AIChatController extends Notifier<AIChatState> {
  @override
  AIChatState build() {
    final history = ref.read(conversationRepositoryProvider).messages();
    return AIChatState(messages: history);
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;

    final repo = ref.read(conversationRepositoryProvider);
    final userMsg =
        AIMessage(role: AIRole.user, content: trimmed, createdAt: DateTime.now());
    await repo.append(userMsg);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      sending: true,
      error: null,
    );

    try {
      final response = await ref.read(aiRepositoryProvider).ask(trimmed);
      final content = response.reason != null && response.reason!.isNotEmpty
          ? '${response.message}\n\n${response.reason}'
          : response.message;
      final coach = AIMessage(
        role: AIRole.coach,
        content: content,
        createdAt: DateTime.now(),
      );
      await repo.append(coach);
      state = state.copyWith(
        messages: [...state.messages, coach],
        sending: false,
      );
    } on AppException catch (e) {
      _fail(e.message);
    } catch (e, st) {
      AppLogger.e('[AIChat] falha inesperada ao consultar o Coach',
          error: e, stackTrace: st);
      _fail('O VIS Coach está indisponível no momento. Tente novamente.');
    }
  }

  Future<void> clear() async {
    await ref.read(conversationRepositoryProvider).clear();
    state = const AIChatState();
  }

  void _fail(String message) {
    final coach = AIMessage(
      role: AIRole.coach,
      content: message,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, coach],
      sending: false,
      error: message,
    );
  }
}
