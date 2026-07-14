import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Item selecionável (single ou multi) usado nos passos do onboarding.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.14)
            : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  selected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.disabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
