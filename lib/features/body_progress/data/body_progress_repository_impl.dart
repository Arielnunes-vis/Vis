import '../domain/body_enums.dart';
import '../domain/body_progress_local_store.dart';
import '../models/body_goal.dart';
import '../models/body_photo.dart';
import '../models/measurement_record.dart';
import '../models/weight_record.dart';
import '../repositories/body_progress_repository.dart';

/// Implementação offline-first do [BodyProgressRepository].
final class BodyProgressRepositoryImpl implements BodyProgressRepository {
  BodyProgressRepositoryImpl({
    required BodyProgressLocalStore store,
    required String? Function() currentUserId,
  })  : _store = store,
        _currentUserId = currentUserId;

  final BodyProgressLocalStore _store;
  final String? Function() _currentUserId;

  String get _uid => _currentUserId() ?? 'local';

  static const _weight = 'weight';
  static const _measurements = 'measurements';
  static const _photos = 'photos';
  static const _goals = 'goals';

  // ----- Peso -----
  @override
  Future<void> addWeight(WeightRecord record) async {
    final list = _store.read(_uid, _weight)..add(record.toMap());
    await _store.write(_uid, _weight, list);
  }

  @override
  List<WeightRecord> weightHistory() {
    final list = _store.read(_uid, _weight).map(WeightRecord.fromMap).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return list;
  }

  @override
  WeightRecord? latestWeight() {
    final h = weightHistory();
    return h.isEmpty ? null : h.first;
  }

  // ----- Medidas -----
  @override
  Future<void> addMeasurement(MeasurementRecord record) async {
    final list = _store.read(_uid, _measurements)..add(record.toMap());
    await _store.write(_uid, _measurements, list);
  }

  @override
  List<MeasurementRecord> measurementHistory() {
    final list = _store
        .read(_uid, _measurements)
        .map(MeasurementRecord.fromMap)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return list;
  }

  @override
  MeasurementRecord? latestMeasurement() {
    final h = measurementHistory();
    return h.isEmpty ? null : h.first;
  }

  // ----- Fotos -----
  @override
  Future<void> addPhoto(BodyPhoto photo) async {
    final list = _store.read(_uid, _photos)..add(photo.toMap());
    await _store.write(_uid, _photos, list);
  }

  @override
  List<BodyPhoto> photos({PhotoType? type}) {
    final list = _store.read(_uid, _photos).map(BodyPhoto.fromMap).toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return type == null ? list : list.where((p) => p.type == type).toList();
  }

  // ----- Metas -----
  @override
  Future<void> addGoal(BodyGoal goal) async {
    final list = _store.read(_uid, _goals)..add(goal.toMap());
    await _store.write(_uid, _goals, list);
  }

  @override
  List<BodyGoal> goals() =>
      _store.read(_uid, _goals).map(BodyGoal.fromMap).toList();

  @override
  Future<void> removeGoal(String id) async {
    final list = _store.read(_uid, _goals)
      ..removeWhere((m) => m['id'] == id);
    await _store.write(_uid, _goals, list);
  }
}
