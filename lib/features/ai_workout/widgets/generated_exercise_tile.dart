import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/generated_workout.dart';

/// Linha editável de um exercício gerado (PROMPT 12).
///
/// Permite ajustar séries, repetições e descanso, ou remover.
class GeneratedExerciseTile extends StatelessWidget {
  const GeneratedExerciseTile({
    required this.exercise,
    required this.onChanged,
    required this.onRemove,
    super.key,
  });

  final GeneratedExercise exercise;
  final ValueChanged<GeneratedExercise> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (exercise.suggestedRpe != null)
                VisBadge(label: 'RPE ${exercise.suggestedRpe!.toStringAsFixed(0)}'),
              IconButton(
                icon: const Icon(LucideIcons.trash2,
                    size: 18, color: AppColors.danger),
                onPressed: onRemove,
              ),
            ],
          ),
          Text(exercise.muscleGroup, style: AppTypography.small),
          const SizedBox(height: 10),
          Row(
            children: [
              _Stepper(
                label: 'Séries',
                value: exercise.sets,
                onChanged: (v) => onChanged(exercise.copyWith(sets: v)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reps', style: AppTypography.small),
                    Text(exercise.targetReps, style: AppTypography.body),
                  ],
                ),
              ),
              _Stepper(
                label: 'Descanso',
                value: exercise.restSeconds,
                step: 15,
                suffix: 's',
                onChanged: (v) => onChanged(exercise.copyWith(restSeconds: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.suffix = '',
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int step;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.small),
        Row(
          children: [
            _btn(LucideIcons.minus,
                () => onChanged((value - step).clamp(0, 999))),
            SizedBox(
              width: 34,
              child: Text('$value$suffix',
                  textAlign: TextAlign.center, style: AppTypography.body),
            ),
            _btn(LucideIcons.plus, () => onChanged(value + step)),
          ],
        ),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.textSecondary),
        ),
      );
}
