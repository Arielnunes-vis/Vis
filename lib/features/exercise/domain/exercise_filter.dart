import '../models/exercise.dart';
import 'exercise_enums.dart';

/// Ordenação da lista de exercícios.
enum ExerciseSort { name, recent, mostUsed }

/// Filtro do catálogo (PROMPT 05).
class ExerciseFilter {
  const ExerciseFilter({
    this.muscle,
    this.equipment,
    this.category,
    this.type,
    this.difficulty,
    this.homeOnly = false,
    this.favoritesOnly = false,
    this.sort = ExerciseSort.name,
  });

  final String? muscle;
  final String? equipment;
  final ExerciseCategory? category;
  final ExerciseType? type;
  final ExerciseDifficulty? difficulty;
  final bool homeOnly;
  final bool favoritesOnly;
  final ExerciseSort sort;

  bool get isEmpty =>
      muscle == null &&
      equipment == null &&
      category == null &&
      type == null &&
      difficulty == null &&
      !homeOnly &&
      !favoritesOnly;

  /// Aplica os critérios que dependem apenas do próprio exercício.
  /// (favoritesOnly/sort são resolvidos no repositório.)
  bool matches(Exercise e) {
    if (muscle != null && e.primaryMuscle != muscle) return false;
    if (equipment != null && e.equipment != equipment) return false;
    if (category != null && e.category != category) return false;
    if (type != null && e.type != type) return false;
    if (difficulty != null && e.difficulty != difficulty) return false;
    if (homeOnly && !e.homeCompatible) return false;
    return true;
  }

  ExerciseFilter copyWith({
    Object? muscle = _sentinel,
    Object? equipment = _sentinel,
    Object? category = _sentinel,
    Object? type = _sentinel,
    Object? difficulty = _sentinel,
    bool? homeOnly,
    bool? favoritesOnly,
    ExerciseSort? sort,
  }) {
    return ExerciseFilter(
      muscle: muscle == _sentinel ? this.muscle : muscle as String?,
      equipment: equipment == _sentinel ? this.equipment : equipment as String?,
      category:
          category == _sentinel ? this.category : category as ExerciseCategory?,
      type: type == _sentinel ? this.type : type as ExerciseType?,
      difficulty: difficulty == _sentinel
          ? this.difficulty
          : difficulty as ExerciseDifficulty?,
      homeOnly: homeOnly ?? this.homeOnly,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sort: sort ?? this.sort,
    );
  }

  static const Object _sentinel = Object();
}
