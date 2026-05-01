import 'ingredient.dart';

class Category {
  final int id;
  final String name;
  final String description;

  Category({required this.id, required this.name, this.description = ''});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
  );
}

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final Category? category;
  final String imageUrl;
  final bool isFeatured;
  final String featuredSlot;
  final String promotionLabel;
  final List<Ingredient> ingredients;
  final double? discountPercentage;
  final double? promotionalPrice;
  final bool available;

  Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.categoryId,
    this.category,
    this.imageUrl = '',
    this.isFeatured = false,
    this.featuredSlot = 'none',
    this.promotionLabel = '',
    this.ingredients = const [],
    this.discountPercentage,
    this.promotionalPrice,
    this.available = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    price: (json['price'] as num).toDouble(),
    categoryId: json['category_id'] as int,
    category: json['category'] != null
        ? Category.fromJson(json['category'])
        : null,
    imageUrl: json['image_url'] as String? ?? '',
    isFeatured: json['is_featured'] as bool? ?? false,
    featuredSlot: json['featured_slot'] as String? ?? 'none',
    promotionLabel: json['promotion_label'] as String? ?? '',
    ingredients: json['ingredients'] != null
        ? (json['ingredients'] as List)
              .map((i) => Ingredient.fromJson(i))
              .toList()
        : [],
    discountPercentage: json['discount_percentage'] != null
        ? (json['discount_percentage'] as num).toDouble()
        : null,
    promotionalPrice: json['promotional_price'] != null
        ? (json['promotional_price'] as num).toDouble()
        : null,
    available: json['available'] as bool? ?? true,
  );
}
