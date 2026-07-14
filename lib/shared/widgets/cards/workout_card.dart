import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../common/card_container.dart';

/// Card de treino: nome, grupo muscular, duração e ação de início.
///
/// Componente de apresentação puro — recebe dados prontos, sem lógica.
class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    required this.name,
    required this.muscleGroups,
    this.durationLabel,
    this.onTap,
    this.onStart,
    super.key,
  });

  final String name;
  final String muscleGroups;
  final String? durationLabel;
  final VoidCallback? onTap;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.subtitle),
                const SizedBox(height: 4),
                Text(muscleGroups, style: AppTypography.caption),
                if (durationLabel != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(LucideIcons.clock,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(durationLabel!, style: AppTypography.small),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onStart != null)
            IconButton(
              onPressed: onStart,
              icon: const Icon(LucideIcons.play, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
