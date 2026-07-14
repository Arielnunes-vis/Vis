import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../../settings/widgets/settings_widgets.dart';

/// Tela de Perfil — conta do usuário e acesso a Configurações (PROMPT 17
/// / 06_UI_UX — Perfil). É uma das abas fixas da navegação.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          Center(
            child: Column(
              children: [
                Avatar(name: user?.name ?? user?.email, size: 84),
                const SizedBox(height: AppSpacing.m),
                Text(
                  user?.name?.isNotEmpty == true ? user!.name! : 'Atleta VIS',
                  style: AppTypography.title,
                ),
                if (user?.email != null) ...[
                  const SizedBox(height: 4),
                  Text(user!.email,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            title: 'ACOMPANHAMENTO',
            children: [
              SettingsTile(
                icon: LucideIcons.barChart3,
                title: 'Estatísticas',
                subtitle: 'Relatórios e recordes por período',
                onTap: () => context.pushNamed('analytics'),
              ),
              SettingsTile(
                icon: LucideIcons.trendingUp,
                title: 'Evolução',
                subtitle: 'Peso, medidas e fotos',
                onTap: () => context.goNamed('progress'),
              ),
              SettingsTile(
                icon: LucideIcons.bell,
                title: 'Notificações',
                onTap: () => context.pushNamed('notifications'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            title: 'CONTA',
            children: [
              SettingsTile(
                icon: LucideIcons.settings,
                title: 'Configurações',
                onTap: () => context.pushNamed('settings'),
              ),
              SettingsTile(
                icon: LucideIcons.logOut,
                title: 'Sair',
                onTap: () => _logout(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Sair da conta',
      message: 'Você precisará entrar novamente para acessar o VIS.',
      confirmLabel: 'Sair',
      danger: true,
    );
    if (!confirmed) return;
    await ref.read(authenticationControllerProvider.notifier).logout();
    // O redirect do GoRouter leva ao login quando a sessão é encerrada.
  }
}
