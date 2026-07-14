import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_data.dart';
import '../providers/dashboard_providers.dart';

/// Controller do Dashboard (PROMPT 07). Usa [AsyncValue] para cobrir
/// loading/error/data e permitir atualização por pull-to-refresh.
class DashboardController extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() =>
      ref.read(dashboardRepositoryProvider).load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dashboardRepositoryProvider).load(),
    );
  }
}
