import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workout_plan.dart';
import '../providers/workout_providers.dart';

/// Controller da lista de treinos (PROMPT 04).
///
/// Carrega os planos e expõe duplicar/excluir/ativar. Usa [AsyncValue]
/// para cobrir os estados loading/error/data.
class WorkoutListController extends AsyncNotifier<List<WorkoutPlan>> {
  @override
  Future<List<WorkoutPlan>> build() =>
      ref.read(workoutRepositoryProvider).getPlans();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(workoutRepositoryProvider).getPlans(),
    );
  }

  Future<void> duplicate(String id) async {
    await ref.read(workoutRepositoryProvider).duplicatePlan(id);
    await refresh();
  }

  Future<void> delete(String id) async {
    await ref.read(workoutRepositoryProvider).deletePlan(id);
    await refresh();
  }

  Future<void> setActive(String id) async {
    await ref.read(workoutRepositoryProvider).setActive(id);
    await refresh();
  }
}
