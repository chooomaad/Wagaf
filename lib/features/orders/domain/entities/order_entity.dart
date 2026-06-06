import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../tracking/domain/entities/tracking_event_entity.dart';
import '../../../payments/domain/entities/payment_entity.dart';

part 'order_entity.freezed.dart';
part 'order_entity.g.dart';

@freezed
class OrderEntity with _$OrderEntity {
  const factory OrderEntity({
    required String id,
    required String orderNumber,
    required String userId,
    @Default('pending') String status,
    required String productUrl,
    required String platform,
    required String productTitle,
    String? productImage,
    required double productPrice,
    @Default('USD') String productCurrency,
    @Default(1) int quantity,
    required double productPriceMru,
    required double shippingFeeMru,
    required double serviceFeeMru,
    required double totalMru,
    String? adminNotes,
    double? weightKg,
    String? trackingNumber,
    String? carrier,
    @Default([]) List<TrackingEventEntity> trackingEvents,
    @Default([]) List<PaymentEntity> payments,
    DateTime? paidAt,
    DateTime? purchasedAt,
    DateTime? shippedAt,
    DateTime? arrivedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _OrderEntity;

  factory OrderEntity.fromJson(Map<String, dynamic> json) =>
      _$OrderEntityFromJson(json);
}
