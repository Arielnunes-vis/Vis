import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/analytics_report.dart';
import 'analytics_format.dart';

/// Grade de KPIs do período (treinos, volume, séries, tempo).
class AnalyticsSummaryGrid extends StatelessWidget {
  const AnalyticsSummaryGrid({required this.report, super.key});
  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      MetricCard(
        title: 'Treinos',
        value: '${report.workouts}',
        delta: '${report.weeklyFrequency.toStringAsFixed(1)}/semana',
        icon: LucideIcons.dumbbell,
      ),
      MetricCard(
        title: 'Volume total',
        value: AnalyticsFormat.kg(report.totalVolume),
        delta: '${AnalyticsFormat.kg(report.avgSessionVolume)}/treino',
        icon: LucideIcons.trendingUp,
      ),
      MetricCard(
        title: 'Séries',
        value: '${report.totalSets}',
        icon: LucideIcons.listChecks,
      ),
      MetricCard(
        title: 'Tempo treinado',
        value: AnalyticsFormat.minutes(report.totalMinutes),
        delta: '${report.avgSessionMinutes.round()} min/treino',
        icon: LucideIcons.clock,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.s;
        final width = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items) SizedBox(width: width, child: item),
          ],
        );
      },
    );
  }
}

/// Gráfico de tendência de volume ao longo do período.
class VolumeTrendCard extends StatelessWidget {
  const VolumeTrendCard({required this.report, super.key});
  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    final points = report.volumeTrend;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tendência de volume', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          if (points.isEmpty)
            Text('Sem dados suficientes no período.',
                style: AppTypography.caption)
          else ...[
            ProgressChart(
              points: [
                for (var i = 0; i < points.length; i++)
                  (x: i.toDouble(), y: points[i].value),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final p in points)
                  Expanded(
                    child: Text(
                      p.label,
                      textAlign: TextAlign.center,
                      style: AppTypography.small
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Distribuição de volume por grupo muscular (barras proporcionais).
class MuscleDistributionCard extends StatelessWidget {
  const MuscleDistributionCard({required this.report, super.key});
  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    final items = report.muscleDistribution;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribuição por músculo', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          if (items.isEmpty)
            Text('Nenhum volume registrado no período.',
                style: AppTypography.caption)
          else
            for (final m in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: _MuscleBar(item: m),
              ),
        ],
      ),
    );
  }
}

class _MuscleBar extends StatelessWidget {
  const _MuscleBar({required this.item});
  final MuscleDistribution item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.muscle, style: AppTypography.small),
            Text('${(item.percent * 100).round()}%',
                style: AppTypography.small
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: item.percent.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.divider,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
