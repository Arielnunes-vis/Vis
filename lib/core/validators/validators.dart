import '../constants/app_constants.dart';

/// Validadores reutilizáveis de formulários.
///
/// Retornam `null` quando válido, ou uma mensagem amigável em
/// português quando inválido (nunca erros técnicos — Regra 15).
abstract final class Validators {
  const Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[\w.\-+]+@([\w-]+\.)+[\w-]{2,}$',
  );

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu e-mail.';
    if (!_emailRegex.hasMatch(v)) return 'E-mail inválido.';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Informe sua senha.';
    if (v.length < AppConstants.minPasswordLength) {
      return 'A senha deve ter ao menos ${AppConstants.minPasswordLength} caracteres.';
    }
    return null;
  }

  /// Senha forte: mínimo, com ao menos uma letra e um número.
  static String? strongPassword(String? value) {
    final base = password(value);
    if (base != null) return base;
    final v = value ?? '';
    final hasLetter = v.contains(RegExp(r'[A-Za-z]'));
    final hasNumber = v.contains(RegExp(r'\d'));
    if (!hasLetter || !hasNumber) {
      return 'Use letras e números na senha.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Confirme a senha.';
    if (value != original) return 'As senhas não coincidem.';
    return null;
  }

  static String? required(String? value, {String field = 'Campo'}) {
    if ((value ?? '').trim().isEmpty) return '$field é obrigatório.';
    return null;
  }
}
