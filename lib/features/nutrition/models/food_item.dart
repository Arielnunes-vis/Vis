import '../domain/nutrition_enums.dart';
import 'macro_nutrients.dart';

/// Item de alimento dentro de uma refeição (PROMPT 10).
///
/// [macros] representa o total já correspondente à [quantity] informada.
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.macros,
    this.category,
  });

  final String id;
  final String name;
  final double quantity;
  final MeasureUnit unit;
  final MacroNutrients macros;
  final String? category;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit.name,
        'category': category,
        'macros': macros.toMap(),
      };

  factory FoodItem.fromMap(Map<String, dynamic> m) => FoodItem(
        id: m['id'] as String,
        name: (m['name'] ?? '') as String,
        quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
        unit: MeasureUnit.fromName(m['unit'] as String?),
        category: m['category'] as String?,
        macros: MacroNutrients.fromMap(
            Map<String, dynamic>.from(m['macros'] as Map? ?? {})),
      );
}
