import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/cardio_enums.dart';
import '../providers/cardio_providers.dart';

/// Bottom sheet de registro de cardio (PROMPT 09).
class AddCardioSheet extends ConsumerStatefulWidget {
  const AddCardioSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddCardioSheet(),
    );
  }

  @override
  ConsumerState<AddCardioSheet> createState() => _AddCardioSheetState();
}

class _AddCardioSheetState extends ConsumerState<AddCardioSheet> {
  CardioType _type = CardioType.running;
  final _minutes = TextEditingController();
  final _distance = TextEditingController();
  final _calories = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _minutes.dispose();
    _distance.dispose();
    _calories.dispose();
    _note.dispose();
    super.dispose();
  }

  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    final min = int.tryParse(_minutes.text);
    if (min == null || min <= 0) {
      AppSnackBar.show(context, 'Informe o tempo em minutos.',
          type: SnackType.warning);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(cardioControllerProvider.notifier).add(
            type: _type,
            durationSeconds: min * 60,
            distanceKm: double.tryParse(_distance.text.replaceAll(',', '.')),
            calories: double.tryParse(_calories.text.replaceAll(',', '.')),
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.show(context, 'Não foi possível salvar o cardio.',
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
          Text('Registrar cardio', style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.m),
          DropdownButtonFormField<CardioType>(
            value: _type,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: [
              for (final t in CardioType.values)
                DropdownMenuItem(value: t, child: Text(t.label)),
            ],
            onChanged: (t) => setState(() => _type = t ?? _type),
          ),
          const SizedBox(height: AppSpacing.m),
          VisTextField(
            label: 'Tempo (minutos)',
            controller: _minutes,
            keyboardType: TextInputType.number,
          ),
          if (_type.distanceBased) ...[
            const SizedBox(height: AppSpacing.m),
            VisTextField(
              label: 'Distância (km)',
              controller: _distance,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          VisTextField(
            label: 'Calorias (opcional)',
            controller: _calories,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.m),
          VisTextField(label: 'Observação (opcional)', controller: _note),
          const SizedBox(height: AppSpacing.l),
          PrimaryButton(label: 'Salvar', isLoading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
