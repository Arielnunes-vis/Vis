part of 'dashboard_screen.dart';

/// Cartões do Dashboard extraídos de dashboard_screen.dart (mantidos
/// privados via `part`; compartilham os imports da biblioteca).

class _NextWorkoutCard extends ConsumerWidget {
  const _NextWorkoutCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final up = data.upcoming;
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.dumbbell, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Próximo treino', style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          if (up == null)
            Text('Você ainda não tem um treino ativo.',
                style: AppTypography.body)
          else ...[
            Text('${up.dayName} · ${up.planName}',
                style: AppTypography.subtitle),
            const SizedBox(height: 4),
            Text(
              '${up.exerciseCount} exercícios'
              '${up.muscleGroups.isNotEmpty ? ' · ${up.muscleGroups.take(3).join(', ')}' : ''}',
              style: AppTypography.caption,
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          PrimaryButton(
            label: up == null ? 'Criar treino' : 'Iniciar treino',
            icon: up == null ? LucideIcons.plus : LucideIcons.play,
            onPressed: () {
              if (data.activePlan != null) {
                context.pushNamed('workout-detail', extra: data.activePlan);
              } else {
                context.goNamed('workout');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SequenceCard extends StatelessWidget {
  const _SequenceCard({required this.sequence});
  final TrainingSequence sequence;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Row(
        children: [
          Text('🔥', style: AppTypography.display.copyWith(fontSize: 34)),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${sequence.current} dias em sequência',
                    style: AppTypography.subtitle),
                Text(
                  'Maior sequência: ${sequence.longest} · '
                  'Semana: ${sequence.weekCount}/${sequence.weekGoal}',
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

class _ShortcutsRow extends StatelessWidget {
  const _ShortcutsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _shortcut(context, LucideIcons.heartPulse, 'Cardio', 'cardio'),
        const SizedBox(width: AppSpacing.s),
        _shortcut(context, LucideIcons.utensils, 'Nutrição', 'nutrition'),
        const SizedBox(width: AppSpacing.s),
        _shortcut(context, LucideIcons.sparkles, 'Coach', 'ai'),
        const SizedBox(width: AppSpacing.s),
        _shortcut(context, LucideIcons.zap, 'Treino IA', 'ai-workout'),
      ],
    );
  }

  Widget _shortcut(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return Expanded(
      child: CardContainer(
        onTap: () => context.pushNamed(route),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label, style: AppTypography.small, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({
    required this.sequence,
    this.cardioMinutes = 0,
    this.todayProtein = 0,
    this.todayWaterMl = 0,
  });
  final TrainingSequence sequence;
  final int cardioMinutes;
  final double todayProtein;
  final int todayWaterMl;

  @override
  Widget build(BuildContext context) {
    final goal = sequence.weekGoal == 0 ? 1 : sequence.weekGoal;
    final progress = (sequence.weekCount / goal).clamp(0.0, 1.0);
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Objetivos da semana', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Expanded(child: Text('Treinos', style: AppTypography.body)),
              Text('${sequence.weekCount} / ${sequence.weekGoal}',
                  style: AppTypography.body),
            ],
          ),
          const SizedBox(height: 6),
          VisProgressBar(value: progress, color: AppColors.success),
          const SizedBox(height: AppSpacing.s),
          Text(
            _summaryLine(),
            style: AppTypography.small,
          ),
        ],
      ),
    );
  }

  String _summaryLine() {
    final parts = <String>[
      if (cardioMinutes > 0) 'Cardio $cardioMinutes min',
      if (todayProtein > 0) 'Proteína ${todayProtein.toStringAsFixed(0)}g hoje',
      if (todayWaterMl > 0) 'Água ${todayWaterMl}ml hoje',
    ];
    return parts.isEmpty
        ? 'Cardio, peso e proteína aparecem quando você registrar.'
        : parts.join(' · ');
  }
}

class _EvolutionCard extends StatelessWidget {
  const _EvolutionCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      onTap: () => context.goNamed('progress'),
      child: Row(
        children: [
          const Icon(LucideIcons.trendingUp, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Evolução corporal', style: AppTypography.subtitle),
                Text(
                  data.latestWeight != null
                      ? 'Peso atual: ${data.latestWeight!.toStringAsFixed(1)} kg'
                      : 'Registre seu peso, medidas e fotos.',
                  style: AppTypography.small,
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.weekly});
  final WeeklyStats weekly;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Resumo semanal',
      child: Wrap(
        runSpacing: AppSpacing.m,
        children: [
          _metric('Treinos', '${weekly.workouts}'),
          _metric('Tempo', '${weekly.totalMinutes} min'),
          _metric('Volume', '${weekly.totalVolume.toStringAsFixed(0)} kg'),
          _metric('Séries', '${weekly.totalSets}'),
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

class _CalendarStrip extends StatelessWidget {
  const _CalendarStrip({required this.activity});
  final List<RecentActivity> activity;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final trained = activity
        .map((a) => DateTime(a.date.year, a.date.month, a.date.day))
        .toSet();
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return _SectionCard(
      title: 'Calendário',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 7; i++)
            _day(
              labels[i],
              startOfWeek.add(Duration(days: i)),
              trained,
              now,
            ),
        ],
      ),
    );
  }

  Widget _day(String label, DateTime date, Set<DateTime> trained, DateTime now) {
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final didTrain = trained.contains(date);
    return Column(
      children: [
        Text(label, style: AppTypography.small),
        const SizedBox(height: 6),
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: didTrain ? AppColors.primary : AppColors.card,
            border: isToday
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Text('${date.day}',
              style: AppTypography.small.copyWith(
                color: didTrain ? AppColors.onPrimary : AppColors.textSecondary,
              )),
        ),
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.activity});
  final List<RecentActivity> activity;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Últimos treinos',
      child: activity.isEmpty
          ? Text('Nenhum treino ainda.', style: AppTypography.caption)
          : Column(
              children: [
                for (final a in activity.take(5))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.checkCircle2,
                            size: 18, color: AppColors.success),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.title, style: AppTypography.body),
                              if (a.subtitle != null)
                                Text(a.subtitle!, style: AppTypography.small),
                            ],
                          ),
                        ),
                        Text(_date(a.date), style: AppTypography.small),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          child,
        ],
      ),
    );
  }
}
