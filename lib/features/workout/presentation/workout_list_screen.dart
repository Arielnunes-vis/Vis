import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/workout_plan.dart';
import '../providers/workout_providers.dart';

/// Lista de treinos do usuário (PROMPT 04).
class WorkoutListScreen extends ConsumerWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(workoutListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Treinos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(workoutEditorControllerProvider.notifier).load(null);
          context.pushNamed('workout-editor');
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('Novo treino'),
      ),
      body: plansAsync.when(
        loading: () => const LoadingWidget(message: 'Carregando treinos...'),
        error: (_, __) => ErrorState(
          onRetry: () =>
              ref.read(workoutListControllerProvider.notifier).refresh(),
        ),
        data: (plans) {
          if (plans.isEmpty) {
            return EmptyState(
              icon: LucideIcons.dumbbell,
              title: 'Nenhum treino ainda',
              description: 'Crie seu primeiro treino para começar.',
              actionLabel: 'Criar treino',
              onAction: () {
                ref.read(workoutEditorControllerProvider.notifier).load(null);
                context.pushNamed('workout-editor');
              },
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: plans.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (_, i) {
              final plan = plans[i];
              return GestureDetector(
                onLongPress: () => _actions(context, ref, plan),
                child: WorkoutCard(
                  name: '${plan.emoji ?? ''} ${plan.name}'.trim(),
                  muscleGroups: plan.muscleGroups.take(4).join(' · '),
                  durationLabel:
                      '${plan.totalDays} dias · ${plan.totalExercises} exercícios',
                  onTap: () => context.pushNamed('workout-detail', extra: plan),
                  onStart: () => context.pushNamed('workout-detail', extra: plan),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _actions(
    BuildContext context,
    WidgetRef ref,
    WorkoutPlan plan,
  ) async {
    final controller = ref.read(workoutListControllerProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.pencil),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(workoutEditorControllerProvider.notifier).load(plan);
                context.pushNamed('workout-editor');
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.copy),
              title: const Text('Duplicar'),
              onTap: () async {
                Navigator.pop(ctx);
                await controller.duplicate(plan.id);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.star),
              title: Text(plan.isActive ? 'Treino ativo' : 'Definir como ativo'),
              enabled: !plan.isActive,
              onTap: () async {
                Navigator.pop(ctx);
                await controller.setActive(plan.id);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash2),
              title: const Text('Excluir'),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await ConfirmationDialog.show(
                  context,
                  title: 'Excluir treino',
                  message: 'Tem certeza que deseja excluir "${plan.name}"?',
                  confirmLabel: 'Excluir',
                  danger: true,
                );
                if (ok) await controller.delete(plan.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
