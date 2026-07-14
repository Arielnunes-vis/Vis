import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../domain/workout_local_store.dart';

/// Implementação Hive do [WorkoutLocalStore] (box `vis_workouts`).
final class HiveWorkoutLocalStore implements WorkoutLocalStore {
  const HiveWorkoutLocalStore(this._storage);

  final LocalStorageService _storage;

  String _key(String userId) => 'plans_$userId';

  @override
  List<Map<String, dynamic>> readPlans(String userId) {
    final raw =
        _storage.get<List<dynamic>>(AppConstants.boxWorkouts, _key(userId)) ??
            const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<void> writePlans(
    String userId,
    List<Map<String, dynamic>> plans,
  ) =>
      _storage.put(AppConstants.boxWorkouts, _key(userId), plans);
}
