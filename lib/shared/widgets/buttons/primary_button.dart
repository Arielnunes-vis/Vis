import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Botão primário do VIS (07_DESIGN_SYSTEM.md).
///
/// Altura 56, raio 16, largura total, cor Primary. Suporta estado de
/// carregamento e ícone opcional. Nunca criar variações duplicadas —
/// reutilizar este componente (Regra 3).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.onPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
