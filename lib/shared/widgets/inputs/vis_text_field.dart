import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Campo de texto padrão do VIS, integrado ao [InputDecorationTheme].
///
/// Suporta rótulo, ícone, alternância de senha e validação. Reutilizado
/// por autenticação, onboarding, registros etc.
class VisTextField extends StatefulWidget {
  const VisTextField({
    required this.label,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  State<VisTextField> createState() => _VisTextFieldState();
}

class _VisTextFieldState extends State<VisTextField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.caption),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20, color: AppColors.textSecondary)
                : null,
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
