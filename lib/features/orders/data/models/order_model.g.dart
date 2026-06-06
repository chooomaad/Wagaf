// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually patched to use snake_case keys matching Supabase column names.

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderModelImpl _$$OrderModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderModelImpl(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      productUrl: json['product_url'] as String? ?? '',
      platform: json['platform'] as String? ?? 'other',
      productTitle: json['product_title'] as String? ?? '',
      productImage: json['product_image'] as String?,
      productPrice: (json['product_price'] as num?)?.toDouble() ?? 0.0,
      productCurrency: json['product_currency'] as String? ?? 'USD',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      productPriceMru: (json['product_price_mru'] as num?)?.toDouble() ?? 0.0,
      shippingFeeMru: (json['shipping_fee_mru'] as num?)?.toDouble() ?? 0.0,
      serviceFeeMru: (json['service_fee_mru'] as num?)?.toDouble() ?? 0.0,
      totalMru: (json['total_mru'] as num?)?.toDouble() ?? 0.0,
      adminNotes: json['admin_notes'] as String?,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      trackingNumber: json['tracking_number'] as String?,
      carrier: json['carrier'] as String?,
      trackingEvents: (json['tracking_events'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      payments: (json['payments'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
      purchasedAt: json['purchased_at'] == null
          ? null
          : DateTime.parse(json['purchased_at'] as String),
      shippedAt: json['shipped_at'] == null
          ? null
          : DateTime.parse(json['shipped_at'] as String),
      arrivedAt: json['arrived_at'] == null
          ? null
          : DateTime.parse(json['arrived_at'] as String),
      deliveredAt: json['delivered_at'] == null
          ? null
          : DateTime.parse(json['delivered_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$OrderModelImplToJson(_$OrderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'user_id': instance.userId,
      'status': instance.status,
      'product_url': instance.productUrl,
      'platform': instance.platform,
      'product_title': instance.productTitle,
      'product_image': instance.productImage,
      'product_price': instance.productPrice,
      'product_currency': instance.productCurrency,
      'quantity': instance.quantity,
      'product_price_mru': instance.productPriceMru,
      'shipping_fee_mru': instance.shippingFeeMru,
      'service_fee_mru': instance.serviceFeeMru,
      'total_mru': instance.totalMru,
      'admin_notes': instance.adminNotes,
      'weight_kg': instance.weightKg,
      'tracking_number': instance.trackingNumber,
      'carrier': instance.carrier,
      'tracking_events': instance.trackingEvents,
      'payments': instance.payments,
      'paid_at': instance.paidAt?.toIso8601String(),
      'purchased_at': instance.purchasedAt?.toIso8601String(),
      'shipped_at': instance.shippedAt?.toIso8601String(),
      'arrived_at': instance.arrivedAt?.toIso8601String(),
      'delivered_at': instance.deliveredAt?.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
