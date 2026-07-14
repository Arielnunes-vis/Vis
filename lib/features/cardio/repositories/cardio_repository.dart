import '../domain/cardio_enums.dart';
import '../models/cardio_goal.dart';
import '../models/cardio_session.dart';
import '../models/cardio_stats.dart';

/// Contrato do repositório de cardio (PROMPT 09). Offline-first.
abstract interface class CardioRepository {
  Future<void> addSession(CardioSession session);
  List<CardioSession> history({CardioType? type});
  CardioSession? latest();

  /// Resumo desde uma data (ex.: início da semana/mês).
  CardioStats statsSince(DateTime from);
  CardioRecords records();

  Future<void> addGoal(CardioGoal goal);
  List<CardioGoal> goals();
  Future<void> removeGoal(String id);
}
