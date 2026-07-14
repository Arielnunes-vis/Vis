import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../exercise/models/exercise.dart';
import '../../exercise/providers/exercise_providers.dart';
import '../models/exercise_ref.dart';

/// Bottom sheet para escolher um exercício da Biblioteca (PROMPT 05).
///
/// Consome o catálogo real (`exerciseRepositoryProvider`) e devolve um
/// [ExerciseRef] leve para o Workout Engine. Substitui a antiga semente.
class ExercisePickerSheet extends ConsumerStatefulWidget {
  const ExercisePickerSheet({super.key});

  static Future<ExerciseRef?> show(BuildContext context) {
    return showModalBottomSheet<ExerciseRef>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ExercisePickerSheet(),
    );
  }

  @override
  ConsumerState<ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<ExercisePickerSheet> {
  late Future<List<Exercise>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _search('');
  }

  Future<List<Exercise>> _search(String q) =>
      ref.read(exerciseRepositoryProvider).list(query: q, pageSize: 100);

  void _onQuery(String q) {
    setState(() {
      _query = q;
      _future = _search(q);
    });
  }

  ExerciseRef _toRef(Exercise e) => ExerciseRef(
        id: e.id,
        name: e.name,
        muscleGroup: e.primaryMuscle,
        secondaryMuscles: e.secondaryMuscles,
        equipment: e.equipment,
        gifUrl: e.gifUrl,
        videoUrl: e.videoUrl,
        imageUrl: e.imageUrl,
        execution: e.execution,
        commonErrors:
            e.commonErrors.isEmpty ? null : e.commonErrors.join('\n'),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.m,
        right: AppSpacing.m,
        top: AppSpacing.m,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.m,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            SearchField(hint: 'Buscar exercício...', onChanged: _onQuery),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: FutureBuilder<List<Exercise>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget();
                  }
                  final results = snapshot.data ?? const [];
                  if (results.isEmpty) {
                    return EmptyState(
                      title: 'Nenhum exercício encontrado',
                      description: _query.isEmpty ? null : 'Tente outro termo.',
                    );
                  }
                  return ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.s),
                    itemBuilder: (_, i) {
                      final ex = results[i];
                      return ExerciseCard(
                        name: ex.name,
                        muscle: ex.primaryMuscle,
                        equipment: ex.equipment,
                        imageUrl: ex.imageUrl,
                        onTap: () => Navigator.of(context).pop(_toRef(ex)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
