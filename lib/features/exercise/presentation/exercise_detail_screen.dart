import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/exercise.dart';
import '../models/exercise_history.dart';
import '../providers/exercise_providers.dart';

/// Tela de detalhe do exercício (PROMPT 05).
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({required this.exercise, super.key});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(exerciseFavoritesControllerProvider);
    final isFav = favorites.contains(exercise.id);
    final repo = ref.read(exerciseRepositoryProvider);
    final history = repo.historyFor(exercise.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.heart,
                color: isFav ? AppColors.danger : null),
            onPressed: () => ref
                .read(exerciseFavoritesControllerProvider.notifier)
                .toggle(exercise.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: (exercise.gifUrl ?? exercise.imageUrl) != null
                  ? CachedNetworkImage(
                      imageUrl: (exercise.gifUrl ?? exercise.imageUrl)!,
                      fit: BoxFit.cover)
                  : Container(
                      color: AppColors.card,
                      child: const Icon(LucideIcons.dumbbell,
                          size: 40, color: AppColors.disabled),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              VisBadge(label: exercise.primaryMuscle),
              VisBadge(label: exercise.equipment, color: AppColors.secondary),
              VisBadge(label: exercise.difficulty.label, color: AppColors.warning),
              VisBadge(label: exercise.type.label, color: AppColors.success),
            ],
          ),
          if (exercise.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            Text(exercise.description, style: AppTypography.body),
          ],
          _section('Execução', exercise.execution),
          _section('Respiração', exercise.breathing),
          _section('Cadência', exercise.cadence),
          _section('Amplitude', exercise.amplitude),
          _bullets('Erros comuns', exercise.commonErrors),
          _bullets('Dicas', exercise.tips),
          _history(history),
          _Related(exercise: exercise),
          const SizedBox(height: AppSpacing.l),
          PrimaryButton(
            label: 'Adicionar ao treino',
            icon: LucideIcons.plus,
            onPressed: () => AppSnackBar.show(
              context,
              'Adicione este exercício pelo editor de treino.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.subtitle),
          const SizedBox(height: 4),
          Text(text, style: AppTypography.body),
        ],
      ),
    );
  }

  Widget _bullets(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.subtitle),
          const SizedBox(height: 4),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('•  $it', style: AppTypography.body),
            ),
        ],
      ),
    );
  }

  Widget _history(ExerciseHistorySummary? history) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l),
      child: CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seu histórico', style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.s),
            if (history == null || history.isEmpty)
              Text('Sem registros ainda. Execute este exercício em um treino.',
                  style: AppTypography.caption)
            else
              Text(
                'Maior carga: ${history.maxWeight ?? '-'} kg · '
                'Maior volume: ${history.maxVolume ?? '-'} · '
                'Execuções: ${history.timesPerformed}',
                style: AppTypography.body,
              ),
          ],
        ),
      ),
    );
  }
}

class _Related extends ConsumerStatefulWidget {
  const _Related({required this.exercise});
  final Exercise exercise;

  @override
  ConsumerState<_Related> createState() => _RelatedState();
}

class _RelatedState extends ConsumerState<_Related> {
  // O future é criado uma única vez (não em build) para não re-disparar
  // getByIds a cada rebuild do pai (ex.: ao favoritar).
  Future<List<Exercise>>? _future;

  @override
  void initState() {
    super.initState();
    final ex = widget.exercise;
    final ids = {
      ...ex.alternatives,
      ...ex.progressions,
      ...ex.regressions,
    }.where((id) => id != ex.id).toList();
    if (ids.isNotEmpty) {
      _future = ref.read(exerciseRepositoryProvider).getByIds(ids);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_future == null) return const SizedBox.shrink();

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        final related = snapshot.data ?? const [];
        if (related.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Relacionados', style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.s),
              for (final ex in related)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s),
                  child: ExerciseCard(
                    name: ex.name,
                    muscle: ex.primaryMuscle,
                    equipment: ex.equipment,
                    onTap: () =>
                        context.pushNamed('exercise-detail', extra: ex),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
