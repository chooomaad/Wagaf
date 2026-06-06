// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PaymentEntity _$PaymentEntityFromJson(Map<String, dynamic> json) {
  return _PaymentEntity.fromJson(json);
}

/// @nodoc
mixin _$PaymentEntity {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get method => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;
  String? get proofUrl => throw _privateConstructorUsedError;
  String? get adminNotes => throw _privateConstructorUsedError;
  String? get validatedBy => throw _privateConstructorUsedError;
  DateTime? get validatedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PaymentEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentEntityCopyWith<PaymentEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentEntityCopyWith<$Res> {
  factory $PaymentEntityCopyWith(
          PaymentEntity value, $Res Function(PaymentEntity) then) =
      _$PaymentEntityCopyWithImpl<$Res, PaymentEntity>;
  @useResult
  $Res call(
      {String id,
      String orderId,
      String userId,
      double amount,
      String currency,
      String method,
      String status,
      String? reference,
      String? proofUrl,
      String? adminNotes,
      String? validatedBy,
      DateTime? validatedAt,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$PaymentEntityCopyWithImpl<$Res, $Val extends PaymentEntity>
    implements $PaymentEntityCopyWith<$Res> {
  _$PaymentEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? userId = null,
    Object? amount = null,
    Object? currency = null,
    Object? method = null,
    Object? status = null,
    Object? reference = freezed,
    Object? proofUrl = freezed,
    Object? adminNotes = freezed,
    Object? validatedBy = freezed,
    Object? validatedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      proofUrl: freezed == proofUrl
          ? _value.proofUrl
          : proofUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      validatedBy: freezed == validatedBy
          ? _value.validatedBy
          : validatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      validatedAt: freezed == validatedAt
          ? _value.validatedAt
          : validatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentEntityImplCopyWith<$Res>
    implements $PaymentEntityCopyWith<$Res> {
  factory _$$PaymentEntityImplCopyWith(
          _$PaymentEntityImpl value, $Res Function(_$PaymentEntityImpl) then) =
      __$$PaymentEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String orderId,
      String userId,
      double amount,
      String currency,
      String method,
      String status,
      String? reference,
      String? proofUrl,
      String? adminNotes,
      String? validatedBy,
      DateTime? validatedAt,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$PaymentEntityImplCopyWithImpl<$Res>
    extends _$PaymentEntityCopyWithImpl<$Res, _$PaymentEntityImpl>
    implements _$$PaymentEntityImplCopyWith<$Res> {
  __$$PaymentEntityImplCopyWithImpl(
      _$PaymentEntityImpl _value, $Res Function(_$PaymentEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? userId = null,
    Object? amount = null,
    Object? currency = null,
    Object? method = null,
    Object? status = null,
    Object? reference = freezed,
    Object? proofUrl = freezed,
    Object? adminNotes = freezed,
    Object? validatedBy = freezed,
    Object? validatedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$PaymentEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      proofUrl: freezed == proofUrl
          ? _value.proofUrl
          : proofUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      validatedBy: freezed == validatedBy
          ? _value.validatedBy
          : validatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      validatedAt: freezed == validatedAt
          ? _value.validatedAt
          : validatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentEntityImpl implements _PaymentEntity {
  const _$PaymentEntityImpl(
      {required this.id,
      required this.orderId,
      required this.userId,
      required this.amount,
      this.currency = 'MRU',
      this.method = 'manual',
      this.status = 'pending',
      this.reference,
      this.proofUrl,
      this.adminNotes,
      this.validatedBy,
      this.validatedAt,
      required this.createdAt,
      required this.updatedAt});

  factory _$PaymentEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String userId;
  @override
  final double amount;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  final String method;
  @override
  @JsonKey()
  final String status;
  @override
  final String? reference;
  @override
  final String? proofUrl;
  @override
  final String? adminNotes;
  @override
  final String? validatedBy;
  @override
  final DateTime? validatedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'PaymentEntity(id: $id, orderId: $orderId, userId: $userId, amount: $amount, currency: $currency, method: $method, status: $status, reference: $reference, proofUrl: $proofUrl, adminNotes: $adminNotes, validatedBy: $validatedBy, validatedAt: $validatedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.proofUrl, proofUrl) ||
                other.proofUrl == proofUrl) &&
            (identical(other.adminNotes, adminNotes) ||
                other.adminNotes == adminNotes) &&
            (identical(other.validatedBy, validatedBy) ||
                other.validatedBy == validatedBy) &&
            (identical(other.validatedAt, validatedAt) ||
                other.validatedAt == validatedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      orderId,
      userId,
      amount,
      currency,
      method,
      status,
      reference,
      proofUrl,
      adminNotes,
      validatedBy,
      validatedAt,
      createdAt,
      updatedAt);

  /// Create a copy of PaymentEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentEntityImplCopyWith<_$PaymentEntityImpl> get copyWith =>
      __$$PaymentEntityImplCopyWithImpl<_$PaymentEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentEntityImplToJson(
      this,
    );
  }
}

abstract class _PaymentEntity implements PaymentEntity {
  const factory _PaymentEntity(
      {required final String id,
      required final String orderId,
      required final String userId,
      required final double amount,
      final String currency,
      final String method,
      final String status,
      final String? reference,
      final String? proofUrl,
      final String? adminNotes,
      final String? validatedBy,
      final DateTime? validatedAt,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$PaymentEntityImpl;

  factory _PaymentEntity.fromJson(Map<String, dynamic> json) =
      _$PaymentEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get userId;
  @override
  double get amount;
  @override
  String get currency;
  @override
  String get method;
  @override
  String get status;
  @override
  String? get reference;
  @override
  String? get proofUrl;
  @override
  String? get adminNotes;
  @override
  String? get validatedBy;
  @override
  DateTime? get validatedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of PaymentEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentEntityImplCopyWith<_$PaymentEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
