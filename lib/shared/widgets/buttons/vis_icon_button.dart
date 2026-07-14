import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Botão de ícone circular (48x48) do Design System.
class VisIconButton extends StatelessWidget {
  const VisIconButton({
    required this.icon,
    required this.onPressed,
    this.background = AppColors.card,
    this.color = AppColors.textPrimary,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color background;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 22),
        tooltip: tooltip,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      ),
    );
  }
}
