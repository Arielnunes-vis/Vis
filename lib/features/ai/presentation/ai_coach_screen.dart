import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../controllers/ai_chat_controller.dart';
import '../models/ai_model.dart';
import '../providers/ai_chat_providers.dart';

/// Chat do VIS Coach (PROMPT 11).
class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  static const _suggestions = [
    'Estou evoluindo?',
    'Quanto devo descansar?',
    'Meu treino está equilibrado?',
    'O que treinar hoje?',
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    _input.clear();
    ref.read(aiChatControllerProvider.notifier).send(text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiChatControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VIS Coach'),
        actions: [
          if (state.messages.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2),
              onPressed: () =>
                  ref.read(aiChatControllerProvider.notifier).clear(),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty
                ? _empty()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(AppSpacing.m),
                    itemCount: state.messages.length + (state.sending ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i >= state.messages.length) return const _Typing();
                      return _Bubble(message: state.messages[i]);
                    },
                  ),
          ),
          if (state.messages.isEmpty) _suggestionsRow(),
          _composer(state.sending),
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.sparkles, size: 40, color: AppColors.primary),
            const SizedBox(height: AppSpacing.m),
            Text('Olá! Sou o VIS Coach.',
                style: AppTypography.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Analiso seu histórico de treinos, evolução e nutrição para '
              'responder com base nos seus dados. Como posso ajudar?',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionsRow() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        children: [
          for (final s in _suggestions) ...[
            ActionChip(label: Text(s), onPressed: () => _send(s)),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _composer(bool sending) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: sending ? null : _send,
                decoration: const InputDecoration(
                  hintText: 'Pergunte ao VIS Coach...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: sending ? null : () => _send(_input.text),
              icon: const Icon(LucideIcons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final AIMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AIRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: AppTypography.body.copyWith(
            color: isUser ? AppColors.onPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
