import 'package:flutter/material.dart';
import '../../../models/product.dart';
import '../../../models/merchandising_section.dart';
import 'dynamic_bento_section.dart';
import 'dynamic_carousel_section.dart';
import 'dynamic_hero_section.dart';

class SectionFactory extends StatelessWidget {
  final MerchandisingSection section;
  final Function(Product) onAddTap;

  const SectionFactory({
    super.key,
    required this.section,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!section.active || section.products.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (section.layoutType) {
      case MerchandisingLayoutType.hero:
        return DynamicHeroSection(section: section, onAddTap: onAddTap);
      case MerchandisingLayoutType.bento:
        return DynamicBentoSection(section: section, onAddTap: onAddTap);
      case MerchandisingLayoutType.grid:
      case MerchandisingLayoutType.horizontalList:
        return DynamicCarouselSection(section: section, onAddTap: onAddTap);
      default:
        // Fallback para lista horizontal se o tipo for desconhecido
        return DynamicCarouselSection(section: section, onAddTap: onAddTap);
    }
  }
}
