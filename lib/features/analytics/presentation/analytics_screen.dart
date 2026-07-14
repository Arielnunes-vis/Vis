import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/analytics_enums.dart';
import '../models/analytics_report.dart';
import '../providers/analytics_providers.dart';
import '../widgets/analytics_format.dart';
import '../widgets/analytics_sections.dart';
import '../widgets/records_section.dart';

/// Tela de estatísticas e relatórios (PROMPT 16).
///
/// Interpreta o histórico já registrado por período; nunca cria dados.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(analyticsPeriodProvider);
    final report = ref.watch(analyticsReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        actions: [
          IconButton(
            tooltip: 'Exportar resumo',
            icon: const Icon(LucideIcons.share2),
            onPressed: () => _export(context, report),
          ),
        ],
      ),
      body: Column(
        children: [
          _PeriodSelector(
            selected: period,
            onSelected: (p) =>
                ref.read(analyticsPeriodProvider.notifier).state = p,
          ),
          Expanded(
            child: report.isEmpty
                ? const EmptyState(
                    icon: LucideIcons.barChart3,
                    title: 'Sem dados para analisar',
                    description:
                        'Registre treinos, cardio ou peso para ver suas '
                        'estatísticas por período aqui.',
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    children: [
                      AnalyticsSummaryGrid(report: report),
                      const SizedBox(height: AppSpacing.m),
                      VolumeTrendCard(report: report),
                      const SizedBox(height: AppSpacing.m),
                      MuscleDistributionCard(report: report),
                      const SizedBox(height: AppSpacing.m),
                      RecordsCard(records: report.personalRecords),
                      const SizedBox(height: AppSpacing.m),
                      CardioWeightCard(report: report),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, AnalyticsReport report) async {
    await Clipboard.setData(ClipboardData(text: _summaryText(report)));
    if (context.mounted) {
      AppSnackBar.show(context, 'Resumo copiado para a área de transferência.',
          type: SnackType.success);
    }
  }

  String _summaryText(AnalyticsReport r) {
    final b = StringBuffer()
      ..writeln('VIS — Estatísticas (${r.period.label})')
      ..writeln('Treinos: ${r.workouts} (${r.weeklyFrequency.toStringAsFixed(1)}/semana)')
      ..writeln('Dias ativos: ${r.activeDays}')
      ..writeln('Volume total: ${AnalyticsFormat.kg(r.totalVolume)}')
      ..writeln('Séries: ${r.totalSets}')
      ..writeln('Tempo treinado: ${AnalyticsFormat.minutes(r.totalMinutes)}');
    if (!r.cardio.isEmpty) {
      b.writeln(
          'Cardio: ${r.cardio.sessions} sessões · ${AnalyticsFormat.minutes(r.cardio.minutes)}');
    }
    if (r.weight.hasData) {
      b.writeln(
          'Peso: ${r.weight.start!.toStringAsFixed(1)} → ${r.weight.end!.toStringAsFixed(1)} kg');
    }
    if (r.personalRecords.isNotEmpty) {
      b.writeln('Recordes:');
      for (final pr in r.personalRecords.take(5)) {
        b.writeln(
            '  • ${pr.exerciseName}: ${pr.maxWeight.toStringAsFixed(0)}kg × ${pr.repsAtMaxWeight}');
      }
    }
    return b.toString();
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onSelected});

  final AnalyticsPeriod selected;
  final ValueChanged<AnalyticsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m, vertical: AppSpacing.s),
      child: Row(
        children: [
          for (final p in AnalyticsPeriod.values) ...[
            ChoiceChip(
              label: Text(p.label),
              selected: p == selected,
              onSelected: (_) => onSelected(p),
            ),
            const SizedBox(width: AppSpacing.s),
          ],
        ],
      ),
    );
  }
}
