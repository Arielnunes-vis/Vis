import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/body_progress/data/body_progress_repository_impl.dart';
import 'package:vis/features/body_progress/domain/body_enums.dart';
import 'package:vis/features/body_progress/domain/body_progress_local_store.dart';
import 'package:vis/features/body_progress/models/body_goal.dart';
import 'package:vis/features/body_progress/models/measurement_record.dart';
import 'package:vis/features/body_progress/models/weight_record.dart';

class InMemStore implements BodyProgressLocalStore {
  final Map<String, List<Map<String, dynamic>>> _d = {};

  @override
  List<Map<String, dynamic>> read(String userId, String collection) =>
      _d['$userId/$collection'] ?? const [];

  @override
  Future<void> write(
    String userId,
    String collection,
    List<Map<String, dynamic>> items,
  ) async =>
      _d['$userId/$collection'] = items;
}

void main() {
  late BodyProgressRepositoryImpl repo;

  setUp(() {
    repo = BodyProgressRepositoryImpl(
      store: InMemStore(),
      currentUserId: () => 'u1',
    );
  });

  test('peso: acumula histórico e retorna o mais recente', () async {
    await repo.addWeight(WeightRecord(
        id: 'w1', userId: 'u1', weight: 80, recordedAt: DateTime(2026, 1, 1)));
    await repo.addWeight(WeightRecord(
        id: 'w2', userId: 'u1', weight: 79, recordedAt: DateTime(2026, 1, 8)));

    expect(repo.weightHistory().length, 2);
    expect(repo.latestWeight()!.weight, 79);
  });

  test('medidas: comparação campo a campo', () async {
    await repo.addMeasurement(MeasurementRecord(
        id: 'm1',
        userId: 'u1',
        recordedAt: DateTime(2026, 1, 1),
        values: const {'chest': 100}));
    await repo.addMeasurement(MeasurementRecord(
        id: 'm2',
        userId: 'u1',
        recordedAt: DateTime(2026, 1, 8),
        values: const {'chest': 102}));

    final latest = repo.latestMeasurement()!;
    final previous = repo.measurementHistory()[1];
    final chest = latest
        .compareTo(previous)
        .firstWhere((d) => d.field == MeasurementField.chest);

    expect(chest.delta, 2);
    expect(chest.direction, 1);
  });

  test('meta: progresso e conclusão (perda de peso)', () {
    final goal = BodyGoal(
      id: 'g1',
      userId: 'u1',
      type: GoalType.weight,
      target: 75,
      startValue: 80,
      createdAt: DateTime(2026, 1, 1),
    );
    expect(goal.progress(77.5), closeTo(0.5, 0.001));
    expect(goal.reached(74), isTrue);
    expect(goal.reached(78), isFalse);
  });
}
