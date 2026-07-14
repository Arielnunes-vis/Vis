import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/body_enums.dart';
import '../models/measurement_record.dart';
import '../providers/body_progress_providers.dart';

/// Aba de medidas: última medição + comparação com a anterior (PROMPT 08).
class MeasurementsTab extends ConsumerWidget {
  const MeasurementsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(measurementsControllerProvider);
    final latest = history.isNotEmpty ? history.first : null;
    final previous = history.length > 1 ? history[1] : null;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Nova medição'),
      ),
      body: latest == null
          ? const EmptyState(
              icon: LucideIcons.ruler,
              title: 'Nenhuma medida registrada',
              description: 'Registre suas circunferências para comparar.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.m),
              children: [
                Text('Última medição · ${_date(latest.recordedAt)}',
                    style: AppTypography.caption),
                const SizedBox(height: AppSpacing.s),
                CardContainer(
                  child: Column(
                    children: [
                      for (final d in latest.compareTo(previous))
                        _row(d),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _row(MeasurementDelta d) {
    final dir = d.direction;
    final color = dir == null || dir == 0
        ? AppColors.textSecondary
        : (dir > 0 ? AppColors.success : AppColors.danger);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(d.field.label, style: AppTypography.body)),
          Text('${d.current.toStringAsFixed(1)} cm', style: AppTypography.body),
          if (d.delta != null) ...[
            const SizedBox(width: 10),
            Icon(
              dir == 0
                  ? LucideIcons.minus
                  : (dir! > 0 ? LucideIcons.arrowUp : LucideIcons.arrowDown),
              size: 14,
              color: color,
            ),
            Text('${d.delta!.abs().toStringAsFixed(1)}',
                style: AppTypography.small.copyWith(color: color)),
          ],
        ],
      ),
    );
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _openForm(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddMeasurementSheet(),
    );
  }
}

class _AddMeasurementSheet extends ConsumerStatefulWidget {
  const _AddMeasurementSheet();

  @override
  ConsumerState<_AddMeasurementSheet> createState() =>
      _AddMeasurementSheetState();
}

class _AddMeasurementSheetState extends ConsumerState<_AddMeasurementSheet> {
  final Map<MeasurementField, TextEditingController> _controllers = {
    for (final f in MeasurementField.values) f: TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final values = <MeasurementField, double>{};
    for (final e in _controllers.entries) {
      final v = double.tryParse(e.value.text.replaceAll(',', '.'));
      if (v != null) values[e.key] = v;
    }
    if (values.isEmpty) {
      AppSnackBar.show(context, 'Preencha ao menos uma medida.',
          type: SnackType.warning);
      return;
    }
    ref
        .read(measurementsControllerProvider.notifier)
        .add(values: values);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nova medição (cm)', style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: ListView(
                children: [
                  for (final f in MeasurementField.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s),
                      child: VisTextField(
                        label: f.label,
                        controller: _controllers[f]!,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            PrimaryButton(label: 'Salvar medição', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
