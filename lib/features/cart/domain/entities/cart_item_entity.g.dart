// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartItemEntityImpl _$$CartItemEntityImplFromJson(Map<String, dynamic> json) =>
    _$CartItemEntityImpl(
      id: json['id'] as String,
      product: ProductEntity.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      shippingFeeMru: (json['shippingFeeMru'] as num?)?.toDouble(),
      serviceFeeMru: (json['serviceFeeMru'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$CartItemEntityImplToJson(
        _$CartItemEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'quantity': instance.quantity,
      'shippingFeeMru': instance.shippingFeeMru,
      'serviceFeeMru': instance.serviceFeeMru,
    };
