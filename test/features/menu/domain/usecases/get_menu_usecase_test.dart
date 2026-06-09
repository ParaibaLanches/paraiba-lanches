import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paraiba_lanches/core/errors/failures.dart';
import 'package:paraiba_lanches/core/usecases/usecase.dart';
import 'package:paraiba_lanches/features/menu/domain/entities/product_entity.dart';
import 'package:paraiba_lanches/features/menu/domain/repositories/i_menu_repository.dart';
import 'package:paraiba_lanches/features/menu/domain/usecases/get_menu_usecase.dart';

class MockMenuRepository extends Mock implements IMenuRepository {}

void main() {
  late GetMenuUseCase usecase;
  late MockMenuRepository mockRepository;

  setUp(() {
    mockRepository = MockMenuRepository();
    usecase = GetMenuUseCase(mockRepository);
  });

  final tProductList = [
    ProductEntity(id: 1, name: 'Burger', price: 10.0, categoryId: 1),
    ProductEntity(id: 2, name: 'Fries', price: 5.0, categoryId: 2),
  ];

  test('should get menu from the repository', () async {
    // arrange
    when(() => mockRepository.getMenu())
        .thenAnswer((_) async => Result.success(tProductList));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result.isSuccess, true);
    expect(result.value, tProductList);
    verify(() => mockRepository.getMenu());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    when(() => mockRepository.getMenu())
        .thenAnswer((_) async => Result.failure(const ServerFailure()));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result.isFailure, true);
    expect(result.failure, isA<ServerFailure>());
    verify(() => mockRepository.getMenu());
    verifyNoMoreInteractions(mockRepository);
  });
}
