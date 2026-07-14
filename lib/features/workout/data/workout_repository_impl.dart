import 'package:uuid/uuid.dart';

import '../../../core/exceptions/app_exception.dart';
import '../domain/workout_local_store.dart';
import '../models/workout_day.dart';
import '../models/workout_exercise.dart';
import '../models/workout_plan.dart';
import '../repositories/workout_repository.dart';

/// Implementação offline-first do [WorkoutRepository].
///
/// Fonte de verdade local (Hive via [WorkoutLocalStore]); a estrutura
/// já serializa em mapas compatíveis com as tabelas workout_* para a
/// sincronização futura com o Supabase.
final class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl({
    required WorkoutLocalStore store,
    required String? Function() currentUserId,
    String Function()? idGenerator,
  })  : _store = store,
        _currentUserId = currentUserId,
        _newId = idGenerator ?? (() => const Uuid().v4());

  final WorkoutLocalStore _store;
  final String? Function() _currentUserId;
  final String Function() _newId;

  String get _uid => _currentUserId() ?? 'local';

  List<WorkoutPlan> _readAll() =>
      _store.readPlans(_uid).map(WorkoutPlan.fromMap).toList();

  Future<void> _writeAll(List<WorkoutPlan> plans) =>
      _store.writePlans(_uid, plans.map((p) => p.toMap()).toList());

  @override
  Future<List<WorkoutPlan>> getPlans() async {
    final plans = _readAll();
    plans.sort((a, b) => (b.updatedAt ?? b.createdAt ?? DateTime(0))
        .compareTo(a.updatedAt ?? a.createdAt ?? DateTime(0)));
    return plans;
  }

  @override
  Future<WorkoutPlan?> getPlan(String id) async {
    for (final p in _readAll()) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<WorkoutPlan> savePlan(WorkoutPlan plan) async {
    final now = DateTime.now();
    final plans = _readAll();
    final index = plans.indexWhere((p) => p.id == plan.id);

    final toSave = WorkoutPlan(
      id: plan.id,
      userId: plan.userId.isEmpty ? _uid : plan.userId,
      name: plan.name,
      description: plan.description,
      goal: plan.goal,
      color: plan.color,
      emoji: plan.emoji,
      imageUrl: plan.imageUrl,
      isActive: plan.isActive,
      days: plan.days,
      createdAt: index >= 0 ? plans[index].createdAt : now,
      updatedAt: now,
    );

    if (index >= 0) {
      plans[index] = toSave;
    } else {
      plans.add(toSave);
    }
    await _writeAll(plans);
    return toSave;
  }

  @override
  Future<WorkoutPlan> duplicatePlan(String id) async {
    final original = await getPlan(id);
    if (original == null) {
      throw const DatabaseException('Treino não encontrado.');
    }
    final copy = _cloneWithNewIds(original, name: '${original.name} (cópia)');
    return savePlan(copy);
  }

  @override
  Future<void> deletePlan(String id) async {
    final plans = _readAll()..removeWhere((p) => p.id == id);
    await _writeAll(plans);
  }

  @override
  Future<void> setActive(String id) async {
    final plans =
        _readAll().map((p) => p.copyWith(isActive: p.id == id)).toList();
    await _writeAll(plans);
  }

  WorkoutPlan _cloneWithNewIds(WorkoutPlan p, {required String name}) {
    final now = DateTime.now();
    return WorkoutPlan(
      id: _newId(),
      userId: p.userId,
      name: name,
      description: p.description,
      goal: p.goal,
      color: p.color,
      emoji: p.emoji,
      imageUrl: p.imageUrl,
      isActive: false,
      createdAt: now,
      updatedAt: now,
      days: p.days
          .map((d) => WorkoutDay(
                id: _newId(),
                name: d.name,
                orderIndex: d.orderIndex,
                weekdays: d.weekdays,
                estimatedDuration: d.estimatedDuration,
                focus: d.focus,
                exercises: d.exercises
                    .map((e) => WorkoutExercise(
                          id: _newId(),
                          exercise: e.exercise,
                          orderIndex: e.orderIndex,
                          sets: e.sets,
                          personalNotes: e.personalNotes,
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }
}
