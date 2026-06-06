import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String orderNumber,
    required String userId,
    @Default('pending') String status,
    required String productUrl,
    @Default('other') String platform,
    required String productTitle,
    String? productImage,
    @Default(0.0) double productPrice,
    @Default('USD') String productCurrency,
    @Default(1) int quantity,
    @Default(0.0) double productPriceMru,
    @Default(0.0) double shippingFeeMru,
    @Default(0.0) double serviceFeeMru,
    @Default(0.0) double totalMru,
    String? adminNotes,
    double? weightKg,
    String? trackingNumber,
    String? carrier,
    @Default([]) List<Map<String, dynamic>> trackingEvents,
    @Default([]) List<Map<String, dynamic>> payments,
    DateTime? paidAt,
    DateTime? purchasedAt,
    DateTime? shippedAt,
    DateTime? arrivedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}
