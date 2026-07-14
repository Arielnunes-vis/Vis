import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../controllers/workout_session_controller.dart';
import '../domain/session_enums.dart';
import '../providers/workout_session_providers.dart';
import '../widgets/rest_timer_bar.dart';
import '../widgets/session_set_row.dart';

String formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

/// Tela de execução do treino (PROMPT 06).
class WorkoutSessionScreen extends ConsumerWidget {
  const WorkoutSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActive =
        ref.watch(workoutSessionControllerProvider.select((s) => s.hasActive));
    final c = ref.read(workoutSessionControllerProvider.notifier);

    if (!hasActive) {
      return const Scaffold(
        body: EmptyState(
          icon: LucideIcons.dumbbell,
          title: 'Nenhum treino em andamento',
        ),
      );
    }

    final session = ref.read(workoutSessionControllerProvider).session!;
    final paused = ref.watch(
        workoutSessionControllerProvider.select((s) => s.session?.isPaused ?? false));

    return Scaffold(
      appBar: AppBar(
        title: Text(session.dayName),
        actions: [
          IconButton(
            icon: Icon(paused ? LucideIcons.play : LucideIcons.pause),
            tooltip: paused ? 'Retomar' : 'Pausar',
            onPressed: () => paused ? c.resume() : c.pause(),
          ),
          TextButton(
            onPressed: () => _finish(context, ref),
            child: const Text('Finalizar'),
          ),
        ],
      ),
      body: Column(
        children: [
          const _SessionHeader(),
          const Expanded(child: _ExerciseList()),
          const _RestBar(),
        ],
      ),
    );
  }

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    final c = ref.read(workoutSessionControllerProvider.notifier);
    WorkoutMood? mood;
    int? energy;
    final noteCtrl = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
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
              Text('Humor', style: AppTypography.caption),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in WorkoutMood.values)
                    VisChip(
                      label: m.label,
                      selected: mood == m,
                      onTap: () => setModal(() => mood = m),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Text('Energia', style: AppTypography.caption),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (var i = 1; i <= 5; i++)
                    VisChip(
                      label: '$i',
                      selected: energy == i,
                      onTap: () => setModal(() => energy = i),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              VisTextField(label: 'Observações (opcional)', controller: noteCtrl),
              const SizedBox(height: AppSpacing.l),
              PrimaryButton(
                label: 'Concluir treino',
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) {
      noteCtrl.dispose();
      return;
    }
    final note = noteCtrl.text.trim();
    noteCtrl.dispose();
    final summary = await c.finish(
      mood: mood,
      energy: energy,
      notes: note.isEmpty ? null : note,
    );
    if (summary != null && context.mounted) {
      context.pushReplacementNamed('workout-summary', extra: summary);
    }
  }
}

class _SessionHeader extends ConsumerWidget {
  const _SessionHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsed = ref.watch(workoutSessionControllerProvider
        .select((s) => s.session?.elapsedSeconds ?? 0));
    final volume = ref.watch(workoutSessionControllerProvider
        .select((s) => s.session?.totalVolume ?? 0));
    final sets = ref.watch(workoutSessionControllerProvider
        .select((s) => s.session?.completedSets ?? 0));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metric(LucideIcons.clock, formatDuration(elapsed), 'Tempo'),
          _metric(LucideIcons.dumbbell, '${volume.toStringAsFixed(0)} kg', 'Volume'),
          _metric(LucideIcons.checkCheck, '$sets', 'Séries'),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label) => Column(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.subtitle),
          Text(label, style: AppTypography.small),
        ],
      );
}

class _ExerciseList extends ConsumerWidget {
  const _ExerciseList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(
        workoutSessionControllerProvider.select((s) => s.session?.exercises)) ??
        const [];
    final c = ref.read(workoutSessionControllerProvider.notifier);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: exercises.length,
      itemBuilder: (_, exIndex) {
        final ex = exercises[exIndex];
        return CardContainer(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(ex.exercise.name,
                        style: AppTypography.subtitle),
                  ),
                  Text('${ex.completedSets}/${ex.totalSets}',
                      style: AppTypography.small),
                ],
              ),
              Text(ex.exercise.muscleGroup, style: AppTypography.small),
              const SizedBox(height: 8),
              for (var i = 0; i < ex.sets.length; i++)
                SessionSetRow(
                  key: ValueKey(ex.sets[i].id),
                  set: ex.sets[i],
                  onChanged: ({double? weight, int? reps}) =>
                      c.updateSet(exIndex, i, weight: weight, reps: reps),
                  onToggleDone: () => ex.sets[i].completed
                      ? c.uncompleteSet(exIndex, i)
                      : c.completeSet(exIndex, i),
                ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () => c.addSet(exIndex),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Adicionar série'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RestBar extends ConsumerWidget {
  const _RestBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(
        workoutSessionControllerProvider.select((s) => s.restRemaining));
    if (remaining <= 0) return const SizedBox.shrink();
    final total =
        ref.watch(workoutSessionControllerProvider.select((s) => s.restTotal));
    final c = ref.read(workoutSessionControllerProvider.notifier);
    return RestTimerBar(
      remaining: remaining,
      total: total,
      onAdjust: c.addRest,
      onSkip: c.skipRest,
    );
  }
}
