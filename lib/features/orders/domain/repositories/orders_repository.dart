import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<Either<Failure, List<OrderEntity>>> getUserOrders(String userId);
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);
  Future<Either<Failure, OrderEntity>> createOrder(Map<String, dynamic> data);
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    String orderId,
    String status, {
    String? adminNotes,
  });
  Future<Either<Failure, OrderEntity>> updateOrderDetails(
    String orderId, {
    String? adminNotes,
    double? weightKg,
    double? shippingFeeMru,
    double? serviceFeeMru,
    double? totalMru,
  });
  Future<Either<Failure, List<OrderEntity>>> getAllOrders({
    int page = 0,
    int limit = 20,
  });
}
