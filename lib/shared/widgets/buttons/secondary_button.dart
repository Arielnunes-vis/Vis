import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Botão secundário: fundo transparente, borda e texto Primary.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(56),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
