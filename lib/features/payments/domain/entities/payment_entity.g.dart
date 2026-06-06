// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentEntityImpl _$$PaymentEntityImplFromJson(Map<String, dynamic> json) =>
    _$PaymentEntityImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'MRU',
      method: json['method'] as String? ?? 'manual',
      status: json['status'] as String? ?? 'pending',
      reference: json['reference'] as String?,
      proofUrl: json['proofUrl'] as String?,
      adminNotes: json['adminNotes'] as String?,
      validatedBy: json['validatedBy'] as String?,
      validatedAt: json['validatedAt'] == null
          ? null
          : DateTime.parse(json['validatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PaymentEntityImplToJson(_$PaymentEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'userId': instance.userId,
      'amount': instance.amount,
      'currency': instance.currency,
      'method': instance.method,
      'status': instance.status,
      'reference': instance.reference,
      'proofUrl': instance.proofUrl,
      'adminNotes': instance.adminNotes,
      'validatedBy': instance.validatedBy,
      'validatedAt': instance.validatedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
