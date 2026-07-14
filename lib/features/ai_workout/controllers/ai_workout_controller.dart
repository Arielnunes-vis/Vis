import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../core/logger/app_logger.dart';
import '../domain/ai_workout_enums.dart';
import '../models/generated_workout.dart';
import '../models/generation_result.dart';
import '../models/workout_request.dart';
import '../providers/ai_workout_providers.dart';

/// Fases do fluxo de geração (PROMPT 12).
enum GenerationPhase { form, generating, result, error }

class AIWorkoutState {
  const AIWorkoutState({
    this.phase = GenerationPhase.form,
    this.request = const WorkoutRequest(
      goal: WorkoutGoal.hypertrophy,
      daysPerWeek: 3,
      minutesPerWorkout: 60,
      location: WorkoutLocation.gym,
      experience: WorkoutExperience.intermediate,
    ),
    this.result,
    this.workout,
    this.isSaving = false,
    this.error,
  });

  final GenerationPhase phase;
  final WorkoutRequest request;
  final WorkoutGenerationResult? result;

  /// Cópia editável do treino gerado.
  final GeneratedWorkout? workout;
  final bool isSaving;
  final String? error;

  AIWorkoutState copyWith({
    GenerationPhase? phase,
    WorkoutRequest? request,
    WorkoutGenerationResult? result,
    GeneratedWorkout? workout,
    bool? isSaving,
    String? error,
  }) {
    return AIWorkoutState(
      phase: phase ?? this.phase,
      request: request ?? this.request,
      result: result ?? this.result,
      workout: workout ?? this.workout,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

class AIWorkoutController extends Notifier<AIWorkoutState> {
  @override
  AIWorkoutState build() => const AIWorkoutState();

  AIWorkoutRepository get _repo => ref.read(aiWorkoutRepositoryProvider);

  // ----- Ajuste do pedido -----
  void setGoal(WorkoutGoal g) =>
      state = state.copyWith(request: state.request.copyWith(goal: g));
  void setDays(int d) =>
      state = state.copyWith(request: state.request.copyWith(daysPerWeek: d));
  void setMinutes(int m) => state =
      state.copyWith(request: state.request.copyWith(minutesPerWorkout: m));
  void setLocation(WorkoutLocation l) =>
      state = state.copyWith(request: state.request.copyWith(location: l));
  void setExperience(WorkoutExperience e) =>
      state = state.copyWith(request: state.request.copyWith(experience: e));

  void toggleEquipment(String item) {
    final list = [...state.request.equipment];
    list.contains(item) ? list.remove(item) : list.add(item);
    state = state.copyWith(request: state.request.copyWith(equipment: list));
  }

  /// Lesões / limitações (texto livre) — PROMPT 12 (RESTRIÇÕES).
  void setRestrictionNotes(String notes) => state = state.copyWith(
        request: state.request.copyWith(
          restrictions: WorkoutRestrictions(notes: notes),
        ),
      );

  /// Exercícios que o usuário evita (separados por vírgula).
  void setAvoidExercises(String csv) {
    final list = csv
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    state = state.copyWith(
      request: state.request.copyWith(
        preferences: WorkoutPreferences(dislikedExercises: list),
      ),
    );
  }

  // ----- Geração -----
  Future<void> generate() async {
    state = state.copyWith(phase: GenerationPhase.generating, error: null);
    try {
      final result = await _repo.generate(state.request);
      state = state.copyWith(
        phase: GenerationPhase.result,
        result: result,
        workout: result.workout,
      );
    } on AppException catch (e) {
      state = state.copyWith(phase: GenerationPhase.error, error: e.message);
    } catch (e, st) {
      AppLogger.e('[AIWorkout] falha inesperada ao gerar treino',
          error: e, stackTrace: st);
      state = state.copyWith(
        phase: GenerationPhase.error,
        error: 'Não foi possível gerar o treino agora.',
      );
    }
  }

  void backToForm() => state = state.copyWith(phase: GenerationPhase.form);

  // ----- Edição do treino gerado -----
  void renameWorkout(String name) {
    final w = state.workout;
    if (w != null) state = state.copyWith(workout: w.copyWith(name: name));
  }

  void updateExercise(int dayIndex, int exIndex, GeneratedExercise updated) {
    _mutateDay(dayIndex, (day) {
      final exercises = [...day.exercises];
      exercises[exIndex] = updated;
      return day.copyWith(exercises: exercises);
    });
  }

  void removeExercise(int dayIndex, int exIndex) {
    _mutateDay(dayIndex, (day) {
      final exercises = [...day.exercises]..removeAt(exIndex);
      return day.copyWith(exercises: exercises);
    });
  }

  void addExercise(int dayIndex, GeneratedExercise exercise) {
    _mutateDay(dayIndex, (day) {
      return day.copyWith(exercises: [...day.exercises, exercise]);
    });
  }

  /// Pede à IA para trocar um exercício por outro equivalente
  /// (PROMPT 12). Requer conexão; em falha, mantém o exercício atual.
  Future<void> regenerateExercise(int dayIndex, int exIndex) async {
    final w = state.workout;
    if (w == null) return;
    if (dayIndex < 0 || dayIndex >= w.days.length) return;
    final day = w.days[dayIndex];
    if (exIndex < 0 || exIndex >= day.exercises.length) return;
    final current = day.exercises[exIndex];
    try {
      final replacement = await _repo.regenerateExercise(
        request: state.request,
        dayName: day.name,
        exerciseName: current.name,
      );
      updateExercise(dayIndex, exIndex, replacement);
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e, st) {
      AppLogger.e('[AIWorkout] falha ao trocar exercício',
          error: e, stackTrace: st);
      state = state.copyWith(
          error: 'Não foi possível trocar o exercício agora.');
    }
  }

  void _mutateDay(
    int dayIndex,
    GeneratedWorkoutDay Function(GeneratedWorkoutDay) fn,
  ) {
    final w = state.workout;
    if (w == null) return;
    final days = [...w.days];
    days[dayIndex] = fn(days[dayIndex]);
    state = state.copyWith(workout: w.copyWith(days: days));
  }

  // ----- Persistência -----
  Future<bool> save() async {
    final w = state.workout;
    if (w == null) return false;
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repo.saveGeneration(request: state.request, workout: w);
      state = state.copyWith(isSaving: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSaving: false, error: e.message);
      return false;
    }
  }

  Future<void> submitFeedback(GenerationRating rating, String comment) async {
    final w = state.workout;
    if (w == null) return;
    await _repo.saveFeedback(GenerationFeedback(
      workoutName: w.name,
      rating: rating,
      comment: comment,
    ));
  }
}
