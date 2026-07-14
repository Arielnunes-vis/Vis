import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validators/validators.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/auth_state.dart';
import '../providers/authentication_providers.dart';

/// Tela de login (PROMPT 02).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(authenticationControllerProvider.notifier).login(
          email: _email.text.trim(),
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authenticationControllerProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        AppSnackBar.show(context, next.errorMessage!, type: SnackType.error);
      }
    });

    final state = ref.watch(authenticationControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Text('Bem-vindo de volta',
                      style: AppTypography.headline.copyWith(fontSize: 28)),
                  const SizedBox(height: AppSpacing.s),
                  Text('Entre para continuar sua evolução.',
                      style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.xl),
                  VisTextField(
                    label: 'E-mail',
                    controller: _email,
                    hint: 'voce@email.com',
                    prefixIcon: LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  VisTextField(
                    label: 'Senha',
                    controller: _password,
                    hint: '••••••••',
                    prefixIcon: LucideIcons.lock,
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      Checkbox(
                        value: _remember,
                        onChanged: (v) => setState(() => _remember = v ?? true),
                      ),
                      const Text('Lembrar sessão'),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.pushNamed('forgot-password'),
                        child: const Text('Esqueci a senha'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  PrimaryButton(
                    label: 'Entrar',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('ou', style: AppTypography.small),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  SecondaryButton(
                    label: 'Entrar com Google',
                    icon: LucideIcons.chrome,
                    onPressed: () => AppSnackBar.show(
                      context,
                      'Login social será habilitado em breve.',
                    ),
                  ),
                  if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                    const SizedBox(height: AppSpacing.s),
                    SecondaryButton(
                      label: 'Entrar com Apple',
                      icon: LucideIcons.apple,
                      onPressed: () => AppSnackBar.show(
                        context,
                        'Login com Apple será habilitado em breve.',
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.l),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Não tem conta?', style: AppTypography.caption),
                      TextButton(
                        onPressed: () => context.pushNamed('register'),
                        child: const Text('Criar conta'),
                      ),
                    ],
                  ),
                  Center(
                    child: TextButton(
                      onPressed: null,
                      child: Text(
                        'Continuar sem login',
                        style: AppTypography.small
                            .copyWith(color: AppColors.disabled),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
