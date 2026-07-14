import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/workout_summary.dart';
import 'workout_session_screen.dart' show formatDuration;

/// Resumo final do treino (PROMPT 06).
class WorkoutSummaryScreen extends ConsumerWidget {
  const WorkoutSummaryScreen({required this.summary, super.key});

  final WorkoutSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = summary.session;
    final stats = summary.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treino concluído'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          Center(
            child: Column(
              children: [
                const Icon(LucideIcons.checkCircle2,
                    size: 48, color: AppColors.success),
                const SizedBox(height: AppSpacing.s),
                Text(s.planName.isEmpty ? s.dayName : '${s.planName} · ${s.dayName}',
                    style: AppTypography.title, textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          CardContainer(
            child: Wrap(
              runSpacing: AppSpacing.m,
              children: [
                _stat('Tempo', formatDuration(stats.durationSeconds)),
                _stat('Volume', '${stats.totalVolume.toStringAsFixed(0)} kg'),
                _stat('Séries', '${stats.totalSets}'),
                _stat('Exercícios', '${stats.totalExercises}'),
              ],
            ),
          ),
          if (summary.hasPr) ...[
            const SizedBox(height: AppSpacing.l),
            const SectionHeader(title: '🏆 Recordes pessoais'),
            const SizedBox(height: AppSpacing.s),
            for (final pr in summary.personalRecords)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: CardContainer(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.trophy,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('${pr.exerciseName} · ${pr.kind.label}',
                            style: AppTypography.body),
                      ),
                      Text(pr.display,
                          style: AppTypography.subtitle
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
              ),
          ],
          if (s.muscleGroups.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            const SectionHeader(title: 'Grupos treinados'),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in s.muscleGroups) VisBadge(label: m),
              ],
            ),
          ],
          if (s.mood != null || s.energy != null) ...[
            const SizedBox(height: AppSpacing.l),
            CardContainer(
              child: Row(
                children: [
                  if (s.mood != null)
                    Expanded(child: _stat('Humor', s.mood!.label)),
                  if (s.energy != null)
                    Expanded(child: _stat('Energia', '${s.energy}/5')),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Concluir',
            onPressed: () => context.goNamed('workout'),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.title),
            Text(label, style: AppTypography.small),
          ],
        ),
      );
}
