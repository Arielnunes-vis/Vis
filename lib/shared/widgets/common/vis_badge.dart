import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Selo compacto (Novo, PR, Recorde, IA, Favorito) — 07_DESIGN_SYSTEM.md.
class VisBadge extends StatelessWidget {
  const VisBadge({
    required this.label,
    this.color = AppColors.primary,
    super.key,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.small.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
