import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../controllers/providers.dart'; // For apiServiceProvider
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/menu_remote_data_source.dart';
import '../../data/repositories/menu_repository_impl.dart';
import '../../domain/repositories/i_menu_repository.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_menu_usecase.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../controllers/menu_controller.dart';

// Data Sources
final menuRemoteDataSourceProvider = Provider<IMenuRemoteDataSource>((ref) {
  return MenuRemoteDataSource(ref.read(apiServiceProvider));
});

// Repositories
final menuRepositoryProvider = Provider<IMenuRepository>((ref) {
  return MenuRepositoryImpl(ref.read(menuRemoteDataSourceProvider));
});

// Use Cases
final getMenuUseCaseProvider = Provider<GetMenuUseCase>((ref) {
  return GetMenuUseCase(ref.read(menuRepositoryProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.read(menuRepositoryProvider));
});

// Presentation Providers
final menuProvider = FutureProvider<List<ProductEntity>>((ref) async {
  final usecase = ref.read(getMenuUseCaseProvider);
  final result = await usecase(const NoParams());
  return result.fold(
    onFailure: (f) => throw Exception(f.message),
    onSuccess: (products) => products,
  );
});

final categoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final usecase = ref.read(getCategoriesUseCaseProvider);
  final result = await usecase(const NoParams());
  return result.fold(
    onFailure: (f) => throw Exception(f.message),
    onSuccess: (categories) => categories,
  );
});

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, int?>(
      SelectedCategoryNotifier.new,
    );
