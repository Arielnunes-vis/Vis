import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/insight_enums.dart';
import '../models/insight.dart';
import '../models/weekly_summary.dart';
import '../providers/insight_providers.dart';

/// Tela de insights e alertas (PROMPT 14).
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  bool _onlyAlerts = false;

  @override
  Widget build(BuildContext context) {
    final bundle = ref.watch(insightBundleProvider);
    final insights = _onlyAlerts
        ? bundle.insights.where((i) => i.isAlert).toList()
        : bundle.insights;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () => ref.invalidate(insightBundleProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(insightBundleProvider),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.m),
          children: [
            _WeeklyCard(weekly: bundle.weekly),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Text('Insights', style: AppTypography.subtitle),
                const Spacer(),
                FilterChip(
                  label: const Text('Só alertas'),
                  selected: _onlyAlerts,
                  onSelected: (v) => setState(() => _onlyAlerts = v),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            for (final i in insights)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: _InsightCard(insight: i),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.weekly});
  final WeeklySummary weekly;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumo da semana', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          if (weekly.isEmpty)
            Text('Sem atividade registrada nesta semana ainda.',
                style: AppTypography.caption)
          else ...[
            Text(
              '${weekly.workouts} treinos · ${weekly.totalMinutes} min · '
              '${weekly.totalVolume.toStringAsFixed(0)} kg · '
              '${weekly.cardioSessions} cardio(s)',
              style: AppTypography.body,
            ),
            for (final h in weekly.highlights)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('✔ $h', style: AppTypography.small),
              ),
            for (final a in weekly.attentionPoints)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('• $a',
                    style: AppTypography.small
                        .copyWith(color: AppColors.warning)),
              ),
          ],
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});
  final Insight insight;

  Color get _color {
    if (insight.isAlert) {
      return insight.priority == InsightPriority.critical
          ? AppColors.danger
          : AppColors.warning;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      color: _color.withValues(alpha: 0.1),
      borderColor: _color.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                insight.isAlert ? LucideIcons.alertTriangle : LucideIcons.sparkles,
                size: 16,
                color: _color,
              ),
              const SizedBox(width: 8),
              Text(insight.category.label,
                  style: AppTypography.small.copyWith(color: _color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(insight.title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(insight.message, style: AppTypography.body),
          if (insight.reason != null) ...[
            const SizedBox(height: 6),
            Text(insight.reason!, style: AppTypography.small),
          ],
        ],
      ),
    );
  }
}
