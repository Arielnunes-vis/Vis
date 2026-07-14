import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/providers/authentication_providers.dart';
import '../models/weight_record.dart';
import '../providers/body_progress_providers.dart';

/// Controller do histórico de peso (PROMPT 08).
class WeightController extends Notifier<List<WeightRecord>> {
  final Uuid _uuid = const Uuid();

  @override
  List<WeightRecord> build() =>
      ref.read(bodyProgressRepositoryProvider).weightHistory();

  Future<void> add({
    required double weight,
    double? bodyFat,
    double? muscleMass,
    String? note,
  }) async {
    final uid =
        ref.read(authenticationRepositoryProvider).currentUser?.id ?? '';
    await ref.read(bodyProgressRepositoryProvider).addWeight(
          WeightRecord(
            id: _uuid.v4(),
            userId: uid,
            weight: weight,
            bodyFat: bodyFat,
            muscleMass: muscleMass,
            note: note,
            recordedAt: DateTime.now(),
          ),
        );
    state = ref.read(bodyProgressRepositoryProvider).weightHistory();
  }
}
