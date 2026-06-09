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
    categoryId: (json['category_id'] ?? json['categoryId']) as int,
    category: json['category'] != null
        ? Category.fromJson(json['category'])
        : null,
    imageUrl: (json['image_url'] ?? json['imageUrl']) as String? ?? '',
    isFeatured: (json['is_featured'] ?? json['isFeatured']) as bool? ?? false,
    featuredSlot: (json['featured_slot'] ?? json['featuredSlot']) as String? ?? 'none',
    promotionLabel: (json['promotion_label'] ?? json['promotionLabel']) as String? ?? '',
    ingredients: (json['ingredients'] is List)
        ? (json['ingredients'] as List)
              .map((i) => Ingredient.fromJson(i))
              .toList()
        : [],
    discountPercentage: (json['discount_percentage'] ?? json['discountPercentage']) != null
        ? ((json['discount_percentage'] ?? json['discountPercentage']) as num).toDouble()
        : null,
    promotionalPrice: (json['promotional_price'] ?? json['promotionalPrice']) != null
        ? ((json['promotional_price'] ?? json['promotionalPrice']) as num).toDouble()
        : null,
    available: json['available'] as bool? ?? true,
  );
}
