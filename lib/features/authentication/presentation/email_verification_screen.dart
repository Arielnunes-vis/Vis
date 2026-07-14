import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/authentication_providers.dart';

/// Tela de verificação de e-mail, quando o Supabase exigir confirmação.
class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(currentUserProvider).value?.email;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.mailQuestion,
                  size: 48, color: AppColors.primary),
              const SizedBox(height: AppSpacing.l),
              Text('Confirme seu e-mail',
                  style: AppTypography.title, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Enviamos um link de confirmação${email != null ? ' para $email' : ''}. '
                'Confirme para continuar.',
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Atualizar status',
                icon: LucideIcons.refreshCw,
                onPressed: () async {
                  await ref
                      .read(authenticationControllerProvider.notifier)
                      .reloadUser();
                  if (context.mounted) {
                    AppSnackBar.show(
                      context,
                      'Status atualizado. Se já confirmou, você será redirecionado.',
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.s),
              SecondaryButton(
                label: 'Reenviar e-mail',
                onPressed: () {
                  if (email != null) {
                    ref
                        .read(authenticationControllerProvider.notifier)
                        .resendConfirmation(email);
                    AppSnackBar.show(context, 'E-mail reenviado.',
                        type: SnackType.success);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.s),
              TextButton(
                onPressed: () => context.goNamed('login'),
                child: const Text('Voltar ao login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
