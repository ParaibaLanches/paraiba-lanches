class Ingredient {
  final int id;
  final String name;
  final String icon;

  Ingredient({required this.id, required this.name, this.icon = ''});

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    id: json['id'] as int,
    name: json['name'] as String,
    icon: json['icon'] as String? ?? '',
  );
}
