import 'package:flutter/material.dart';
import '../../../features/menu/domain/entities/product_entity.dart';
import '../../../models/merchandising_section.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';

class DynamicCarouselSection extends StatelessWidget {
  final MerchandisingSection section;
  final Function(ProductEntity, GlobalKey) onAddTap;

  const DynamicCarouselSection({
    super.key,
    required this.section,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    if (section.products.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: section.title,
          subtitle: section.subtitle.isNotEmpty ? section.subtitle : null,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: section.products.length,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final product = section.products[index];
              return Container(
                width: 320,
                margin: const EdgeInsets.only(right: 16),
                child: ProductCard(
                  product: product,
                  heroTag: 'section_${section.id}_carousel_product_${product.id}',
                  textColor: section.titleColor == 'white'
                      ? Colors.white
                      : (section.titleColor == 'primary'
                            ? AppColors.primary
                            : null),
                  onAddTap: (key) => onAddTap(product, key),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
