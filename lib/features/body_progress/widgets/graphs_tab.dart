import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/body_enums.dart';
import '../providers/body_progress_providers.dart';

/// Aba de gráficos: peso e circunferências (PROMPT 08).
class GraphsTab extends ConsumerStatefulWidget {
  const GraphsTab({super.key});

  @override
  ConsumerState<GraphsTab> createState() => _GraphsTabState();
}

class _GraphsTabState extends ConsumerState<GraphsTab> {
  MeasurementField _field = MeasurementField.chest;

  @override
  Widget build(BuildContext context) {
    final weights = ref.watch(weightControllerProvider).reversed.toList();
    final measures =
        ref.watch(measurementsControllerProvider).reversed.toList();

    final weightPoints = [
      for (var i = 0; i < weights.length; i++)
        (x: i.toDouble(), y: weights[i].weight),
    ];

    final fieldPoints = <({double x, double y})>[];
    var idx = 0;
    for (final m in measures) {
      final v = m.value(_field);
      if (v != null) {
        fieldPoints.add((x: idx.toDouble(), y: v));
        idx++;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Peso', style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.s),
              if (weightPoints.isEmpty)
                Text('Sem registros de peso.', style: AppTypography.caption)
              else
                ProgressChart(points: weightPoints),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Circunferência', style: AppTypography.subtitle),
                  ),
                  DropdownButton<MeasurementField>(
                    value: _field,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final f in MeasurementField.values)
                        DropdownMenuItem(
                          value: f,
                          child: Text(f.label,
                              style: AppTypography.body.copyWith(fontSize: 14)),
                        ),
                    ],
                    onChanged: (f) => setState(() => _field = f ?? _field),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              if (fieldPoints.isEmpty)
                Text('Sem registros para ${_field.label}.',
                    style: AppTypography.caption)
              else
                ProgressChart(points: fieldPoints),
            ],
          ),
        ),
      ],
    );
  }
}
