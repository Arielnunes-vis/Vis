import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../controllers/workout_editor_controller.dart';
import '../domain/workout_enums.dart';
import '../models/workout_day.dart';
import '../models/workout_exercise.dart';
import '../providers/workout_providers.dart';
import '../widgets/exercise_picker_sheet.dart';
import '../widgets/set_editor_sheet.dart';

/// Editor de treino: criar ou editar um plano (PROMPT 04).
class WorkoutEditorScreen extends ConsumerStatefulWidget {
  const WorkoutEditorScreen({super.key});

  @override
  ConsumerState<WorkoutEditorScreen> createState() =>
      _WorkoutEditorScreenState();
}

class _WorkoutEditorScreenState extends ConsumerState<WorkoutEditorScreen> {
  late final TextEditingController _name;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final plan = ref.read(workoutEditorControllerProvider);
    _name = TextEditingController(text: plan.name);
    _description = TextEditingController(text: plan.description);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  WorkoutEditorController get _c =>
      ref.read(workoutEditorControllerProvider.notifier);

  Future<void> _save() async {
    if (!_c.isValid) {
      AppSnackBar.show(context, 'Dê um nome e adicione ao menos um dia.',
          type: SnackType.warning);
      return;
    }
    await _c.save();
    ref.invalidate(workoutListControllerProvider);
    if (mounted) {
      AppSnackBar.show(context, 'Treino salvo!', type: SnackType.success);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(workoutEditorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.name.isEmpty ? 'Novo treino' : 'Editar treino'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Salvar')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          VisTextField(
            label: 'Nome do treino',
            controller: _name,
            hint: 'Ex.: Hipertrofia ABC',
            onChanged: _c.setName,
          ),
          const SizedBox(height: AppSpacing.m),
          VisTextField(
            label: 'Descrição (opcional)',
            controller: _description,
            onChanged: _c.setDescription,
          ),
          const SizedBox(height: AppSpacing.l),
          Text('Objetivo', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in WorkoutGoalType.values)
                VisChip(
                  label: g.label,
                  selected: plan.goal == g,
                  onTap: () => _c.setGoal(g),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          const SectionHeader(title: 'Dias de treino'),
          const SizedBox(height: AppSpacing.s),
          for (final day in plan.days) _DayCard(day: day, controller: _c),
          const SizedBox(height: AppSpacing.s),
          SecondaryButton(
            label: 'Adicionar dia',
            icon: LucideIcons.plus,
            onPressed: _c.addDay,
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.controller});

  final WorkoutDay day;
  final WorkoutEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(day.name, style: AppTypography.subtitle),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.pencil, size: 18),
                  onPressed: () => _rename(context),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  onPressed: () => controller.removeDay(day.id),
                ),
              ],
            ),
            if (day.exercises.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                child: Text('Nenhum exercício ainda.',
                    style: AppTypography.small),
              ),
            for (var i = 0; i < day.exercises.length; i++)
              _ExerciseRow(
                dayId: day.id,
                exercise: day.exercises[i],
                index: i,
                total: day.exercises.length,
                controller: controller,
              ),
            const SizedBox(height: AppSpacing.s),
            SecondaryButton(
              label: 'Adicionar exercício',
              icon: LucideIcons.plus,
              onPressed: () async {
                final ex = await ExercisePickerSheet.show(context);
                if (ex != null) controller.addExercise(day.id, ex);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context) async {
    final ctrl = TextEditingController(text: day.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renomear dia'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Salvar')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) controller.renameDay(day.id, name);
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.dayId,
    required this.exercise,
    required this.index,
    required this.total,
    required this.controller,
  });

  final String dayId;
  final WorkoutExercise exercise;
  final int index;
  final int total;
  final WorkoutEditorController controller;

  @override
  Widget build(BuildContext context) {
    final ex = exercise;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => SetEditorSheet(dayId: dayId, exerciseId: ex.id),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ex.exercise.name, style: AppTypography.body),
                  Text('${ex.workingSets} séries · ${ex.exercise.muscleGroup}',
                      style: AppTypography.small),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronUp, size: 18),
            onPressed:
                index > 0 ? () => controller.moveExerciseUp(dayId, index) : null,
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronDown, size: 18),
            onPressed: index < total - 1
                ? () => controller.moveExerciseDown(dayId, index)
                : null,
          ),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 18),
            onPressed: () => controller.removeExercise(dayId, ex.id),
          ),
        ],
      ),
    );
  }
}
