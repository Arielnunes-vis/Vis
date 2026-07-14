import '../domain/exercise_enums.dart';

/// Exercício do catálogo (PROMPT 05 / 08_EXERCISE_LIBRARY.md).
///
/// Contém todos os campos obrigatórios. A estrutura suporta um catálogo
/// ilimitado (5.000+); a paginação/busca é responsabilidade da fonte
/// de dados, não do modelo.
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.slug,
    required this.primaryMuscle,
    this.description = '',
    this.secondaryMuscles = const [],
    this.equipment = Equipments.barbell,
    this.category = ExerciseCategory.push,
    this.type = ExerciseType.compound,
    this.difficulty = ExerciseDifficulty.beginner,
    this.plane = MovementPlane.horizontal,
    this.pattern = MovementPattern.push,
    this.execution = '',
    this.breathing = '',
    this.cadence = '',
    this.amplitude = '',
    this.commonErrors = const [],
    this.tips = const [],
    this.synonyms = const [],
    this.gifUrl,
    this.videoUrl,
    this.imageUrl,
    this.alternatives = const [],
    this.progressions = const [],
    this.regressions = const [],
    this.homeCompatible = false,
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String equipment;
  final ExerciseCategory category;
  final ExerciseType type;
  final ExerciseDifficulty difficulty;
  final MovementPlane plane;
  final MovementPattern pattern;
  final String execution;
  final String breathing;
  final String cadence;
  final String amplitude;
  final List<String> commonErrors;
  final List<String> tips;
  final List<String> synonyms;
  final String? gifUrl;
  final String? videoUrl;
  final String? imageUrl;

  /// IDs de exercícios relacionados.
  final List<String> alternatives;
  final List<String> progressions;
  final List<String> regressions;

  final bool homeCompatible;

  bool get isCompound => type == ExerciseType.compound;

  /// Texto usado na busca (nome + músculo + equipamento + sinônimos).
  String get searchIndex => [
        name,
        primaryMuscle,
        equipment,
        category.label,
        ...synonyms,
      ].join(' ').toLowerCase();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'primary_muscle': primaryMuscle,
        'secondary_muscles': secondaryMuscles,
        'equipment': equipment,
        'category': category.name,
        'type': type.name,
        'difficulty': difficulty.name,
        'plane': plane.name,
        'pattern': pattern.name,
        'execution': execution,
        'breathing': breathing,
        'cadence': cadence,
        'amplitude': amplitude,
        'common_errors': commonErrors,
        'tips': tips,
        'synonyms': synonyms,
        'gif_url': gifUrl,
        'video_url': videoUrl,
        'photo_url': imageUrl,
        'alternatives': alternatives,
        'progressions': progressions,
        'regressions': regressions,
        'home_compatible': homeCompatible,
      };

  factory Exercise.fromMap(Map<String, dynamic> m) => Exercise(
        id: m['id'] as String,
        name: (m['name'] ?? '') as String,
        slug: (m['slug'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        primaryMuscle: (m['primary_muscle'] ?? '') as String,
        secondaryMuscles: _list(m['secondary_muscles']),
        equipment: (m['equipment'] ?? Equipments.barbell) as String,
        category: ExerciseCategory.fromName(m['category'] as String?),
        type: ExerciseType.fromName(m['type'] as String?),
        difficulty: ExerciseDifficulty.fromName(m['difficulty'] as String?),
        plane: MovementPlane.fromName(m['plane'] as String?),
        pattern: MovementPattern.fromName(m['pattern'] as String?),
        execution: (m['execution'] ?? '') as String,
        breathing: (m['breathing'] ?? '') as String,
        cadence: (m['cadence'] ?? '') as String,
        amplitude: (m['amplitude'] ?? '') as String,
        commonErrors: _list(m['common_errors']),
        tips: _list(m['tips']),
        synonyms: _list(m['synonyms']),
        gifUrl: m['gif_url'] as String?,
        videoUrl: m['video_url'] as String?,
        imageUrl: m['photo_url'] as String?,
        alternatives: _list(m['alternatives']),
        progressions: _list(m['progressions']),
        regressions: _list(m['regressions']),
        homeCompatible: (m['home_compatible'] as bool?) ?? false,
      );

  static List<String> _list(dynamic v) =>
      (v as List? ?? const []).map((e) => e.toString()).toList();
}
