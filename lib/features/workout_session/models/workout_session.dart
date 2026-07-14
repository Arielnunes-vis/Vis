import '../domain/session_enums.dart';
import 'workout_exercise_session.dart';

/// Sessão de treino em andamento ou concluída (PROMPT 06 / tabela
/// `workout_sessions`).
class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.dayName,
    required this.startedAt,
    this.exercises = const [],
    this.finishedAt,
    this.mood,
    this.energy,
    this.notes,
    this.elapsedSeconds = 0,
    this.restSeconds = 0,
    this.status = SessionStatus.active,
  });

  final String id;
  final String userId;
  final String planId;
  final String planName;
  final String dayName;
  final DateTime startedAt;
  final List<WorkoutExerciseSession> exercises;
  final DateTime? finishedAt;
  final WorkoutMood? mood;
  final int? energy; // 1..5
  final String? notes;

  /// Cronômetros (segundos): tempo total ativo e tempo em descanso.
  final int elapsedSeconds;
  final int restSeconds;
  final SessionStatus status;

  double get totalVolume => exercises.fold(0, (s, e) => s + e.volume);
  int get totalSets => exercises.fold(0, (s, e) => s + e.totalSets);
  int get completedSets => exercises.fold(0, (s, e) => s + e.completedSets);
  int get totalExercises => exercises.length;

  Set<String> get muscleGroups =>
      {for (final e in exercises) e.exercise.muscleGroup}
        ..removeWhere((e) => e.isEmpty);

  bool get isPaused => status == SessionStatus.paused;
  bool get isFinished => status == SessionStatus.finished;

  WorkoutSession copyWith({
    List<WorkoutExerciseSession>? exercises,
    DateTime? finishedAt,
    WorkoutMood? mood,
    int? energy,
    String? notes,
    int? elapsedSeconds,
    int? restSeconds,
    SessionStatus? status,
  }) {
    return WorkoutSession(
      id: id,
      userId: userId,
      planId: planId,
      planName: planName,
      dayName: dayName,
      startedAt: startedAt,
      exercises: exercises ?? this.exercises,
      finishedAt: finishedAt ?? this.finishedAt,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      notes: notes ?? this.notes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'plan_id': planId,
        'plan_name': planName,
        'day_name': dayName,
        'started_at': startedAt.toIso8601String(),
        'finished_at': finishedAt?.toIso8601String(),
        'mood': mood?.name,
        'energy': energy,
        'notes': notes,
        'elapsed_seconds': elapsedSeconds,
        'rest_seconds': restSeconds,
        'status': status.name,
        'exercises': exercises.map((e) => e.toMap()).toList(),
      };

  factory WorkoutSession.fromMap(Map<String, dynamic> m) => WorkoutSession(
        id: m['id'] as String,
        userId: (m['user_id'] ?? '') as String,
        planId: (m['plan_id'] ?? '') as String,
        planName: (m['plan_name'] ?? '') as String,
        dayName: (m['day_name'] ?? '') as String,
        startedAt: DateTime.parse(m['started_at'] as String),
        finishedAt: m['finished_at'] != null
            ? DateTime.tryParse(m['finished_at'] as String)
            : null,
        mood: WorkoutMood.fromName(m['mood'] as String?),
        energy: (m['energy'] as num?)?.toInt(),
        notes: m['notes'] as String?,
        elapsedSeconds: (m['elapsed_seconds'] as num?)?.toInt() ?? 0,
        restSeconds: (m['rest_seconds'] as num?)?.toInt() ?? 0,
        status: SessionStatus.values
            .firstWhere((s) => s.name == m['status'], orElse: () => SessionStatus.active),
        exercises: (m['exercises'] as List? ?? [])
            .map((e) => WorkoutExerciseSession.fromMap(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
