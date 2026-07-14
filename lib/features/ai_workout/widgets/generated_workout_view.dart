import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/generated_workout.dart';
import '../models/generation_result.dart';
import 'generated_exercise_tile.dart';

/// Visualização + edição do treino gerado (PROMPT 12).
class GeneratedWorkoutView extends StatelessWidget {
  const GeneratedWorkoutView({
    required this.result,
    required this.workout,
    required this.onRename,
    required this.onExerciseChanged,
    required this.onExerciseRemoved,
    this.onRegenerate,
    this.onAddExercise,
    super.key,
  });

  final WorkoutGenerationResult result;
  final GeneratedWorkout workout;
  final ValueChanged<String> onRename;
  final void Function(int dayIndex, int exIndex, GeneratedExercise updated)
      onExerciseChanged;
  final void Function(int dayIndex, int exIndex) onExerciseRemoved;
  final void Function(int dayIndex, int exIndex)? onRegenerate;
  final void Function(int dayIndex)? onAddExercise;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        // Recomendação da IA (explica escolhas).
        if (result.recommendations.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: InsightCard(
              message: result.recommendations.first.reason ??
                  result.recommendations.first.message,
            ),
          ),

        // Resumo.
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(workout.name, style: AppTypography.title),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.pencil, size: 18),
                    onPressed: () => _rename(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${workout.goal.label} · ${workout.split.label}',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat('Dias', '${workout.days.length}'),
                  _stat('Exercícios', '${workout.totalExercises}'),
                  _stat('Séries', '${workout.totalSets}'),
                  if (result.estimatedMinutes != null)
                    _stat('Tempo', '${result.estimatedMinutes} min'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        // Dias e exercícios.
        for (var d = 0; d < workout.days.length; d++) ...[
          SectionHeader(title: workout.days[d].name),
          if (workout.days[d].focus != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(workout.days[d].focus!, style: AppTypography.small),
            ),
          const SizedBox(height: AppSpacing.s),
          for (var e = 0; e < workout.days[d].exercises.length; e++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: Column(
                children: [
                  GeneratedExerciseTile(
                    exercise: workout.days[d].exercises[e],
                    onChanged: (updated) => onExerciseChanged(d, e, updated),
                    onRemove: () => onExerciseRemoved(d, e),
                  ),
                  if (onRegenerate != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(LucideIcons.refreshCw, size: 14),
                        label: const Text('Trocar (IA)'),
                        onPressed: () => onRegenerate!(d, e),
                      ),
                    ),
                ],
              ),
            ),
          if (onAddExercise != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Adicionar exercício'),
                onPressed: () => onAddExercise!(d),
              ),
            ),
          const SizedBox(height: AppSpacing.m),
        ],
      ],
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(value, style: AppTypography.subtitle),
          Text(label, style: AppTypography.small),
        ],
      );

  Future<void> _rename(BuildContext context) async {
    final controller = TextEditingController(text: workout.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renomear treino'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.isNotEmpty) onRename(name);
  }
}
