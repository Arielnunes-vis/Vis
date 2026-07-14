import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/nutrition_enums.dart';
import '../models/food_item.dart';
import '../models/macro_nutrients.dart';
import '../providers/nutrition_providers.dart';

/// Bottom sheet de registro manual de refeição (PROMPT 10).
class AddMealSheet extends ConsumerStatefulWidget {
  const AddMealSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddMealSheet(),
    );
  }

  @override
  ConsumerState<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<AddMealSheet> {
  final Uuid _uuid = const Uuid();
  MealType _type = MealType.lunch;
  final List<FoodItem> _items = [];

  final _name = TextEditingController();
  final _qty = TextEditingController(text: '100');
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fats = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _qty, _kcal, _protein, _carbs, _fats]) {
      c.dispose();
    }
    super.dispose();
  }

  double _d(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  FoodItem? _buildItem() {
    if (_name.text.trim().isEmpty) return null;
    return FoodItem(
      id: _uuid.v4(),
      name: _name.text.trim(),
      quantity: _d(_qty),
      unit: MeasureUnit.grams,
      macros: MacroNutrients(
        calories: _d(_kcal),
        protein: _d(_protein),
        carbs: _d(_carbs),
        fats: _d(_fats),
      ),
    );
  }

  void _addItem() {
    final item = _buildItem();
    if (item == null) {
      AppSnackBar.show(context, 'Informe o nome do alimento.',
          type: SnackType.warning);
      return;
    }
    setState(() {
      _items.add(item);
      for (final c in [_name, _kcal, _protein, _carbs, _fats]) {
        c.clear();
      }
      _qty.text = '100';
    });
  }

  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    final pending = _buildItem();
    final all = [..._items, if (pending != null) pending];
    if (all.isEmpty) {
      AppSnackBar.show(context, 'Adicione ao menos um alimento.',
          type: SnackType.warning);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(nutritionControllerProvider.notifier)
          .addMeal(type: _type, items: all);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.show(context, 'Não foi possível salvar a refeição.',
          type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total =
        _items.fold(MacroNutrients.zero, (s, i) => s + i.macros);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nova refeição', style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.m),
            DropdownButtonFormField<MealType>(
              value: _type,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Refeição'),
              items: [
                for (final t in MealType.values)
                  DropdownMenuItem(value: t, child: Text(t.label)),
              ],
              onChanged: (t) => setState(() => _type = t ?? _type),
            ),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: ListView(
                children: [
                  for (final it in _items)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(it.name, style: AppTypography.body),
                      subtitle: Text(
                        '${it.macros.calories.toStringAsFixed(0)} kcal · '
                        'P ${it.macros.protein.toStringAsFixed(0)}g',
                        style: AppTypography.small,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _items.remove(it)),
                      ),
                    ),
                  VisTextField(label: 'Alimento', controller: _name),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      Expanded(child: _num('Qtd (g)', _qty)),
                      const SizedBox(width: 8),
                      Expanded(child: _num('Calorias', _kcal)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      Expanded(child: _num('Proteína', _protein)),
                      const SizedBox(width: 8),
                      Expanded(child: _num('Carbo', _carbs)),
                      const SizedBox(width: 8),
                      Expanded(child: _num('Gordura', _fats)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  SecondaryButton(
                    label: 'Adicionar item',
                    onPressed: _addItem,
                  ),
                ],
              ),
            ),
            if (_items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Total: ${total.calories.toStringAsFixed(0)} kcal · '
                  'P ${total.protein.toStringAsFixed(0)}g',
                  style: AppTypography.caption,
                ),
              ),
            PrimaryButton(
                label: 'Salvar refeição', isLoading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }

  Widget _num(String label, TextEditingController c) => VisTextField(
        label: label,
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );
}
