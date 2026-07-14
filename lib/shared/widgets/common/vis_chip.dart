import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Chip selecionável (grupo muscular, equipamento, nível, objetivo).
class VisChip extends StatelessWidget {
  const VisChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.body.copyWith(
            fontSize: 14,
            color: selected ? AppColors.onPrimary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
