import 'package:flutter/material.dart';
import '../../../features/menu/domain/entities/product_entity.dart';
import '../../../models/merchandising_section.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';

class DynamicGridSection extends StatelessWidget {
  final MerchandisingSection section;
  final Function(ProductEntity, GlobalKey) onAddTap;

  const DynamicGridSection({
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
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 240, // Altura fixa para os cards verticais
          ),
          itemCount: section.products.length,
          itemBuilder: (context, index) {
            final product = section.products[index];
            return ProductCard(
              product: product,
              heroTag: 'section_${section.id}_grid_product_${product.id}',
              layoutType: MerchandisingLayoutType.grid,
              textColor: section.titleColor == 'white'
                  ? Colors.white
                  : (section.titleColor == 'primary'
                        ? AppColors.primary
                        : null),
              onAddTap: (key) => onAddTap(product, key),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
