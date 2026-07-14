/// Referência leve a um exercício dentro de um treino (PROMPT 04).
///
/// O catálogo completo (biomecânica, variações, progressões) vive no
/// módulo Exercise Library (05). Aqui guardamos apenas o necessário
/// para montar e exibir o treino — o `id` liga ao catálogo.
class ExerciseRef {
  const ExerciseRef({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscles = const [],
    this.equipment,
    this.gifUrl,
    this.videoUrl,
    this.imageUrl,
    this.execution,
    this.commonErrors,
  });

  final String id;
  final String name;
  final String muscleGroup;
  final List<String> secondaryMuscles;
  final String? equipment;
  final String? gifUrl;
  final String? videoUrl;
  final String? imageUrl;
  final String? execution;
  final String? commonErrors;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'muscle_group': muscleGroup,
        'secondary_muscles': secondaryMuscles,
        'equipment': equipment,
        'gif_url': gifUrl,
        'video_url': videoUrl,
        'image_url': imageUrl,
        'execution': execution,
        'common_errors': commonErrors,
      };

  factory ExerciseRef.fromMap(Map<String, dynamic> m) => ExerciseRef(
        id: m['id'] as String,
        name: (m['name'] ?? '') as String,
        muscleGroup: (m['muscle_group'] ?? '') as String,
        secondaryMuscles:
            (m['secondary_muscles'] as List? ?? []).map((e) => e.toString()).toList(),
        equipment: m['equipment'] as String?,
        gifUrl: m['gif_url'] as String?,
        videoUrl: m['video_url'] as String?,
        imageUrl: m['image_url'] as String?,
        execution: m['execution'] as String?,
        commonErrors: m['common_errors'] as String?,
      );
}
