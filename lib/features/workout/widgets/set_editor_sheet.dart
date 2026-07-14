import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/workout_enums.dart';
import '../providers/workout_providers.dart';

/// Editor das séries planejadas de um exercício (PROMPT 04).
///
/// Permite ajustar técnica (SetType), repetições-alvo, descanso e a
/// quantidade de séries. Lê o exercício do rascunho do editor.
class SetEditorSheet extends ConsumerWidget {
  const SetEditorSheet({
    required this.dayId,
    required this.exerciseId,
    super.key,
  });

  final String dayId;
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(workoutEditorControllerProvider);
    final c = ref.read(workoutEditorControllerProvider.notifier);

    final day = plan.days.firstWhere((d) => d.id == dayId);
    final exercise = day.exercises.firstWhere((e) => e.id == exerciseId);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.m,
        right: AppSpacing.m,
        top: AppSpacing.m,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.m,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.exercise.name, style: AppTypography.subtitle),
            Text(exercise.exercise.muscleGroup, style: AppTypography.small),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: ListView.separated(
                itemCount: exercise.sets.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.s),
                itemBuilder: (_, i) {
                  final set = exercise.sets[i];
                  return CardContainer(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Série ${set.setNumber}',
                                style: AppTypography.body
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, size: 18),
                              onPressed: () => c.removeSet(dayId, exerciseId, i),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<SetType>(
                                value: set.type,
                                isExpanded: true,
                                decoration:
                                    const InputDecoration(labelText: 'Tipo'),
                                items: [
                                  for (final t in SetType.values)
                                    DropdownMenuItem(
                                      value: t,
                                      child: Text(t.label,
                                          style: AppTypography.body
                                              .copyWith(fontSize: 14)),
                                    ),
                                ],
                                onChanged: (t) => c.updateSet(
                                  dayId,
                                  exerciseId,
                                  i,
                                  set.copyWith(type: t),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            SizedBox(
                              width: 90,
                              child: TextFormField(
                                initialValue: set.targetReps,
                                decoration:
                                    const InputDecoration(labelText: 'Reps'),
                                onChanged: (v) => c.updateSet(
                                  dayId,
                                  exerciseId,
                                  i,
                                  set.copyWith(targetReps: v),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            SecondaryButton(
              label: 'Adicionar série',
              icon: LucideIcons.plus,
              onPressed: () => c.addSet(dayId, exerciseId),
            ),
            const SizedBox(height: AppSpacing.s),
            PrimaryButton(
              label: 'Concluir',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
