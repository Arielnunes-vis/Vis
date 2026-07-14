import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/cardio_session.dart';
import '../models/cardio_stats.dart';
import '../providers/cardio_providers.dart';
import '../widgets/add_cardio_sheet.dart';

/// Módulo de cardio: resumo, recordes e histórico (PROMPT 09).
class CardioScreen extends ConsumerWidget {
  const CardioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(cardioControllerProvider);
    final repo = ref.watch(cardioRepositoryProvider);
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final week = repo.statsSince(startOfWeek);
    final records = repo.records();

    return Scaffold(
      appBar: AppBar(title: const Text('Cardio')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddCardioSheet.show(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Registrar cardio'),
      ),
      body: sessions.isEmpty
          ? const EmptyState(
              icon: LucideIcons.heartPulse,
              title: 'Nenhum cardio registrado',
              description: 'Registre suas atividades para acompanhar.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.m),
              children: [
                _WeeklyCard(stats: week),
                const SizedBox(height: AppSpacing.m),
                _RecordsCard(records: records),
                const SizedBox(height: AppSpacing.m),
                Text('Histórico', style: AppTypography.subtitle),
                const SizedBox(height: AppSpacing.s),
                for (final s in sessions.take(20)) _SessionRow(session: s),
              ],
            ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.stats});
  final CardioStats stats;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Esta semana', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            runSpacing: AppSpacing.m,
            children: [
              _metric('Sessões', '${stats.sessions}'),
              _metric('Tempo', '${stats.totalMinutes} min'),
              _metric('Distância', '${stats.totalDistance.toStringAsFixed(1)} km'),
              _metric('Calorias', '${stats.totalCalories.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) => SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.title),
            Text(label, style: AppTypography.small),
          ],
        ),
      );
}

class _RecordsCard extends StatelessWidget {
  const _RecordsCard({required this.records});
  final CardioRecords records;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      if (records.maxDistanceKm != null)
        ('Maior distância', '${records.maxDistanceKm!.toStringAsFixed(1)} km'),
      if (records.maxDurationSeconds != null)
        ('Maior tempo', '${(records.maxDurationSeconds! / 60).round()} min'),
      if (records.maxSpeedKmh != null)
        ('Maior velocidade', '${records.maxSpeedKmh!.toStringAsFixed(1)} km/h'),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recordes', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(it.$1, style: AppTypography.body)),
                  Text(it.$2,
                      style: AppTypography.body
                          .copyWith(color: AppColors.primary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});
  final CardioSession session;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      '${session.minutes} min',
      if (session.distanceKm != null)
        '${session.distanceKm!.toStringAsFixed(1)} km',
      if (session.paceLabel != null) session.paceLabel!,
      if (session.calories != null) '${session.calories!.toStringAsFixed(0)} kcal',
    ];
    return CardContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(LucideIcons.heartPulse, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.type.label, style: AppTypography.body),
                Text(parts.join(' · '), style: AppTypography.small),
              ],
            ),
          ),
          Text(_date(session.performedAt), style: AppTypography.small),
        ],
      ),
    );
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}
