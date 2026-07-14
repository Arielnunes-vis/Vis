import '../domain/workout_enums.dart';
import 'workout_day.dart';

/// Plano de treino completo (PROMPT 04 / tabela `workout_plans`).
class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.userId,
    required this.name,
    this.description = '',
    this.goal = WorkoutGoalType.hypertrophy,
    this.color,
    this.emoji,
    this.imageUrl,
    this.isActive = false,
    this.days = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String description;
  final WorkoutGoalType goal;
  final String? color;
  final String? emoji;
  final String? imageUrl;
  final bool isActive;
  final List<WorkoutDay> days;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get totalDays => days.length;
  int get totalExercises => days.fold(0, (sum, d) => sum + d.totalExercises);
  int get totalSets => days.fold(0, (sum, d) => sum + d.totalSets);

  Set<String> get muscleGroups => {
        for (final d in days) ...d.muscleGroups,
      };

  WorkoutPlan copyWith({
    String? name,
    String? description,
    WorkoutGoalType? goal,
    String? color,
    String? emoji,
    String? imageUrl,
    bool? isActive,
    List<WorkoutDay>? days,
    DateTime? updatedAt,
  }) {
    return WorkoutPlan(
      id: id,
      userId: userId,
      name: name ?? this.name,
      description: description ?? this.description,
      goal: goal ?? this.goal,
      color: color ?? this.color,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      days: days ?? this.days,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'description': description,
        'goal': goal.name,
        'color': color,
        'emoji': emoji,
        'image_url': imageUrl,
        'is_active': isActive,
        'days': days.map((d) => d.toMap()).toList(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory WorkoutPlan.fromMap(Map<String, dynamic> m) => WorkoutPlan(
        id: m['id'] as String,
        userId: (m['user_id'] ?? '') as String,
        name: (m['name'] ?? 'Treino') as String,
        description: (m['description'] ?? '') as String,
        goal: WorkoutGoalType.fromName(m['goal'] as String?),
        color: m['color'] as String?,
        emoji: m['emoji'] as String?,
        imageUrl: m['image_url'] as String?,
        isActive: (m['is_active'] as bool?) ?? false,
        days: (m['days'] as List? ?? [])
            .map((e) => WorkoutDay.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        createdAt: m['created_at'] != null
            ? DateTime.tryParse(m['created_at'] as String)
            : null,
        updatedAt: m['updated_at'] != null
            ? DateTime.tryParse(m['updated_at'] as String)
            : null,
      );
}
