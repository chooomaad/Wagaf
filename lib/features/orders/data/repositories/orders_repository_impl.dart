import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';
import '../../../tracking/domain/entities/tracking_event_entity.dart';
import '../../../payments/domain/entities/payment_entity.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource dataSource;
  OrdersRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<OrderEntity>>> getUserOrders(String userId) async {
    try {
      final models = await dataSource.getUserOrders(userId);
      return Right(models.map(_toEntity).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    try {
      final model = await dataSource.getOrderById(orderId);
      return Right(_toEntity(model));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder(
    Map<String, dynamic> data,
  ) async {
    try {
      final model = await dataSource.createOrder(data);
      return Right(_toEntity(model));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    String orderId,
    String status, {
    String? adminNotes,
  }) async {
    try {
      final model = await dataSource.updateOrderStatus(
        orderId,
        status,
        adminNotes: adminNotes,
      );
      return Right(_toEntity(model));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderDetails(
    String orderId, {
    String? adminNotes,
    double? weightKg,
    double? shippingFeeMru,
    double? serviceFeeMru,
    double? totalMru,
  }) async {
    try {
      final model = await dataSource.updateOrderDetails(
        orderId,
        adminNotes: adminNotes,
        weightKg: weightKg,
        shippingFeeMru: shippingFeeMru,
        serviceFeeMru: serviceFeeMru,
        totalMru: totalMru,
      );
      return Right(_toEntity(model));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getAllOrders({
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final models = await dataSource.getAllOrders(page: page, limit: limit);
      return Right(models.map(_toEntity).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  OrderEntity _toEntity(dynamic model) {
    final json = model.toJson();
    final trackingEvents = (json['tracking_events'] as List? ?? [])
        .map((e) => TrackingEventEntity(
              id: e['id'] ?? '',
              orderId: e['order_id'] ?? '',
              status: e['status'] ?? '',
              title: e['title'] ?? '',
              description: e['description'],
              location: e['location'],
              createdBy: e['created_by'],
              createdAt: e['created_at'] != null
                  ? DateTime.parse(e['created_at'])
                  : DateTime.now(),
            ))
        .toList();

    final payments = (json['payments'] as List? ?? [])
        .map((e) => PaymentEntity(
              id: e['id'] ?? '',
              orderId: e['order_id'] ?? '',
              userId: e['user_id'] ?? '',
              amount: (e['amount'] as num?)?.toDouble() ?? 0,
              currency: e['currency'] ?? 'MRU',
              method: e['method'] ?? 'manual',
              status: e['status'] ?? 'pending',
              reference: e['reference'],
              proofUrl: e['proof_url'],
              adminNotes: e['admin_notes'],
              validatedBy: e['validated_by'],
              validatedAt: e['validated_at'] != null
                  ? DateTime.parse(e['validated_at'])
                  : null,
              createdAt: e['created_at'] != null
                  ? DateTime.parse(e['created_at'])
                  : DateTime.now(),
              updatedAt: e['updated_at'] != null
                  ? DateTime.parse(e['updated_at'])
                  : DateTime.now(),
            ))
        .toList();

    return OrderEntity(
      id: json['id'],
      orderNumber: json['order_number'],
      userId: json['user_id'],
      status: json['status'] ?? 'pending',
      productUrl: json['product_url'],
      platform: json['platform'] ?? 'other',
      productTitle: json['product_title'],
      productImage: json['product_image'],
      productPrice: (json['product_price'] as num?)?.toDouble() ?? 0,
      productCurrency: json['product_currency'] ?? 'USD',
      quantity: json['quantity'] ?? 1,
      productPriceMru: (json['product_price_mru'] as num?)?.toDouble() ?? 0,
      shippingFeeMru: (json['shipping_fee_mru'] as num?)?.toDouble() ?? 0,
      serviceFeeMru: (json['service_fee_mru'] as num?)?.toDouble() ?? 0,
      totalMru: (json['total_mru'] as num?)?.toDouble() ?? 0,
      adminNotes: json['admin_notes'],
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      trackingNumber: json['tracking_number'],
      carrier: json['carrier'],
      trackingEvents: trackingEvents,
      payments: payments,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      purchasedAt: json['purchased_at'] != null ? DateTime.parse(json['purchased_at']) : null,
      shippedAt: json['shipped_at'] != null ? DateTime.parse(json['shipped_at']) : null,
      arrivedAt: json['arrived_at'] != null ? DateTime.parse(json['arrived_at']) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }
}
