import '../domain/nutrition_enums.dart';
import 'food_item.dart';
import 'macro_nutrients.dart';

/// Refeição registrada (PROMPT 10).
class Meal {
  const Meal({
    required this.id,
    required this.userId,
    required this.type,
    required this.consumedAt,
    this.items = const [],
    this.photoPath,
    this.note,
  });

  final String id;
  final String userId;
  final MealType type;
  final DateTime consumedAt;
  final List<FoodItem> items;
  final String? photoPath;
  final String? note;

  MacroNutrients get macros =>
      items.fold(MacroNutrients.zero, (sum, i) => sum + i.macros);

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'type': type.name,
        'photo_path': photoPath,
        'note': note,
        'consumed_at': consumedAt.toIso8601String(),
        'items': items.map((i) => i.toMap()).toList(),
      };

  factory Meal.fromMap(Map<String, dynamic> m) => Meal(
        id: m['id'] as String,
        userId: (m['user_id'] ?? '') as String,
        type: MealType.fromName(m['type'] as String?),
        photoPath: m['photo_path'] as String?,
        note: m['note'] as String?,
        consumedAt: DateTime.parse(m['consumed_at'] as String),
        items: (m['items'] as List? ?? [])
            .map((e) => FoodItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
