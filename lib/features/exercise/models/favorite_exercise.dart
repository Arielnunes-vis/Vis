/// Marcação de exercício favorito do usuário (PROMPT 05).
///
/// Persistido localmente (offline) e consumido pela IA para preferir
/// exercícios que o usuário gosta.
class FavoriteExercise {
  const FavoriteExercise({required this.exerciseId, this.createdAt});

  final String exerciseId;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'exercise_id': exerciseId,
        'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory FavoriteExercise.fromMap(Map<String, dynamic> m) => FavoriteExercise(
        exerciseId: m['exercise_id'] as String,
        createdAt: m['created_at'] != null
            ? DateTime.tryParse(m['created_at'] as String)
            : null,
      );
}
