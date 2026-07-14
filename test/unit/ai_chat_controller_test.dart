import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/ai/domain/ai_context.dart';
import 'package:vis/features/ai/models/ai_model.dart';
import 'package:vis/features/ai/providers/ai_chat_providers.dart';
import 'package:vis/features/ai/providers/ai_providers.dart';
import 'package:vis/features/ai/repositories/ai_repository.dart';
import 'package:vis/features/ai/repositories/conversation_repository.dart';

class InMemConversation implements ConversationRepository {
  final List<AIMessage> _list = [];
  @override
  List<AIMessage> messages() => List.unmodifiable(_list);
  @override
  Future<void> append(AIMessage message) async => _list.add(message);
  @override
  Future<void> clear() async => _list.clear();
}

class FakeAIRepository implements IAIRepository {
  FakeAIRepository({this.fail = false});
  final bool fail;

  @override
  Future<AIResponse> ask(String question) async {
    if (fail) throw Exception('offline');
    return const AIResponse(message: 'Com base no seu histórico, sim!');
  }

  @override
  Future<AIResponse> createWorkout() => throw UnimplementedError();
  @override
  Future<AIResponse> analyzeProgress() => throw UnimplementedError();
}

ProviderContainer _container(FakeAIRepository ai) => ProviderContainer(
      overrides: [
        conversationRepositoryProvider.overrideWithValue(InMemConversation()),
        aiRepositoryProvider.overrideWithValue(ai),
      ],
    );

void main() {
  test('enviar mensagem adiciona pergunta e resposta', () async {
    final c = _container(FakeAIRepository());
    addTearDown(c.dispose);

    final ctrl = c.read(aiChatControllerProvider.notifier);
    await ctrl.send('Estou evoluindo?');

    final state = c.read(aiChatControllerProvider);
    expect(state.messages.length, 2);
    expect(state.messages.first.role, AIRole.user);
    expect(state.messages.last.role, AIRole.coach);
    expect(state.sending, isFalse);
  });

  test('falha do backend gera mensagem amigável', () async {
    final c = _container(FakeAIRepository(fail: true));
    addTearDown(c.dispose);

    final ctrl = c.read(aiChatControllerProvider.notifier);
    await ctrl.send('Monte um treino');

    final state = c.read(aiChatControllerProvider);
    expect(state.messages.last.role, AIRole.coach);
    expect(state.error, isNotNull);
    expect(state.sending, isFalse);
  });

  // Garante que o AIContext serializa (usado pelo builder → Edge Function).
  test('AIContext serializa para JSON', () {
    const ctx = AIContext(profile: {'x': 1});
    expect(ctx.toJson()['profile'], {'x': 1});
  });
}
