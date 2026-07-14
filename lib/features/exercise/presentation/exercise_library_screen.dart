import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/exercise_enums.dart';
import '../providers/exercise_providers.dart';

/// Biblioteca de exercícios — busca, filtros e favoritos (PROMPT 05).
class ExerciseLibraryScreen extends ConsumerWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exerciseLibraryControllerProvider);
    final c = ref.read(exerciseLibraryControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: SearchField(
              hint: 'Buscar exercício...',
              onChanged: c.setQuery,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              children: [
                VisChip(
                  label: 'Favoritos',
                  selected: state.filter.favoritesOnly,
                  onTap: () => c.setFavoritesOnly(!state.filter.favoritesOnly),
                ),
                const SizedBox(width: 8),
                VisChip(
                  label: 'Casa',
                  selected: state.filter.homeOnly,
                  onTap: () => c.setHomeOnly(!state.filter.homeOnly),
                ),
                const SizedBox(width: 8),
                for (final m in Muscles.all) ...[
                  VisChip(
                    label: m,
                    selected: state.filter.muscle == m,
                    onTap: () =>
                        c.setMuscle(state.filter.muscle == m ? null : m),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Expanded(
            child: state.results.when(
              loading: () => const LoadingWidget(),
              error: (_, __) => ErrorState(onRetry: c.reload),
              data: (exercises) {
                if (exercises.isEmpty) {
                  return const EmptyState(
                    title: 'Nenhum exercício encontrado',
                    description: 'Ajuste a busca ou os filtros.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  itemCount: exercises.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.s),
                  itemBuilder: (_, i) {
                    final ex = exercises[i];
                    return ExerciseCard(
                      name: ex.name,
                      muscle: ex.primaryMuscle,
                      equipment: ex.equipment,
                      imageUrl: ex.imageUrl,
                      onTap: () =>
                          context.pushNamed('exercise-detail', extra: ex),
                      // Consumer isolado: favoritar rebuilda só este ícone,
                      // não a lista inteira (Regra 009 — rebuild mínimo).
                      trailing: Consumer(
                        builder: (context, ref, _) {
                          final isFav = ref.watch(
                              exerciseFavoritesControllerProvider
                                  .select((s) => s.contains(ex.id)));
                          return IconButton(
                            icon: Icon(
                              LucideIcons.heart,
                              color:
                                  isFav ? AppColors.danger : AppColors.disabled,
                              size: 20,
                            ),
                            onPressed: () => ref
                                .read(exerciseFavoritesControllerProvider
                                    .notifier)
                                .toggle(ex.id),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
