import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validators/validators.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/auth_state.dart';
import '../providers/authentication_providers.dart';

/// Tela de cadastro (PROMPT 02).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _name.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      AppSnackBar.show(context, 'Aceite os termos para continuar.',
          type: SnackType.warning);
      return;
    }
    FocusScope.of(context).unfocus();
    final fullName =
        '${_name.text.trim()} ${_lastName.text.trim()}'.trim();
    ref.read(authenticationControllerProvider.notifier).register(
          email: _email.text.trim(),
          password: _password.text,
          name: fullName,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authenticationControllerProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        AppSnackBar.show(context, next.errorMessage!, type: SnackType.error);
      } else if (next.status == AuthStatus.emailUnconfirmed) {
        context.goNamed('verify-email');
      }
    });

    final isLoading = ref.watch(authenticationControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VisTextField(
                  label: 'Nome',
                  controller: _name,
                  prefixIcon: LucideIcons.user,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, field: 'Nome'),
                ),
                const SizedBox(height: AppSpacing.m),
                VisTextField(
                  label: 'Sobrenome',
                  controller: _lastName,
                  prefixIcon: LucideIcons.user,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, field: 'Sobrenome'),
                ),
                const SizedBox(height: AppSpacing.m),
                VisTextField(
                  label: 'E-mail',
                  controller: _email,
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.m),
                VisTextField(
                  label: 'Senha',
                  controller: _password,
                  prefixIcon: LucideIcons.lock,
                  obscure: true,
                  validator: Validators.strongPassword,
                ),
                const SizedBox(height: AppSpacing.m),
                VisTextField(
                  label: 'Confirmar senha',
                  controller: _confirm,
                  prefixIcon: LucideIcons.lock,
                  obscure: true,
                  validator: (v) =>
                      Validators.confirmPassword(v, _password.text),
                ),
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (v) =>
                          setState(() => _acceptedTerms = v ?? false),
                    ),
                    Expanded(
                      child: Text('Aceito os termos de uso.',
                          style: AppTypography.caption),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                PrimaryButton(
                  label: 'Criar conta',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
