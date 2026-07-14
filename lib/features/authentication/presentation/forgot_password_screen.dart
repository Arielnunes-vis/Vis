import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validators/validators.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/authentication_providers.dart';

/// Tela de recuperação de senha (PROMPT 02).
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await ref
        .read(authenticationControllerProvider.notifier)
        .forgotPassword(_email.text.trim());
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: _sent
              ? EmptyState(
                  icon: LucideIcons.mailCheck,
                  title: 'Verifique seu e-mail',
                  description:
                      'Enviamos um link de recuperação para ${_email.text.trim()}.',
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Redefinir senha', style: AppTypography.title),
                      const SizedBox(height: AppSpacing.s),
                      Text(
                        'Informe seu e-mail e enviaremos um link para criar uma nova senha.',
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      VisTextField(
                        label: 'E-mail',
                        controller: _email,
                        prefixIcon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      PrimaryButton(
                        label: 'Enviar link',
                        isLoading: _loading,
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
