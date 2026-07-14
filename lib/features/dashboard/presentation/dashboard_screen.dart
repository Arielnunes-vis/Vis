import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../authentication/providers/authentication_providers.dart';
import '../models/dashboard_data.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/muscle_volume_bars.dart';

part 'dashboard_sections.dart';

/// Dashboard Inteligente — primeira tela após o login (PROMPT 07).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardControllerProvider);
    final name = ref.watch(currentUserProvider).value?.name?.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting(name), style: AppTypography.subtitle),
            Text(_todayLabel(), style: AppTypography.small),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () => context.pushNamed('notifications'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const DashboardSkeleton(),
        error: (_, __) => ErrorState(
          onRetry: () =>
              ref.read(dashboardControllerProvider.notifier).refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: _cards(context, ref, data),
          ),
        ),
      ),
    );
  }

  List<Widget> _cards(BuildContext context, WidgetRef ref, DashboardData d) {
    return [
      if (d.insight != null) ...[
        InsightCard(
          message: '${d.insight!.message}'
              '${d.insight!.reason != null ? '\n\n${d.insight!.reason}' : ''}',
          onDetails: () => context.pushNamed('insights'),
        ),
        const SizedBox(height: AppSpacing.m),
      ],
      _NextWorkoutCard(data: d),
      const SizedBox(height: AppSpacing.m),
      const _ShortcutsRow(),
      const SizedBox(height: AppSpacing.m),
      _SequenceCard(sequence: d.sequence),
      const SizedBox(height: AppSpacing.m),
      _GoalsCard(
        sequence: d.sequence,
        cardioMinutes: d.weeklyCardioMinutes,
        todayProtein: d.todayProtein,
        todayWaterMl: d.todayWaterMl,
      ),
      const SizedBox(height: AppSpacing.m),
      _EvolutionCard(data: d),
      const SizedBox(height: AppSpacing.m),
      _WeeklyCard(weekly: d.weekly),
      const SizedBox(height: AppSpacing.m),
      _CalendarStrip(activity: d.recentActivity),
      const SizedBox(height: AppSpacing.m),
      _SectionCard(
        title: 'Volume muscular (30 dias)',
        child: MuscleVolumeBars(data: d.muscleVolume),
      ),
      const SizedBox(height: AppSpacing.m),
      _RecentCard(activity: d.recentActivity),
    ];
  }

  String _greeting(String? name) {
    final h = DateTime.now().hour;
    final part = h < 12 ? 'Bom dia' : (h < 18 ? 'Boa tarde' : 'Boa noite');
    return name == null ? '$part 👋' : '$part, $name 👋';
  }

  String _todayLabel() {
    const days = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];
    return 'Hoje é ${days[DateTime.now().weekday - 1]}.';
  }
}

