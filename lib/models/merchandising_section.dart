import 'product.dart';

enum MerchandisingLayoutType { hero, bento, horizontalList, grid, custom }

class MerchandisingSection {
  final int id;
  final String title;
  final String subtitle;
  final MerchandisingLayoutType layoutType;
  final bool fixedLayout;
  final String customStyles;
  final int orderIndex;
  final bool active;
  final String titleColor;
  final List<Product> products;

  MerchandisingSection({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.layoutType,
    this.fixedLayout = true,
    this.customStyles = '',
    this.orderIndex = 0,
    this.active = true,
    this.titleColor = 'black',
    required this.products,
  });

  factory MerchandisingSection.fromJson(Map<String, dynamic> json) {
    // Mapping string layout types from API to Enum
    final layoutStr = json['layout_type'] as String? ?? 'horizontal_list';
    MerchandisingLayoutType type;
    switch (layoutStr) {
      case 'hero':
        type = MerchandisingLayoutType.hero;
        break;
      case 'bento':
        type = MerchandisingLayoutType.bento;
        break;
      case 'grid':
        type = MerchandisingLayoutType.grid;
        break;
      case 'custom':
        type = MerchandisingLayoutType.custom;
        break;
      case 'horizontal_list':
      default:
        type = MerchandisingLayoutType.horizontalList;
    }

    return MerchandisingSection(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      layoutType: type,
      fixedLayout: json['fixed_layout'] as bool? ?? true,
      customStyles: json['custom_styles'] as String? ?? '',
      orderIndex: json['order_index'] as int? ?? 0,
      active: json['active'] as bool? ?? true,
      titleColor: json['title_color'] as String? ?? 'black',
      products: (json['products'] is List ? json['products'] as List : [])
          .map((p) => Product.fromJson(p))
          .toList(),
    );
  }
}
