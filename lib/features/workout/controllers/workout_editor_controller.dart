import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/providers/authentication_providers.dart';
import '../domain/workout_enums.dart';
import '../models/exercise_ref.dart';
import '../models/workout_day.dart';
import '../models/workout_exercise.dart';
import '../models/workout_plan.dart';
import '../models/workout_set.dart';
import '../providers/workout_providers.dart';

/// Controller do editor de treino (criar/editar) — PROMPT 04.
///
/// Mantém um rascunho [WorkoutPlan] imutável e expõe operações de
/// edição de dias, exercícios e séries. Nada é persistido até [save].
class WorkoutEditorController extends Notifier<WorkoutPlan> {
  final Uuid _uuid = const Uuid();

  @override
  WorkoutPlan build() => _emptyPlan();

  String _newId() => _uuid.v4();

  WorkoutPlan _emptyPlan() {
    final uid = ref.read(authenticationRepositoryProvider).currentUser?.id ?? '';
    return WorkoutPlan(id: _newId(), userId: uid, name: '');
  }

  /// Carrega um plano existente para edição (ou começa um novo).
  void load(WorkoutPlan? plan) {
    state = plan ?? _emptyPlan();
  }

  // ---------- Plano ----------
  void setName(String v) => state = state.copyWith(name: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setGoal(WorkoutGoalType g) => state = state.copyWith(goal: g);
  void setEmoji(String? e) => state = state.copyWith(emoji: e);

  // ---------- Dias ----------
  void addDay([String? name]) {
    final index = state.days.length;
    final day = WorkoutDay(
      id: _newId(),
      name: name ?? 'Treino ${String.fromCharCode(65 + index)}',
      orderIndex: index,
    );
    state = state.copyWith(days: [...state.days, day]);
  }

  void removeDay(String dayId) {
    state = state.copyWith(
      days: state.days.where((d) => d.id != dayId).toList(),
    );
  }

  void renameDay(String dayId, String name) =>
      _mutateDay(dayId, (d) => d.copyWith(name: name));

  void setDayWeekdays(String dayId, List<Weekday> weekdays) =>
      _mutateDay(dayId, (d) => d.copyWith(weekdays: weekdays));

  // ---------- Exercícios ----------
  void addExercise(String dayId, ExerciseRef exercise) {
    _mutateDay(dayId, (d) {
      final order = d.exercises.length;
      final ex = WorkoutExercise(
        id: _newId(),
        exercise: exercise,
        orderIndex: order,
        sets: List.generate(
          3,
          (i) => WorkoutSet(setNumber: i + 1),
        ),
      );
      return d.copyWith(exercises: [...d.exercises, ex]);
    });
  }

  void removeExercise(String dayId, String exerciseId) {
    _mutateDay(dayId, (d) {
      final list = d.exercises.where((e) => e.id != exerciseId).toList();
      return d.copyWith(exercises: _reindex(list));
    });
  }

  void moveExercise(String dayId, int oldIndex, int newIndex) {
    _mutateDay(dayId, (d) {
      final list = [...d.exercises];
      if (newIndex > oldIndex) newIndex -= 1;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      return d.copyWith(exercises: _reindex(list));
    });
  }

  void moveExerciseUp(String dayId, int index) {
    if (index <= 0) return;
    _swapExercises(dayId, index, index - 1);
  }

  void moveExerciseDown(String dayId, int index) {
    _mutateDay(dayId, (d) {
      if (index >= d.exercises.length - 1) return d;
      final list = [...d.exercises];
      final tmp = list[index];
      list[index] = list[index + 1];
      list[index + 1] = tmp;
      return d.copyWith(exercises: _reindex(list));
    });
  }

  void _swapExercises(String dayId, int a, int b) {
    _mutateDay(dayId, (d) {
      final list = [...d.exercises];
      final tmp = list[a];
      list[a] = list[b];
      list[b] = tmp;
      return d.copyWith(exercises: _reindex(list));
    });
  }

  void setExerciseNotes(String dayId, String exerciseId, String notes) =>
      _mutateExercise(dayId, exerciseId, (e) => e.copyWith(personalNotes: notes));

  // ---------- Séries ----------
  void addSet(String dayId, String exerciseId) {
    _mutateExercise(dayId, exerciseId, (e) {
      final sets = [...e.sets, WorkoutSet(setNumber: e.sets.length + 1)];
      return e.copyWith(sets: sets);
    });
  }

  void removeSet(String dayId, String exerciseId, int setIndex) {
    _mutateExercise(dayId, exerciseId, (e) {
      final sets = [...e.sets]..removeAt(setIndex);
      return e.copyWith(sets: _renumber(sets));
    });
  }

  void updateSet(String dayId, String exerciseId, int setIndex, WorkoutSet set) {
    _mutateExercise(dayId, exerciseId, (e) {
      final sets = [...e.sets];
      sets[setIndex] = set;
      return e.copyWith(sets: sets);
    });
  }

  // ---------- Persistência ----------
  Future<WorkoutPlan> save() =>
      ref.read(workoutRepositoryProvider).savePlan(state);

  bool get isValid => state.name.trim().isNotEmpty && state.days.isNotEmpty;

  // ---------- Helpers ----------
  void _mutateDay(String dayId, WorkoutDay Function(WorkoutDay) fn) {
    state = state.copyWith(
      days: state.days.map((d) => d.id == dayId ? fn(d) : d).toList(),
    );
  }

  void _mutateExercise(
    String dayId,
    String exerciseId,
    WorkoutExercise Function(WorkoutExercise) fn,
  ) {
    _mutateDay(dayId, (d) {
      return d.copyWith(
        exercises:
            d.exercises.map((e) => e.id == exerciseId ? fn(e) : e).toList(),
      );
    });
  }

  List<WorkoutExercise> _reindex(List<WorkoutExercise> list) {
    for (var i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(orderIndex: i);
    }
    return list;
  }

  List<WorkoutSet> _renumber(List<WorkoutSet> sets) {
    for (var i = 0; i < sets.length; i++) {
      sets[i] = sets[i].copyWith(setNumber: i + 1);
    }
    return sets;
  }
}
