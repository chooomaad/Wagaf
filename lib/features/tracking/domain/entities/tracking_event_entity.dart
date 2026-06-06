import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracking_event_entity.freezed.dart';
part 'tracking_event_entity.g.dart';

@freezed
class TrackingEventEntity with _$TrackingEventEntity {
  const factory TrackingEventEntity({
    required String id,
    required String orderId,
    required String status,
    required String title,
    String? description,
    String? location,
    String? createdBy,
    required DateTime createdAt,
  }) = _TrackingEventEntity;

  factory TrackingEventEntity.fromJson(Map<String, dynamic> json) =>
      _$TrackingEventEntityFromJson(json);
}
