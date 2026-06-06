// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_event_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackingEventEntityImpl _$$TrackingEventEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$TrackingEventEntityImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TrackingEventEntityImplToJson(
        _$TrackingEventEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'status': instance.status,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
    };
