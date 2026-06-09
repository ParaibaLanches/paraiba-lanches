import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paraiba_lanches/core/errors/failures.dart';
import 'package:paraiba_lanches/core/usecases/usecase.dart';
import 'package:paraiba_lanches/features/orders/domain/entities/order_entity.dart';
import 'package:paraiba_lanches/features/orders/domain/repositories/i_order_repository.dart';
import 'package:paraiba_lanches/features/orders/domain/usecases/get_my_orders_usecase.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  late GetMyOrdersUseCase usecase;
  late MockOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockOrderRepository();
    usecase = GetMyOrdersUseCase(mockRepository);
  });

  final tOrderList = [
    OrderEntity(
      id: 1,
      code: 'PED-001',
      status: 'pending',
      subtotal: 50.0,
      deliveryFee: 5.0,
      discount: 0.0,
      total: 55.0,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      orderType: 'delivery',
      items: const [],
      payments: const [],
    )
  ];

  test('should get orders from the repository', () async {
    // arrange
    when(() => mockRepository.getMyOrders())
        .thenAnswer((_) async => Result.success(tOrderList));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result.isSuccess, true);
    expect(result.value, tOrderList);
    verify(() => mockRepository.getMyOrders());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    when(() => mockRepository.getMyOrders())
        .thenAnswer((_) async => Result.failure(const ServerFailure()));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result.isFailure, true);
    expect(result.failure, isA<ServerFailure>());
    verify(() => mockRepository.getMyOrders());
    verifyNoMoreInteractions(mockRepository);
  });
}
