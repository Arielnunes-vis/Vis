import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/settings_enums.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_widgets.dart';

/// Tela de Configurações (PROMPT 17 / 06_UI_UX — Configurações).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _restOptions = [45, 60, 90, 120, 150, 180, 240];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          SettingsSection(
            title: 'APARÊNCIA',
            children: [
              SettingsTile(
                icon: LucideIcons.moon,
                title: 'Tema',
                subtitle: 'Escuro',
                trailing: Text('Padrão',
                    style: AppTypography.small
                        .copyWith(color: AppColors.textSecondary)),
              ),
              SettingsTile(
                icon: LucideIcons.globe,
                title: 'Idioma',
                subtitle: 'Português (Brasil)',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            title: 'PREFERÊNCIAS',
            children: [
              SettingsTile(
                icon: LucideIcons.ruler,
                title: 'Unidades',
                subtitle: settings.unitSystem.hint,
                onTap: () => _pickUnits(context, ref, settings.unitSystem),
              ),
              SettingsTile(
                icon: LucideIcons.timer,
                title: 'Tempo de descanso padrão',
                subtitle: _restLabel(settings.defaultRestSeconds),
                onTap: () =>
                    _pickRest(context, ref, settings.defaultRestSeconds),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            title: 'NOTIFICAÇÕES E FEEDBACK',
            children: [
              SettingsTile(
                icon: LucideIcons.bell,
                title: 'Notificações',
                subtitle: 'Lembretes e alertas',
                onTap: () => context.pushNamed('notifications'),
              ),
              SettingsTile(
                icon: LucideIcons.vibrate,
                title: 'Feedback tátil',
                trailing: Switch(
                  value: settings.hapticsEnabled,
                  onChanged: controller.setHaptics,
                ),
              ),
              SettingsTile(
                icon: LucideIcons.volume2,
                title: 'Som',
                subtitle: 'Ao concluir descanso e treino',
                trailing: Switch(
                  value: settings.soundEnabled,
                  onChanged: controller.setSound,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            title: 'DADOS',
            children: [
              SettingsTile(
                icon: LucideIcons.barChart3,
                title: 'Estatísticas',
                subtitle: 'Relatórios por período',
                onTap: () => context.pushNamed('analytics'),
              ),
              SettingsTile(
                icon: LucideIcons.cloud,
                title: 'Backup e sincronização',
                subtitle: 'Sincroniza quando houver conexão',
                onTap: () => AppSnackBar.show(
                  context,
                  'Seus dados ficam salvos no dispositivo e sincronizam '
                  'automaticamente quando online.',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            title: 'SOBRE',
            children: [
              SettingsTile(
                icon: LucideIcons.info,
                title: AppConstants.appName,
                subtitle:
                    'Versão ${AppConstants.appVersion} · ${AppConstants.appTagline}',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  String _restLabel(int seconds) => seconds >= 60
      ? '${(seconds / 60).toStringAsFixed(seconds % 60 == 0 ? 0 : 1)} min'
      : '$seconds s';

  Future<void> _pickUnits(
    BuildContext context,
    WidgetRef ref,
    UnitSystem current,
  ) async {
    final choice = await showModalBottomSheet<UnitSystem>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => _OptionSheet<UnitSystem>(
        title: 'Unidades',
        options: [
          for (final u in UnitSystem.values)
            (value: u, label: u.label, hint: u.hint),
        ],
        selected: current,
      ),
    );
    if (choice != null) {
      await ref.read(settingsControllerProvider.notifier).setUnitSystem(choice);
    }
  }

  Future<void> _pickRest(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final choice = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => _OptionSheet<int>(
        title: 'Tempo de descanso padrão',
        options: [
          for (final s in _restOptions)
            (value: s, label: _restLabel(s), hint: null),
        ],
        selected: current,
      ),
    );
    if (choice != null) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setDefaultRestSeconds(choice);
    }
  }
}

/// Bottom sheet genérico de seleção única.
class _OptionSheet<T> extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<({T value, String label, String? hint})> options;
  final T selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.s),
            for (final o in options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(o.label, style: AppTypography.body),
                subtitle: o.hint == null
                    ? null
                    : Text(o.hint!, style: AppTypography.small),
                trailing: o.value == selected
                    ? const Icon(LucideIcons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(o.value),
              ),
          ],
        ),
      ),
    );
  }
}
