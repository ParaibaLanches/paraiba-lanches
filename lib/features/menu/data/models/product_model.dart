import '../../domain/entities/product_entity.dart';
import 'category_model.dart';
import 'ingredient_model.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    super.description = '',
    required super.price,
    required super.categoryId,
    super.category,
    super.imageUrl = '',
    super.isFeatured = false,
    super.featuredSlot = 'none',
    super.promotionLabel = '',
    super.ingredients = const [],
    super.discountPercentage,
    super.promotionalPrice,
    super.available = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        categoryId: (json['category_id'] ?? json['categoryId']) as int,
        category: json['category'] != null
            ? CategoryModel.fromJson(json['category'])
            : null,
        imageUrl: (json['image_url'] ?? json['imageUrl']) as String? ?? '',
        isFeatured: (json['is_featured'] ?? json['isFeatured']) as bool? ?? false,
        featuredSlot: (json['featured_slot'] ?? json['featuredSlot']) as String? ?? 'none',
        promotionLabel: (json['promotion_label'] ?? json['promotionLabel']) as String? ?? '',
        ingredients: (json['ingredients'] is List)
            ? (json['ingredients'] as List)
                .map((i) => IngredientModel.fromJson(i))
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'category': category != null ? (category as CategoryModel).toJson() : null,
        'image_url': imageUrl,
        'is_featured': isFeatured,
        'featured_slot': featuredSlot,
        'promotion_label': promotionLabel,
        'ingredients': ingredients.map((i) => (i as IngredientModel).toJson()).toList(),
        'discount_percentage': discountPercentage,
        'promotional_price': promotionalPrice,
        'available': available,
      };
}
