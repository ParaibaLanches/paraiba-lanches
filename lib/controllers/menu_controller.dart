import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import 'providers.dart';

final menuProvider = FutureProvider<List<Product>>((ref) async {
  return ref.read(menuServiceProvider).getMenu();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.read(menuServiceProvider).getCategories();
});

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, int?>(
      SelectedCategoryNotifier.new,
    );

class SelectedCategoryNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? id) => state = id;
}
