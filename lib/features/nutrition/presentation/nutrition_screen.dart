import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/nutrition_enums.dart';
import '../models/macro_nutrients.dart';
import '../models/nutrition_goal.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/add_meal_sheet.dart';

/// Tela de nutrição — resumo do dia, água e refeições (PROMPT 10).
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(nutritionControllerProvider);
    final goal = ref.watch(nutritionGoalProvider);
    final macros = day.macros;

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrição')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddMealSheet.show(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Refeição'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          _summary(macros, goal),
          const SizedBox(height: AppSpacing.m),
          _water(context, ref, day.waterMl, goal.waterMl ?? 2500),
          const SizedBox(height: AppSpacing.m),
          Text('Refeições de hoje', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          if (day.meals.isEmpty)
            Text('Nenhuma refeição registrada hoje.',
                style: AppTypography.caption)
          else
            for (final m in day.meals)
              CardContainer(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(LucideIcons.utensils,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.type.label, style: AppTypography.body),
                          Text(
                            m.items.map((i) => i.name).join(', '),
                            style: AppTypography.small,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text('${m.macros.calories.toStringAsFixed(0)} kcal',
                        style: AppTypography.small),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _summary(MacroNutrients macros, NutritionGoal goal) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumo do dia', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          _bar('Calorias', macros.calories, goal.calories ?? 2200, 'kcal',
              AppColors.primary),
          _bar('Proteína', macros.protein, goal.protein ?? 140, 'g',
              AppColors.success),
          _bar('Carboidrato', macros.carbs, goal.carbs ?? 250, 'g',
              AppColors.warning),
          _bar('Gordura', macros.fats, goal.fats ?? 70, 'g', AppColors.secondary),
        ],
      ),
    );
  }

  Widget _bar(
    String label,
    double current,
    double goal,
    String unit,
    Color color,
  ) {
    final progress = goal <= 0 ? 0.0 : (current / goal).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTypography.body)),
              Text('${current.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit',
                  style: AppTypography.small),
            ],
          ),
          const SizedBox(height: 4),
          VisProgressBar(value: progress, color: color),
        ],
      ),
    );
  }

  Widget _water(BuildContext context, WidgetRef ref, int current, int goal) {
    final progress = goal <= 0 ? 0.0 : (current / goal).clamp(0.0, 1.0);
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.droplet, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Água', style: AppTypography.subtitle)),
              Text('$current / $goal ml', style: AppTypography.small),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          VisProgressBar(value: progress, color: AppColors.primary),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: 8,
            children: [
              for (final w in WaterContainer.values)
                ActionChip(
                  label: Text(w.label),
                  onPressed: () => ref
                      .read(nutritionControllerProvider.notifier)
                      .addWater(w.ml),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
