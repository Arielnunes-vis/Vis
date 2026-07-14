import 'package:flutter_test/flutter_test.dart';
import 'package:vis/features/cardio/data/cardio_repository_impl.dart';
import 'package:vis/features/cardio/domain/cardio_enums.dart';
import 'package:vis/features/cardio/domain/cardio_local_store.dart';
import 'package:vis/features/cardio/models/cardio_session.dart';

class InMemStore implements CardioLocalStore {
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

CardioSession _run() => CardioSession(
      id: 'c1',
      userId: 'u1',
      type: CardioType.running,
      performedAt: DateTime(2026, 1, 15),
      durationSeconds: 1800,
      distanceKm: 5,
      calories: 300,
    );

void main() {
  late CardioRepositoryImpl repo;

  setUp(() {
    repo = CardioRepositoryImpl(
      store: InMemStore(),
      currentUserId: () => 'u1',
    );
  });

  test('session calcula velocidade e pace', () {
    final s = _run();
    expect(s.minutes, 30);
    expect(s.speedKmh, 10);
    expect(s.paceLabel, '6:00/km');
  });

  test('registra, resume a semana e calcula recordes', () async {
    await repo.addSession(_run());

    expect(repo.history().length, 1);
    expect(repo.latest(), isNotNull);

    final stats = repo.statsSince(DateTime(2026, 1, 12));
    expect(stats.sessions, 1);
    expect(stats.totalMinutes, 30);
    expect(stats.totalDistance, 5);
    expect(stats.totalCalories, 300);

    final records = repo.records();
    expect(records.maxDistanceKm, 5);
    expect(records.maxDurationSeconds, 1800);
    expect(records.maxSpeedKmh, 10);
  });
}
