import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/exercise_enums.dart';
import '../domain/exercise_filter.dart';
import '../models/exercise.dart';
import '../providers/exercise_providers.dart';

/// Estado da tela de biblioteca (busca + filtro + resultados).
class ExerciseLibraryState {
  const ExerciseLibraryState({
    this.query = '',
    this.filter = const ExerciseFilter(),
    this.results = const AsyncLoading(),
  });

  final String query;
  final ExerciseFilter filter;
  final AsyncValue<List<Exercise>> results;

  ExerciseLibraryState copyWith({
    String? query,
    ExerciseFilter? filter,
    AsyncValue<List<Exercise>>? results,
  }) {
    return ExerciseLibraryState(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      results: results ?? this.results,
    );
  }
}

/// Controller da biblioteca de exercícios (PROMPT 05).
class ExerciseLibraryController extends Notifier<ExerciseLibraryState> {
  @override
  ExerciseLibraryState build() {
    // Carrega assim que o provider é criado.
    Future.microtask(reload);
    return const ExerciseLibraryState();
  }

  Future<void> reload() async {
    state = state.copyWith(results: const AsyncLoading());
    final res = await AsyncValue.guard(
      () => ref.read(exerciseRepositoryProvider).list(
            filter: state.filter,
            query: state.query,
            pageSize: 500,
          ),
    );
    state = state.copyWith(results: res);
  }

  void setQuery(String q) {
    state = state.copyWith(query: q);
    reload();
  }

  void setMuscle(String? muscle) => _setFilter(state.filter.copyWith(muscle: muscle));
  void setEquipment(String? eq) => _setFilter(state.filter.copyWith(equipment: eq));
  void setType(ExerciseType? t) => _setFilter(state.filter.copyWith(type: t));
  void setDifficulty(ExerciseDifficulty? d) =>
      _setFilter(state.filter.copyWith(difficulty: d));
  void setHomeOnly(bool v) => _setFilter(state.filter.copyWith(homeOnly: v));
  void setFavoritesOnly(bool v) =>
      _setFilter(state.filter.copyWith(favoritesOnly: v));
  void setSort(ExerciseSort s) => _setFilter(state.filter.copyWith(sort: s));

  void clearFilters() {
    state = state.copyWith(filter: const ExerciseFilter());
    reload();
  }

  void _setFilter(ExerciseFilter filter) {
    state = state.copyWith(filter: filter);
    reload();
  }
}
