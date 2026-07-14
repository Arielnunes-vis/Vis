import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../controllers/notification_controller.dart';
import '../domain/notification_enums.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_tile.dart';

/// Tela de notificações (PROMPT 15): histórico + configurações.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notificações'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Histórico'),
              Tab(text: 'Configurações'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_HistoryTab(), _SettingsTab()],
        ),
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);
    final c = ref.read(notificationControllerProvider.notifier);

    if (state.history.isEmpty) {
      return const EmptyState(
        title: 'Nenhuma notificação',
        description: 'Seus lembretes e conquistas aparecerão aqui.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: c.clearHistory,
            child: const Text('Limpar tudo'),
          ),
        ),
        for (final n in state.history)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: NotificationTile(
              notification: n,
              onTap: () => c.markAsRead(n.id),
            ),
          ),
      ],
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationControllerProvider).preferences;
    final c = ref.read(notificationControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        SwitchListTile(
          title: const Text('Silenciar todas'),
          value: prefs.silentMode,
          onChanged: c.setSilent,
        ),
        SwitchListTile(
          title: const Text('Som'),
          value: prefs.soundEnabled,
          onChanged: prefs.silentMode ? null : c.setSound,
        ),
        SwitchListTile(
          title: const Text('Vibração'),
          value: prefs.vibrationEnabled,
          onChanged: prefs.silentMode ? null : c.setVibration,
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
          child: SectionHeader(title: 'Categorias'),
        ),
        for (final cat in NotificationCategory.values)
          SwitchListTile(
            title: Text(cat.label),
            value: prefs.enabledCategories.contains(cat),
            onChanged: prefs.silentMode ? null : (_) => c.toggleCategory(cat),
          ),
      ],
    );
  }
}
