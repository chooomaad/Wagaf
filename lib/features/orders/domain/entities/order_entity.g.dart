// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderEntityImpl _$$OrderEntityImplFromJson(Map<String, dynamic> json) =>
    _$OrderEntityImpl(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String? ?? 'pending',
      productUrl: json['productUrl'] as String,
      platform: json['platform'] as String,
      productTitle: json['productTitle'] as String,
      productImage: json['productImage'] as String?,
      productPrice: (json['productPrice'] as num).toDouble(),
      productCurrency: json['productCurrency'] as String? ?? 'USD',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      productPriceMru: (json['productPriceMru'] as num).toDouble(),
      shippingFeeMru: (json['shippingFeeMru'] as num).toDouble(),
      serviceFeeMru: (json['serviceFeeMru'] as num).toDouble(),
      totalMru: (json['totalMru'] as num).toDouble(),
      adminNotes: json['adminNotes'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      trackingNumber: json['trackingNumber'] as String?,
      carrier: json['carrier'] as String?,
      trackingEvents: (json['trackingEvents'] as List<dynamic>?)
              ?.map((e) =>
                  TrackingEventEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      payments: (json['payments'] as List<dynamic>?)
              ?.map((e) => PaymentEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      purchasedAt: json['purchasedAt'] == null
          ? null
          : DateTime.parse(json['purchasedAt'] as String),
      shippedAt: json['shippedAt'] == null
          ? null
          : DateTime.parse(json['shippedAt'] as String),
      arrivedAt: json['arrivedAt'] == null
          ? null
          : DateTime.parse(json['arrivedAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$OrderEntityImplToJson(_$OrderEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'userId': instance.userId,
      'status': instance.status,
      'productUrl': instance.productUrl,
      'platform': instance.platform,
      'productTitle': instance.productTitle,
      'productImage': instance.productImage,
      'productPrice': instance.productPrice,
      'productCurrency': instance.productCurrency,
      'quantity': instance.quantity,
      'productPriceMru': instance.productPriceMru,
      'shippingFeeMru': instance.shippingFeeMru,
      'serviceFeeMru': instance.serviceFeeMru,
      'totalMru': instance.totalMru,
      'adminNotes': instance.adminNotes,
      'weightKg': instance.weightKg,
      'trackingNumber': instance.trackingNumber,
      'carrier': instance.carrier,
      'trackingEvents': instance.trackingEvents,
      'payments': instance.payments,
      'paidAt': instance.paidAt?.toIso8601String(),
      'purchasedAt': instance.purchasedAt?.toIso8601String(),
      'shippedAt': instance.shippedAt?.toIso8601String(),
      'arrivedAt': instance.arrivedAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
