import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/nutrition_goal_status.dart';
import '../models/nutrition_period_report.dart';

/// Seções dos relatórios semanal/mensal de nutrição (PROMPT 10 —
/// Relatórios). Mesma UI para os dois períodos — evita duplicar layout.

const _fullMonths = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

String _shortDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

/// Composição completa de um relatório de período (usada pela aba
/// "Semana" e pela aba "Mês" da tela de Nutrição).
class NutritionReportView extends StatelessWidget {
  const NutritionReportView({
    required this.report,
    required this.periodLabel,
    super.key,
  });

  /// Relatório já calculado (semanal ou mensal).
  final NutritionPeriodReport report;

  /// "Semana" ou "Mês" — usado nos títulos das seções.
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        _PeriodHeader(report: report, periodLabel: periodLabel),
        const SizedBox(height: AppSpacing.m),
        if (report.isEmpty)
          EmptyState(
            icon: LucideIcons.utensils,
            title: 'Nenhuma refeição registrada',
            description:
                'Registre as refeições do período para ver o resumo aqui.',
          )
        else ...[
          NutritionReportStats(report: report),
          const SizedBox(height: AppSpacing.m),
          NutritionMacrosCard(report: report, periodLabel: periodLabel),
          const SizedBox(height: AppSpacing.m),
          if (report.totalWaterMl > 0) ...[
            NutritionWaterCard(report: report),
            const SizedBox(height: AppSpacing.m),
          ],
          NutritionTrendCard(report: report),
        ],
      ],
    );
  }
}

class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({required this.report, required this.periodLabel});
  final NutritionPeriodReport report;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    // "Mês" sempre mostra o nome do mês; "Semana" sempre mostra o
    // intervalo de datas — decidido pela aba, nunca inferido das datas
    // (uma semana também pode começar no dia 1º de um mês).
    final label = periodLabel == 'mês'
        ? '${_fullMonths[report.start.month - 1][0].toUpperCase()}'
            '${_fullMonths[report.start.month - 1].substring(1)} de ${report.start.year}'
        : '${_shortDate(report.start)} a ${_shortDate(report.end)}';
    return Text(label, style: AppTypography.subtitle);
  }
}

/// Refeições registradas, dias com registro e água do período.
class NutritionReportStats extends StatelessWidget {
  const NutritionReportStats({required this.report, super.key});
  final NutritionPeriodReport report;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      MetricCard(
        title: 'Refeições registradas',
        value: '${report.mealsCount}',
        icon: LucideIcons.utensils,
      ),
      MetricCard(
        title: 'Dias registrados',
        value: '${report.daysWithRecords}/${report.totalDaysInPeriod}',
        icon: LucideIcons.checkCircle2,
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

/// Calorias, proteína, carboidrato e gordura — total, média por dia
/// registrado e status frente à meta configurada.
class NutritionMacrosCard extends StatelessWidget {
  const NutritionMacrosCard({
    required this.report,
    required this.periodLabel,
    super.key,
  });

  final NutritionPeriodReport report;
  final String periodLabel;

  String _unitFor(String label) => label == 'Calorias' ? 'kcal' : 'g';

  Color _statusColor(NutritionGoalStatus status) =>
      status == NutritionGoalStatus.onTarget ? AppColors.success : AppColors.warning;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calorias e macros — $periodLabel', style: AppTypography.subtitle),
          Text(
            'Total consumido e média por dia registrado, comparados com sua meta diária.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.s),
          for (final m in report.metrics)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(m.label, style: AppTypography.body)),
                      if (m.status != null)
                        VisBadge(
                          label: m.status!.label,
                          color: _statusColor(m.status!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      'Total: ${m.total.toStringAsFixed(0)} ${_unitFor(m.label)}',
                      'Média/dia: ${m.average.toStringAsFixed(0)} ${_unitFor(m.label)}',
                      if (m.goal != null) 'Meta: ${m.goal!.toStringAsFixed(0)} ${_unitFor(m.label)}',
                    ].join(' · '),
                    style: AppTypography.small,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Água consumida no período (só aparece se o usuário já registrou água).
class NutritionWaterCard extends StatelessWidget {
  const NutritionWaterCard({required this.report, super.key});
  final NutritionPeriodReport report;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Row(
        children: [
          const Icon(LucideIcons.droplet, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Água', style: AppTypography.subtitle),
                Text(
                  'Total: ${report.totalWaterMl} ml · Média/dia: ${report.avgWaterMl} ml',
                  style: AppTypography.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gráfico simples de calorias por dia no período.
class NutritionTrendCard extends StatelessWidget {
  const NutritionTrendCard({required this.report, super.key});
  final NutritionPeriodReport report;

  @override
  Widget build(BuildContext context) {
    final points = report.dailyTrend;
    final hasData = points.any((p) => p.calories > 0);
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calorias por dia', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          if (!hasData)
            Text('Sem refeições registradas neste período.',
                style: AppTypography.caption)
          else ...[
            ProgressChart(
              points: [
                for (var i = 0; i < points.length; i++)
                  (x: i.toDouble(), y: points[i].calories),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            _TrendAxisLabels(points: points),
          ],
        ],
      ),
    );
  }
}

class _TrendAxisLabels extends StatelessWidget {
  const _TrendAxisLabels({required this.points});
  final List<NutritionDailyPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    // Em períodos longos (mês) mostra no máximo ~7 rótulos para não poluir.
    final step = (points.length / 7).ceil().clamp(1, points.length);
    return Row(
      children: [
        for (var i = 0; i < points.length; i++)
          Expanded(
            child: i % step == 0
                ? Text(
                    _shortDate(points[i].date),
                    textAlign: TextAlign.center,
                    style: AppTypography.small.copyWith(color: AppColors.textSecondary),
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
