import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/weight_record.dart';
import '../providers/body_progress_providers.dart';

/// Aba de peso: valor atual, gráfico e histórico (PROMPT 08).
class WeightTab extends ConsumerWidget {
  const WeightTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(weightControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSheet(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Registrar peso'),
      ),
      body: records.isEmpty
          ? const EmptyState(
              icon: LucideIcons.scale,
              title: 'Nenhum peso registrado',
              description: 'Registre seu peso para acompanhar a evolução.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.m),
              children: [
                _current(records),
                const SizedBox(height: AppSpacing.m),
                CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Evolução', style: AppTypography.subtitle),
                      const SizedBox(height: AppSpacing.s),
                      ProgressChart(points: _points(records)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Text('Histórico', style: AppTypography.subtitle),
                const SizedBox(height: AppSpacing.s),
                for (var i = 0; i < records.length; i++)
                  _row(records[i],
                      i + 1 < records.length ? records[i + 1] : null),
              ],
            ),
    );
  }

  Widget _current(List<WeightRecord> records) {
    final latest = records.first;
    final prev = records.length > 1 ? records[1] : null;
    final delta = prev == null ? null : latest.weight - prev.weight;
    return CardContainer(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Peso atual', style: AppTypography.caption),
              Text('${latest.weight.toStringAsFixed(1)} kg',
                  style: AppTypography.display.copyWith(fontSize: 34)),
            ],
          ),
          const Spacer(),
          if (delta != null)
            Text(
              '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg',
              style: AppTypography.subtitle.copyWith(
                color: delta == 0
                    ? AppColors.textSecondary
                    : (delta > 0 ? AppColors.warning : AppColors.success),
              ),
            ),
        ],
      ),
    );
  }

  List<({double x, double y})> _points(List<WeightRecord> records) {
    final asc = records.reversed.toList();
    return [
      for (var i = 0; i < asc.length; i++)
        (x: i.toDouble(), y: asc[i].weight),
    ];
  }

  Widget _row(WeightRecord r, WeightRecord? older) {
    final delta = older == null ? null : r.weight - older.weight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(_date(r.recordedAt), style: AppTypography.body),
          ),
          Text('${r.weight.toStringAsFixed(1)} kg', style: AppTypography.body),
          if (delta != null) ...[
            const SizedBox(width: 10),
            Text('${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}',
                style: AppTypography.small.copyWith(
                  color: delta > 0 ? AppColors.warning : AppColors.success,
                )),
          ],
        ],
      ),
    );
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _addSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddWeightSheet(),
    );
  }
}

/// Folha de registro de peso. `ConsumerStatefulWidget` para descartar os
/// `TextEditingController` no `dispose` (evita vazamento), usar o `ref`
/// herdado (lifecycle correto) e tratar erros de gravação.
class _AddWeightSheet extends ConsumerStatefulWidget {
  const _AddWeightSheet();

  @override
  ConsumerState<_AddWeightSheet> createState() => _AddWeightSheetState();
}

class _AddWeightSheetState extends ConsumerState<_AddWeightSheet> {
  final _weight = TextEditingController();
  final _bodyFat = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _weight.dispose();
    _bodyFat.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final w = double.tryParse(_weight.text.replaceAll(',', '.'));
    if (w == null) {
      AppSnackBar.show(context, 'Informe um peso válido.',
          type: SnackType.warning);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(weightControllerProvider.notifier).add(
            weight: w,
            bodyFat: double.tryParse(_bodyFat.text.replaceAll(',', '.')),
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.show(context, 'Não foi possível salvar o peso.',
          type: SnackType.error);
    }
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registrar peso', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.m),
          VisTextField(
            label: 'Peso (kg)',
            controller: _weight,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.m),
          VisTextField(
            label: '% Gordura (opcional)',
            controller: _bodyFat,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.m),
          VisTextField(label: 'Observação (opcional)', controller: _note),
          const SizedBox(height: AppSpacing.l),
          PrimaryButton(
            label: 'Salvar',
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
