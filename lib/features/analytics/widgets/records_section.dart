import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/analytics_report.dart';
import 'analytics_format.dart';

/// Lista de recordes pessoais por exercício no período.
class RecordsCard extends StatelessWidget {
  const RecordsCard({required this.records, this.limit = 8, super.key});

  final List<PersonalRecord> records;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final shown = records.take(limit).toList();
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.trophy,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              Text('Recordes pessoais', style: AppTypography.subtitle),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          if (shown.isEmpty)
            Text('Registre treinos com carga para ver seus recordes.',
                style: AppTypography.caption)
          else
            for (final r in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: _RecordRow(record: r),
              ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record});
  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(record.exerciseName,
                  style: AppTypography.body
                      .copyWith(fontWeight: FontWeight.w600)),
              if (record.muscleGroup.isNotEmpty)
                Text(record.muscleGroup,
                    style: AppTypography.small
                        .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${record.maxWeight.toStringAsFixed(record.maxWeight % 1 == 0 ? 0 : 1)} kg × ${record.repsAtMaxWeight}',
              style: AppTypography.body,
            ),
            Text('1RM ~${record.estimatedOneRm.round()} kg',
                style: AppTypography.small
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

/// Resumo de cardio e variação de peso no período.
class CardioWeightCard extends StatelessWidget {
  const CardioWeightCard({required this.report, super.key});
  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    final cardio = report.cardio;
    final weight = report.weight;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cardio e peso', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          _Line(
            icon: LucideIcons.heartPulse,
            label: 'Cardio',
            value: cardio.isEmpty
                ? 'Sem sessões no período'
                : '${cardio.sessions} sessões · ${AnalyticsFormat.minutes(cardio.minutes)}'
                    '${cardio.distanceKm > 0 ? ' · ${AnalyticsFormat.km(cardio.distanceKm)}' : ''}',
          ),
          const SizedBox(height: AppSpacing.s),
          _Line(
            icon: LucideIcons.scale,
            label: 'Peso',
            value: !weight.hasData
                ? 'Sem registros no período'
                : '${weight.end!.toStringAsFixed(1)} kg '
                    '(${_deltaLabel(weight.delta!)})',
            valueColor: weight.hasData ? _deltaColor(weight.delta!) : null,
          ),
        ],
      ),
    );
  }

  String _deltaLabel(double delta) {
    final sign = delta > 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(1)} kg';
  }

  Color? _deltaColor(double delta) {
    if (delta == 0) return AppColors.textSecondary;
    // Sem julgar direção (depende do objetivo) — apenas destaca a variação.
    return AppColors.textSecondary;
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.small),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.small
                .copyWith(color: valueColor ?? AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
