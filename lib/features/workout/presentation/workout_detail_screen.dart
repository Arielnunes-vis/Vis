import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../workout_session/providers/workout_session_providers.dart';
import '../models/workout_day.dart';
import '../models/workout_plan.dart';
import '../providers/workout_providers.dart';

/// Detalhe (somente leitura) de um plano de treino (PROMPT 04).
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({required this.plan, super.key});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.name),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            onPressed: () {
              ref.read(workoutEditorControllerProvider.notifier).load(plan);
              context.pushNamed('workout-editor');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${plan.emoji ?? ''} ${plan.name}'.trim(),
                    style: AppTypography.title),
                const SizedBox(height: 4),
                Text(plan.goal.label, style: AppTypography.caption),
                if (plan.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s),
                  Text(plan.description, style: AppTypography.body),
                ],
                const SizedBox(height: AppSpacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _stat('Dias', '${plan.totalDays}'),
                    _stat('Exercícios', '${plan.totalExercises}'),
                    _stat('Séries', '${plan.totalSets}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          for (final day in plan.days) ...[
            SectionHeader(title: day.name),
            const SizedBox(height: AppSpacing.s),
            CardContainer(
              child: Column(
                children: [
                  for (final ex in day.exercises)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ex.exercise.name, style: AppTypography.body),
                                Text(ex.exercise.muscleGroup,
                                    style: AppTypography.small),
                              ],
                            ),
                          ),
                          Text(
                            '${ex.workingSets}x ${ex.sets.isNotEmpty ? ex.sets.first.targetReps : '-'}',
                            style: AppTypography.body
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
          const SizedBox(height: AppSpacing.s),
          PrimaryButton(
            label: 'Iniciar treino',
            icon: LucideIcons.play,
            onPressed: () => _start(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    if (plan.days.isEmpty) {
      AppSnackBar.show(context, 'Adicione ao menos um dia ao treino.',
          type: SnackType.warning);
      return;
    }
    var day = plan.days.first;
    if (plan.days.length > 1) {
      final chosen = await showModalBottomSheet<WorkoutDay>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final d in plan.days)
                ListTile(
                  title: Text(d.name),
                  subtitle: Text('${d.totalExercises} exercícios'),
                  onTap: () => Navigator.pop(ctx, d),
                ),
            ],
          ),
        ),
      );
      if (chosen == null) return;
      day = chosen;
    }
    await ref
        .read(workoutSessionControllerProvider.notifier)
        .start(plan, day);
    if (context.mounted) context.pushNamed('workout-session');
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(value, style: AppTypography.subtitle),
          Text(label, style: AppTypography.small),
        ],
      );
}
