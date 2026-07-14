import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../onboarding/domain/onboarding_options.dart';
import '../../workout/widgets/exercise_picker_sheet.dart';
import '../controllers/ai_workout_controller.dart';
import '../domain/ai_workout_enums.dart';
import '../models/generated_workout.dart';
import '../providers/ai_workout_providers.dart';
import '../widgets/generated_workout_view.dart';

/// Gerador Inteligente de Treinos (PROMPT 12).
class AIWorkoutScreen extends ConsumerWidget {
  const AIWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiWorkoutControllerProvider);
    final c = ref.read(aiWorkoutControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerar treino com IA'),
        leading: state.phase == GenerationPhase.result
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: c.backToForm,
              )
            : null,
      ),
      body: switch (state.phase) {
        GenerationPhase.form => _Form(state: state, c: c),
        GenerationPhase.generating => const LoadingWidget(
            message: 'Montando seu treino com base no seu histórico...',
          ),
        GenerationPhase.error => ErrorState(
            message: state.error ?? 'Não foi possível gerar o treino.',
            onRetry: c.backToForm,
          ),
        GenerationPhase.result => _Result(state: state, c: c),
      },
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.state, required this.c});
  final AIWorkoutState state;
  final AIWorkoutController c;

  @override
  Widget build(BuildContext context) {
    final r = state.request;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        _group(
          'Objetivo',
          [
            for (final g in WorkoutGoal.values)
              VisChip(
                label: g.label,
                selected: r.goal == g,
                onTap: () => c.setGoal(g),
              ),
          ],
        ),
        _group(
          'Dias por semana',
          [
            for (final d in const [2, 3, 4, 5, 6, 7])
              VisChip(
                label: '$d',
                selected: r.daysPerWeek == d,
                onTap: () => c.setDays(d),
              ),
          ],
        ),
        _group(
          'Tempo por treino',
          [
            for (final m in const [30, 45, 60, 75, 90])
              VisChip(
                label: '$m min',
                selected: r.minutesPerWorkout == m,
                onTap: () => c.setMinutes(m),
              ),
          ],
        ),
        _group(
          'Onde treina',
          [
            for (final l in WorkoutLocation.values)
              VisChip(
                label: l.label,
                selected: r.location == l,
                onTap: () => c.setLocation(l),
              ),
          ],
        ),
        _group(
          'Experiência',
          [
            for (final e in WorkoutExperience.values)
              VisChip(
                label: e.label,
                selected: r.experience == e,
                onTap: () => c.setExperience(e),
              ),
          ],
        ),
        _group(
          'Equipamentos disponíveis',
          [
            for (final eq in OnboardingOptions.equipment)
              VisChip(
                label: eq,
                selected: r.equipment.contains(eq),
                onTap: () => c.toggleEquipment(eq),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.m),
          child: VisTextField(
            label: 'Lesões / limitações (opcional)',
            hint: 'ex.: dor no ombro, cirurgia no joelho',
            onChanged: c.setRestrictionNotes,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.m),
          child: VisTextField(
            label: 'Exercícios que você evita (opcional)',
            hint: 'ex.: agachamento, barra fixa',
            onChanged: c.setAvoidExercises,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        PrimaryButton(
          label: 'Gerar treino',
          icon: Icons.auto_awesome,
          onPressed: c.generate,
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          'O VIS Coach usa seu histórico, objetivos e equipamentos para montar o treino.',
          style: AppTypography.small,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _group(String title, List<Widget> chips) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.s),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
          ],
        ),
      );
}

class _Result extends StatelessWidget {
  const _Result({required this.state, required this.c});
  final AIWorkoutState state;
  final AIWorkoutController c;

  @override
  Widget build(BuildContext context) {
    final result = state.result!;
    final workout = state.workout!;
    return Column(
      children: [
        Expanded(
          child: GeneratedWorkoutView(
            result: result,
            workout: workout,
            onRename: c.renameWorkout,
            onExerciseChanged: c.updateExercise,
            onExerciseRemoved: c.removeExercise,
            onRegenerate: c.regenerateExercise,
            onAddExercise: (dayIndex) async {
              final ref = await ExercisePickerSheet.show(context);
              if (ref != null) {
                c.addExercise(
                  dayIndex,
                  GeneratedExercise(
                    name: ref.name,
                    muscleGroup: ref.muscleGroup,
                    sets: 3,
                    targetReps: '8-12',
                    equipment: ref.equipment,
                    restSeconds: 90,
                  ),
                );
              }
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Avaliar',
                    onPressed: () => _feedback(context, c),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: PrimaryButton(
                    label: 'Salvar treino',
                    isLoading: state.isSaving,
                    onPressed: () async {
                      final ok = await c.save();
                      if (ok && context.mounted) {
                        AppSnackBar.show(context, 'Treino salvo!',
                            type: SnackType.success);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _feedback(BuildContext context, AIWorkoutController c) async {
    GenerationRating? selected;
    final comment = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.l,
            right: AppSpacing.l,
            top: AppSpacing.l,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Como foi o treino?', style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.m),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in GenerationRating.values)
                    VisChip(
                      label: r.label,
                      selected: selected == r,
                      onTap: () => setModalState(() => selected = r),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              VisTextField(
                label: 'Comentário (opcional)',
                controller: comment,
              ),
              const SizedBox(height: AppSpacing.l),
              PrimaryButton(
                label: 'Enviar avaliação',
                onPressed: selected == null
                    ? null
                    : () {
                        c.submitFeedback(selected!, comment.text.trim());
                        Navigator.pop(ctx);
                        AppSnackBar.show(context, 'Obrigado pela avaliação!',
                            type: SnackType.success);
                      },
              ),
            ],
          ),
        ),
      ),
    );
    comment.dispose();
  }
}
