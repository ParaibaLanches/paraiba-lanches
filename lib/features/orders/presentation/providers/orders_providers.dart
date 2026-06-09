import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../controllers/providers.dart'; // To get apiServiceProvider
import '../../data/datasources/order_remote_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../../domain/usecases/calculate_delivery_fee_usecase.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_my_orders_usecase.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import '../controllers/orders_controller.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../services/websocket_service.dart';

// Data Sources
final orderRemoteDataSourceProvider = Provider<IOrderRemoteDataSource>((ref) {
  return OrderRemoteDataSource(ref.read(apiServiceProvider));
});

// Repositories
final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  return OrderRepositoryImpl(ref.read(orderRemoteDataSourceProvider));
});

// Use Cases
final getMyOrdersUseCaseProvider = Provider<GetMyOrdersUseCase>((ref) {
  return GetMyOrdersUseCase(ref.read(orderRepositoryProvider));
});

final getOrderByIdUseCaseProvider = Provider<GetOrderByIdUseCase>((ref) {
  return GetOrderByIdUseCase(ref.read(orderRepositoryProvider));
});

final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  return CreateOrderUseCase(ref.read(orderRepositoryProvider));
});

final calculateDeliveryFeeUseCaseProvider = Provider<CalculateDeliveryFeeUseCase>((ref) {
  return CalculateDeliveryFeeUseCase(ref.read(orderRepositoryProvider));
});

// Presentation Providers
final wsConnectionStatusProvider = NotifierProvider<WsStatusNotifier, WsConnectionStatus>(
  WsStatusNotifier.new,
);

final orderEventsProvider = StreamProvider<dynamic>((ref) {
  // We keep the old WebSocketService logic from the old providers temporarily 
  // or point to it here. Let's assume we import websocket_service from services.
  throw UnimplementedError('Handled in orders_controller.dart');
});

final myOrdersProvider = AsyncNotifierProvider<OrdersNotifier, List<OrderEntity>>(
  OrdersNotifier.new,
);

final orderDetailProvider = FutureProvider.family<OrderEntity, int>((ref, id) async {
  final usecase = ref.read(getOrderByIdUseCaseProvider);
  final result = await usecase(GetOrderByIdParams(id));
  return result.fold(
    onFailure: (failure) => throw Exception(failure.message),
    onSuccess: (order) => order,
  );
});
