import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/providers/authentication_providers.dart';
import '../domain/body_enums.dart';
import '../models/body_goal.dart';
import '../providers/body_progress_providers.dart';

/// Controller de metas corporais (PROMPT 08).
class GoalsController extends Notifier<List<BodyGoal>> {
  final Uuid _uuid = const Uuid();

  @override
  List<BodyGoal> build() =>
      ref.read(bodyProgressRepositoryProvider).goals();

  Future<void> add({
    required GoalType type,
    required double target,
    required double startValue,
    DateTime? deadline,
    String? note,
  }) async {
    final uid =
        ref.read(authenticationRepositoryProvider).currentUser?.id ?? '';
    await ref.read(bodyProgressRepositoryProvider).addGoal(
          BodyGoal(
            id: _uuid.v4(),
            userId: uid,
            type: type,
            target: target,
            startValue: startValue,
            deadline: deadline,
            note: note,
            createdAt: DateTime.now(),
          ),
        );
    state = ref.read(bodyProgressRepositoryProvider).goals();
  }

  Future<void> remove(String id) async {
    await ref.read(bodyProgressRepositoryProvider).removeGoal(id);
    state = ref.read(bodyProgressRepositoryProvider).goals();
  }
}
