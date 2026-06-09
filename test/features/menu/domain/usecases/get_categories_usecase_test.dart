import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paraiba_lanches/core/errors/failures.dart';
import 'package:paraiba_lanches/core/usecases/usecase.dart';
import 'package:paraiba_lanches/features/menu/domain/entities/category_entity.dart';
import 'package:paraiba_lanches/features/menu/domain/repositories/i_menu_repository.dart';
import 'package:paraiba_lanches/features/menu/domain/usecases/get_categories_usecase.dart';

class MockMenuRepository extends Mock implements IMenuRepository {}

void main() {
  late GetCategoriesUseCase usecase;
  late MockMenuRepository mockRepository;

  setUp(() {
    mockRepository = MockMenuRepository();
    usecase = GetCategoriesUseCase(mockRepository);
  });

  final tCategoryList = [
    CategoryEntity(id: 1, name: 'Lanches'),
    CategoryEntity(id: 2, name: 'Bebidas'),
  ];

  test('should get categories from the repository', () async {
    // arrange
    when(() => mockRepository.getCategories())
        .thenAnswer((_) async => Result.success(tCategoryList));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result.isSuccess, true);
    expect(result.value, tCategoryList);
    verify(() => mockRepository.getCategories());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    when(() => mockRepository.getCategories())
        .thenAnswer((_) async => Result.failure(const ServerFailure()));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result.isFailure, true);
    expect(result.failure, isA<ServerFailure>());
    verify(() => mockRepository.getCategories());
    verifyNoMoreInteractions(mockRepository);
  });
}
