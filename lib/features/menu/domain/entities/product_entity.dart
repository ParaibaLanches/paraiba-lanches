import 'category_entity.dart';
import 'ingredient_entity.dart';

class ProductEntity {
  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final CategoryEntity? category;
  final String imageUrl;
  final bool isFeatured;
  final String featuredSlot;
  final String promotionLabel;
  final List<IngredientEntity> ingredients;
  final double? discountPercentage;
  final double? promotionalPrice;
  final bool available;

  const ProductEntity({
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
}
