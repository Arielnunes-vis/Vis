import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../body_progress/providers/body_progress_providers.dart';
import '../../cardio/providers/cardio_providers.dart';
import '../../workout_session/providers/workout_session_providers.dart';
import '../data/analytics_service.dart';
import '../domain/analytics_enums.dart';
import '../models/analytics_report.dart';

/// Providers do módulo de Analytics (PROMPT 16).

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(
    sessionRepository: ref.watch(workoutSessionRepositoryProvider),
    cardioRepository: ref.watch(cardioRepositoryProvider),
    bodyRepository: ref.watch(bodyProgressRepositoryProvider),
  ),
);

/// Período selecionado na tela de Analytics.
final analyticsPeriodProvider =
    StateProvider<AnalyticsPeriod>((ref) => AnalyticsPeriod.month);

/// Relatório calculado para o período atualmente selecionado.
final analyticsReportProvider = Provider<AnalyticsReport>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  return ref.watch(analyticsServiceProvider).buildReport(period);
});
