// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracking_event_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrackingEventEntity _$TrackingEventEntityFromJson(Map<String, dynamic> json) {
  return _TrackingEventEntity.fromJson(json);
}

/// @nodoc
mixin _$TrackingEventEntity {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TrackingEventEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrackingEventEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackingEventEntityCopyWith<TrackingEventEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackingEventEntityCopyWith<$Res> {
  factory $TrackingEventEntityCopyWith(
          TrackingEventEntity value, $Res Function(TrackingEventEntity) then) =
      _$TrackingEventEntityCopyWithImpl<$Res, TrackingEventEntity>;
  @useResult
  $Res call(
      {String id,
      String orderId,
      String status,
      String title,
      String? description,
      String? location,
      String? createdBy,
      DateTime createdAt});
}

/// @nodoc
class _$TrackingEventEntityCopyWithImpl<$Res, $Val extends TrackingEventEntity>
    implements $TrackingEventEntityCopyWith<$Res> {
  _$TrackingEventEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackingEventEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? status = null,
    Object? title = null,
    Object? description = freezed,
    Object? location = freezed,
    Object? createdBy = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrackingEventEntityImplCopyWith<$Res>
    implements $TrackingEventEntityCopyWith<$Res> {
  factory _$$TrackingEventEntityImplCopyWith(_$TrackingEventEntityImpl value,
          $Res Function(_$TrackingEventEntityImpl) then) =
      __$$TrackingEventEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String orderId,
      String status,
      String title,
      String? description,
      String? location,
      String? createdBy,
      DateTime createdAt});
}

/// @nodoc
class __$$TrackingEventEntityImplCopyWithImpl<$Res>
    extends _$TrackingEventEntityCopyWithImpl<$Res, _$TrackingEventEntityImpl>
    implements _$$TrackingEventEntityImplCopyWith<$Res> {
  __$$TrackingEventEntityImplCopyWithImpl(_$TrackingEventEntityImpl _value,
      $Res Function(_$TrackingEventEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrackingEventEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? status = null,
    Object? title = null,
    Object? description = freezed,
    Object? location = freezed,
    Object? createdBy = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$TrackingEventEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrackingEventEntityImpl implements _TrackingEventEntity {
  const _$TrackingEventEntityImpl(
      {required this.id,
      required this.orderId,
      required this.status,
      required this.title,
      this.description,
      this.location,
      this.createdBy,
      required this.createdAt});

  factory _$TrackingEventEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackingEventEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String status;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? location;
  @override
  final String? createdBy;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'TrackingEventEntity(id: $id, orderId: $orderId, status: $status, title: $title, description: $description, location: $location, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackingEventEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, orderId, status, title,
      description, location, createdBy, createdAt);

  /// Create a copy of TrackingEventEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackingEventEntityImplCopyWith<_$TrackingEventEntityImpl> get copyWith =>
      __$$TrackingEventEntityImplCopyWithImpl<_$TrackingEventEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrackingEventEntityImplToJson(
      this,
    );
  }
}

abstract class _TrackingEventEntity implements TrackingEventEntity {
  const factory _TrackingEventEntity(
      {required final String id,
      required final String orderId,
      required final String status,
      required final String title,
      final String? description,
      final String? location,
      final String? createdBy,
      required final DateTime createdAt}) = _$TrackingEventEntityImpl;

  factory _TrackingEventEntity.fromJson(Map<String, dynamic> json) =
      _$TrackingEventEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get status;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get location;
  @override
  String? get createdBy;
  @override
  DateTime get createdAt;

  /// Create a copy of TrackingEventEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackingEventEntityImplCopyWith<_$TrackingEventEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
