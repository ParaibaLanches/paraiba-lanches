class IngredientEntity {
  final int id;
  final String name;
  final String icon;

  const IngredientEntity({
    required this.id,
    required this.name,
    this.icon = '',
  });
}
