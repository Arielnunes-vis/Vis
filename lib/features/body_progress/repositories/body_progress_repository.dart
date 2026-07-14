import '../domain/body_enums.dart';
import '../models/body_goal.dart';
import '../models/body_photo.dart';
import '../models/measurement_record.dart';
import '../models/weight_record.dart';

/// Contrato do repositório de evolução corporal (PROMPT 08).
///
/// Regra 001/003: nada é sobrescrito — cada registro é novo e datado.
/// Offline-first.
abstract interface class BodyProgressRepository {
  // ----- Peso -----
  Future<void> addWeight(WeightRecord record);
  List<WeightRecord> weightHistory();
  WeightRecord? latestWeight();

  // ----- Medidas -----
  Future<void> addMeasurement(MeasurementRecord record);
  List<MeasurementRecord> measurementHistory();
  MeasurementRecord? latestMeasurement();

  // ----- Fotos -----
  Future<void> addPhoto(BodyPhoto photo);
  List<BodyPhoto> photos({PhotoType? type});

  // ----- Metas -----
  Future<void> addGoal(BodyGoal goal);
  List<BodyGoal> goals();
  Future<void> removeGoal(String id);
}
