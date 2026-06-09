import '../../domain/entities/ingredient_entity.dart';

class IngredientModel extends IngredientEntity {
  const IngredientModel({
    required super.id,
    required super.name,
    super.icon = '',
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) => IngredientModel(
        id: json['id'] as int,
        name: json['name'] as String,
        icon: json['icon'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
      };
}
