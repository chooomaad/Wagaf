import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

enum OrdersStatus { idle, loading, success, error }

class OrdersState {
  final OrdersStatus status;
  final List<OrderEntity> orders;
  final OrderEntity? selectedOrder;
  final String? error;

  const OrdersState({
    this.status = OrdersStatus.idle,
    this.orders = const [],
    this.selectedOrder,
    this.error,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderEntity>? orders,
    OrderEntity? selectedOrder,
    String? error,
  }) =>
      OrdersState(
        status: status ?? this.status,
        orders: orders ?? this.orders,
        selectedOrder: selectedOrder ?? this.selectedOrder,
        error: error,
      );
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrdersRepository _repository;
  OrdersNotifier(this._repository) : super(const OrdersState());

  Future<void> loadUserOrders(String userId) async {
    state = state.copyWith(status: OrdersStatus.loading);
    final result = await _repository.getUserOrders(userId);
    result.fold(
      (failure) => state = state.copyWith(
        status: OrdersStatus.error,
        error: failure.message,
      ),
      (orders) => state = state.copyWith(
        status: OrdersStatus.success,
        orders: orders,
      ),
    );
  }

  Future<void> loadAllOrders({int page = 0}) async {
    state = state.copyWith(status: OrdersStatus.loading);
    final result = await _repository.getAllOrders(page: page);
    result.fold(
      (failure) => state = state.copyWith(
        status: OrdersStatus.error,
        error: failure.message,
      ),
      (orders) => state = state.copyWith(
        status: OrdersStatus.success,
        orders: orders,
      ),
    );
  }

  Future<bool> createOrder(Map<String, dynamic> data) async {
    final result = await _repository.createOrder(data);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (order) {
        state = state.copyWith(
          orders: [order, ...state.orders],
          selectedOrder: order,
        );
        return true;
      },
    );
  }

  Future<bool> updateStatus(String orderId, String status, {String? notes}) async {
    final result = await _repository.updateOrderStatus(
      orderId,
      status,
      adminNotes: notes,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updated) {
        final orders = state.orders
            .map((o) => o.id == orderId ? updated : o)
            .toList();
        state = state.copyWith(orders: orders, selectedOrder: updated);
        return true;
      },
    );
  }

  Future<bool> updateDetails(
    String orderId, {
    String? adminNotes,
    double? weightKg,
    double? shippingFeeMru,
    double? serviceFeeMru,
    double? totalMru,
  }) async {
    final result = await _repository.updateOrderDetails(
      orderId,
      adminNotes: adminNotes,
      weightKg: weightKg,
      shippingFeeMru: shippingFeeMru,
      serviceFeeMru: serviceFeeMru,
      totalMru: totalMru,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updated) {
        final orders =
            state.orders.map((o) => o.id == orderId ? updated : o).toList();
        state = state.copyWith(orders: orders, selectedOrder: updated);
        return true;
      },
    );
  }

  void selectOrder(OrderEntity order) {
    state = state.copyWith(selectedOrder: order);
  }
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return GetIt.instance<OrdersRepository>();
});

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(ref.watch(ordersRepositoryProvider));
});

final userOrdersProvider = FutureProvider<List<OrderEntity>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(ordersRepositoryProvider);
  final result = await repo.getUserOrders(user.id);
  return result.fold((_) => [], (orders) => orders);
});
