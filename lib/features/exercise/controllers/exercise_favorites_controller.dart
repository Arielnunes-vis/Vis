import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/exercise_providers.dart';

/// Mantém o conjunto de exercícios favoritos reativo entre telas
/// (PROMPT 05). Persistência offline via repositório.
class ExerciseFavoritesController extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.read(exerciseRepositoryProvider).favorites();

  Future<void> toggle(String id) async {
    await ref.read(exerciseRepositoryProvider).toggleFavorite(id);
    state = ref.read(exerciseRepositoryProvider).favorites();
  }

  bool isFavorite(String id) => state.contains(id);
}
