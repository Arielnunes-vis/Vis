import '../domain/cardio_enums.dart';
import '../domain/cardio_local_store.dart';
import '../models/cardio_goal.dart';
import '../models/cardio_session.dart';
import '../models/cardio_stats.dart';
import '../repositories/cardio_repository.dart';

/// Implementação offline-first do [CardioRepository].
final class CardioRepositoryImpl implements CardioRepository {
  CardioRepositoryImpl({
    required CardioLocalStore store,
    required String? Function() currentUserId,
  })  : _store = store,
        _currentUserId = currentUserId;

  final CardioLocalStore _store;
  final String? Function() _currentUserId;

  String get _uid => _currentUserId() ?? 'local';
  static const _sessions = 'sessions';
  static const _goals = 'goals';

  @override
  Future<void> addSession(CardioSession session) async {
    final list = _store.read(_uid, _sessions)..add(session.toMap());
    await _store.write(_uid, _sessions, list);
  }

  List<CardioSession> _all() {
    final list = _store.read(_uid, _sessions).map(CardioSession.fromMap).toList()
      ..sort((a, b) => b.performedAt.compareTo(a.performedAt));
    return list;
  }

  @override
  List<CardioSession> history({CardioType? type}) {
    final all = _all();
    return type == null ? all : all.where((s) => s.type == type).toList();
  }

  @override
  CardioSession? latest() {
    final all = _all();
    return all.isEmpty ? null : all.first;
  }

  @override
  CardioStats statsSince(DateTime from) =>
      CardioStats.from(_all().where((s) => !s.performedAt.isBefore(from)));

  @override
  CardioRecords records() => CardioRecords.from(_all());

  @override
  Future<void> addGoal(CardioGoal goal) async {
    final list = _store.read(_uid, _goals)..add(goal.toMap());
    await _store.write(_uid, _goals, list);
  }

  @override
  List<CardioGoal> goals() =>
      _store.read(_uid, _goals).map(CardioGoal.fromMap).toList();

  @override
  Future<void> removeGoal(String id) async {
    final list = _store.read(_uid, _goals)..removeWhere((m) => m['id'] == id);
    await _store.write(_uid, _goals, list);
  }
}
