import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/providers/authentication_providers.dart';
import '../domain/cardio_enums.dart';
import '../models/cardio_session.dart';
import '../providers/cardio_providers.dart';

/// Controller do histórico de cardio (PROMPT 09).
class CardioController extends Notifier<List<CardioSession>> {
  final Uuid _uuid = const Uuid();

  @override
  List<CardioSession> build() =>
      ref.read(cardioRepositoryProvider).history();

  Future<void> add({
    required CardioType type,
    required int durationSeconds,
    double? distanceKm,
    double? incline,
    double? calories,
    int? avgHeartRate,
    double? rpe,
    String? note,
  }) async {
    final uid =
        ref.read(authenticationRepositoryProvider).currentUser?.id ?? '';
    await ref.read(cardioRepositoryProvider).addSession(
          CardioSession(
            id: _uuid.v4(),
            userId: uid,
            type: type,
            performedAt: DateTime.now(),
            durationSeconds: durationSeconds,
            distanceKm: distanceKm,
            incline: incline,
            calories: calories,
            avgHeartRate: avgHeartRate,
            rpe: rpe,
            note: note,
          ),
        );
    state = ref.read(cardioRepositoryProvider).history();
  }
}
