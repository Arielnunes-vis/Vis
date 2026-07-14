import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/providers/authentication_providers.dart';
import '../domain/body_enums.dart';
import '../models/measurement_record.dart';
import '../providers/body_progress_providers.dart';

/// Controller do histórico de medidas (PROMPT 08).
class MeasurementsController extends Notifier<List<MeasurementRecord>> {
  final Uuid _uuid = const Uuid();

  @override
  List<MeasurementRecord> build() =>
      ref.read(bodyProgressRepositoryProvider).measurementHistory();

  Future<void> add({
    required Map<MeasurementField, double> values,
    double? weight,
    double? bodyFat,
    String? note,
  }) async {
    final uid =
        ref.read(authenticationRepositoryProvider).currentUser?.id ?? '';
    await ref.read(bodyProgressRepositoryProvider).addMeasurement(
          MeasurementRecord(
            id: _uuid.v4(),
            userId: uid,
            recordedAt: DateTime.now(),
            values: {for (final e in values.entries) e.key.name: e.value},
            weight: weight,
            bodyFat: bodyFat,
            note: note,
          ),
        );
    state = ref.read(bodyProgressRepositoryProvider).measurementHistory();
  }

  /// A medição imediatamente anterior à mais recente (para comparação).
  MeasurementRecord? get previous => state.length > 1 ? state[1] : null;
}
