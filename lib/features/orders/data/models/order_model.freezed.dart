// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) {
  return _OrderModel.fromJson(json);
}

/// @nodoc
mixin _$OrderModel {
  String get id => throw _privateConstructorUsedError;
  String get orderNumber => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get productUrl => throw _privateConstructorUsedError;
  String get platform => throw _privateConstructorUsedError;
  String get productTitle => throw _privateConstructorUsedError;
  String? get productImage => throw _privateConstructorUsedError;
  double get productPrice => throw _privateConstructorUsedError;
  String get productCurrency => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get productPriceMru => throw _privateConstructorUsedError;
  double get shippingFeeMru => throw _privateConstructorUsedError;
  double get serviceFeeMru => throw _privateConstructorUsedError;
  double get totalMru => throw _privateConstructorUsedError;
  String? get adminNotes => throw _privateConstructorUsedError;
  double? get weightKg => throw _privateConstructorUsedError;
  String? get trackingNumber => throw _privateConstructorUsedError;
  String? get carrier => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get trackingEvents =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get payments => throw _privateConstructorUsedError;
  DateTime? get paidAt => throw _privateConstructorUsedError;
  DateTime? get purchasedAt => throw _privateConstructorUsedError;
  DateTime? get shippedAt => throw _privateConstructorUsedError;
  DateTime? get arrivedAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
          OrderModel value, $Res Function(OrderModel) then) =
      _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call(
      {String id,
      String orderNumber,
      String userId,
      String status,
      String productUrl,
      String platform,
      String productTitle,
      String? productImage,
      double productPrice,
      String productCurrency,
      int quantity,
      double productPriceMru,
      double shippingFeeMru,
      double serviceFeeMru,
      double totalMru,
      String? adminNotes,
      double? weightKg,
      String? trackingNumber,
      String? carrier,
      List<Map<String, dynamic>> trackingEvents,
      List<Map<String, dynamic>> payments,
      DateTime? paidAt,
      DateTime? purchasedAt,
      DateTime? shippedAt,
      DateTime? arrivedAt,
      DateTime? deliveredAt,
      DateTime? cancelledAt,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? userId = null,
    Object? status = null,
    Object? productUrl = null,
    Object? platform = null,
    Object? productTitle = null,
    Object? productImage = freezed,
    Object? productPrice = null,
    Object? productCurrency = null,
    Object? quantity = null,
    Object? productPriceMru = null,
    Object? shippingFeeMru = null,
    Object? serviceFeeMru = null,
    Object? totalMru = null,
    Object? adminNotes = freezed,
    Object? weightKg = freezed,
    Object? trackingNumber = freezed,
    Object? carrier = freezed,
    Object? trackingEvents = null,
    Object? payments = null,
    Object? paidAt = freezed,
    Object? purchasedAt = freezed,
    Object? shippedAt = freezed,
    Object? arrivedAt = freezed,
    Object? deliveredAt = freezed,
    Object? cancelledAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      productUrl: null == productUrl
          ? _value.productUrl
          : productUrl // ignore: cast_nullable_to_non_nullable
              as String,
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      productTitle: null == productTitle
          ? _value.productTitle
          : productTitle // ignore: cast_nullable_to_non_nullable
              as String,
      productImage: freezed == productImage
          ? _value.productImage
          : productImage // ignore: cast_nullable_to_non_nullable
              as String?,
      productPrice: null == productPrice
          ? _value.productPrice
          : productPrice // ignore: cast_nullable_to_non_nullable
              as double,
      productCurrency: null == productCurrency
          ? _value.productCurrency
          : productCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      productPriceMru: null == productPriceMru
          ? _value.productPriceMru
          : productPriceMru // ignore: cast_nullable_to_non_nullable
              as double,
      shippingFeeMru: null == shippingFeeMru
          ? _value.shippingFeeMru
          : shippingFeeMru // ignore: cast_nullable_to_non_nullable
              as double,
      serviceFeeMru: null == serviceFeeMru
          ? _value.serviceFeeMru
          : serviceFeeMru // ignore: cast_nullable_to_non_nullable
              as double,
      totalMru: null == totalMru
          ? _value.totalMru
          : totalMru // ignore: cast_nullable_to_non_nullable
              as double,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      trackingNumber: freezed == trackingNumber
          ? _value.trackingNumber
          : trackingNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      carrier: freezed == carrier
          ? _value.carrier
          : carrier // ignore: cast_nullable_to_non_nullable
              as String?,
      trackingEvents: null == trackingEvents
          ? _value.trackingEvents
          : trackingEvents // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      payments: null == payments
          ? _value.payments
          : payments // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      paidAt: freezed == paidAt
          ? _value.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      purchasedAt: freezed == purchasedAt
          ? _value.purchasedAt
          : purchasedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      shippedAt: freezed == shippedAt
          ? _value.shippedAt
          : shippedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      arrivedAt: freezed == arrivedAt
          ? _value.arrivedAt
          : arrivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
          _$OrderModelImpl value, $Res Function(_$OrderModelImpl) then) =
      __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String orderNumber,
      String userId,
      String status,
      String productUrl,
      String platform,
      String productTitle,
      String? productImage,
      double productPrice,
      String productCurrency,
      int quantity,
      double productPriceMru,
      double shippingFeeMru,
      double serviceFeeMru,
      double totalMru,
      String? adminNotes,
      double? weightKg,
      String? trackingNumber,
      String? carrier,
      List<Map<String, dynamic>> trackingEvents,
      List<Map<String, dynamic>> payments,
      DateTime? paidAt,
      DateTime? purchasedAt,
      DateTime? shippedAt,
      DateTime? arrivedAt,
      DateTime? deliveredAt,
      DateTime? cancelledAt,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
      _$OrderModelImpl _value, $Res Function(_$OrderModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? userId = null,
    Object? status = null,
    Object? productUrl = null,
    Object? platform = null,
    Object? productTitle = null,
    Object? productImage = freezed,
    Object? productPrice = null,
    Object? productCurrency = null,
    Object? quantity = null,
    Object? productPriceMru = null,
    Object? shippingFeeMru = null,
    Object? serviceFeeMru = null,
    Object? totalMru = null,
    Object? adminNotes = freezed,
    Object? weightKg = freezed,
    Object? trackingNumber = freezed,
    Object? carrier = freezed,
    Object? trackingEvents = null,
    Object? payments = null,
    Object? paidAt = freezed,
    Object? purchasedAt = freezed,
    Object? shippedAt = freezed,
    Object? arrivedAt = freezed,
    Object? deliveredAt = freezed,
    Object? cancelledAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$OrderModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      productUrl: null == productUrl
          ? _value.productUrl
          : productUrl // ignore: cast_nullable_to_non_nullable
              as String,
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      productTitle: null == productTitle
          ? _value.productTitle
          : productTitle // ignore: cast_nullable_to_non_nullable
              as String,
      productImage: freezed == productImage
          ? _value.productImage
          : productImage // ignore: cast_nullable_to_non_nullable
              as String?,
      productPrice: null == productPrice
          ? _value.productPrice
          : productPrice // ignore: cast_nullable_to_non_nullable
              as double,
      productCurrency: null == productCurrency
          ? _value.productCurrency
          : productCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      productPriceMru: null == productPriceMru
          ? _value.productPriceMru
          : productPriceMru // ignore: cast_nullable_to_non_nullable
              as double,
      shippingFeeMru: null == shippingFeeMru
          ? _value.shippingFeeMru
          : shippingFeeMru // ignore: cast_nullable_to_non_nullable
              as double,
      serviceFeeMru: null == serviceFeeMru
          ? _value.serviceFeeMru
          : serviceFeeMru // ignore: cast_nullable_to_non_nullable
              as double,
      totalMru: null == totalMru
          ? _value.totalMru
          : totalMru // ignore: cast_nullable_to_non_nullable
              as double,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      trackingNumber: freezed == trackingNumber
          ? _value.trackingNumber
          : trackingNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      carrier: freezed == carrier
          ? _value.carrier
          : carrier // ignore: cast_nullable_to_non_nullable
              as String?,
      trackingEvents: null == trackingEvents
          ? _value._trackingEvents
          : trackingEvents // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      payments: null == payments
          ? _value._payments
          : payments // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      paidAt: freezed == paidAt
          ? _value.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      purchasedAt: freezed == purchasedAt
          ? _value.purchasedAt
          : purchasedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      shippedAt: freezed == shippedAt
          ? _value.shippedAt
          : shippedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      arrivedAt: freezed == arrivedAt
          ? _value.arrivedAt
          : arrivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderModelImpl implements _OrderModel {
  const _$OrderModelImpl(
      {required this.id,
      required this.orderNumber,
      required this.userId,
      this.status = 'pending',
      required this.productUrl,
      this.platform = 'other',
      required this.productTitle,
      this.productImage,
      this.productPrice = 0.0,
      this.productCurrency = 'USD',
      this.quantity = 1,
      this.productPriceMru = 0.0,
      this.shippingFeeMru = 0.0,
      this.serviceFeeMru = 0.0,
      this.totalMru = 0.0,
      this.adminNotes,
      this.weightKg,
      this.trackingNumber,
      this.carrier,
      final List<Map<String, dynamic>> trackingEvents = const [],
      final List<Map<String, dynamic>> payments = const [],
      this.paidAt,
      this.purchasedAt,
      this.shippedAt,
      this.arrivedAt,
      this.deliveredAt,
      this.cancelledAt,
      this.createdAt,
      this.updatedAt})
      : _trackingEvents = trackingEvents,
        _payments = payments;

  factory _$OrderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderNumber;
  @override
  final String userId;
  @override
  @JsonKey()
  final String status;
  @override
  final String productUrl;
  @override
  @JsonKey()
  final String platform;
  @override
  final String productTitle;
  @override
  final String? productImage;
  @override
  @JsonKey()
  final double productPrice;
  @override
  @JsonKey()
  final String productCurrency;
  @override
  @JsonKey()
  final int quantity;
  @override
  @JsonKey()
  final double productPriceMru;
  @override
  @JsonKey()
  final double shippingFeeMru;
  @override
  @JsonKey()
  final double serviceFeeMru;
  @override
  @JsonKey()
  final double totalMru;
  @override
  final String? adminNotes;
  @override
  final double? weightKg;
  @override
  final String? trackingNumber;
  @override
  final String? carrier;
  final List<Map<String, dynamic>> _trackingEvents;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get trackingEvents {
    if (_trackingEvents is EqualUnmodifiableListView) return _trackingEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trackingEvents);
  }

  final List<Map<String, dynamic>> _payments;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get payments {
    if (_payments is EqualUnmodifiableListView) return _payments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_payments);
  }

  @override
  final DateTime? paidAt;
  @override
  final DateTime? purchasedAt;
  @override
  final DateTime? shippedAt;
  @override
  final DateTime? arrivedAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime? cancelledAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'OrderModel(id: $id, orderNumber: $orderNumber, userId: $userId, status: $status, productUrl: $productUrl, platform: $platform, productTitle: $productTitle, productImage: $productImage, productPrice: $productPrice, productCurrency: $productCurrency, quantity: $quantity, productPriceMru: $productPriceMru, shippingFeeMru: $shippingFeeMru, serviceFeeMru: $serviceFeeMru, totalMru: $totalMru, adminNotes: $adminNotes, weightKg: $weightKg, trackingNumber: $trackingNumber, carrier: $carrier, trackingEvents: $trackingEvents, payments: $payments, paidAt: $paidAt, purchasedAt: $purchasedAt, shippedAt: $shippedAt, arrivedAt: $arrivedAt, deliveredAt: $deliveredAt, cancelledAt: $cancelledAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.productUrl, productUrl) ||
                other.productUrl == productUrl) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.productTitle, productTitle) ||
                other.productTitle == productTitle) &&
            (identical(other.productImage, productImage) ||
                other.productImage == productImage) &&
            (identical(other.productPrice, productPrice) ||
                other.productPrice == productPrice) &&
            (identical(other.productCurrency, productCurrency) ||
                other.productCurrency == productCurrency) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.productPriceMru, productPriceMru) ||
                other.productPriceMru == productPriceMru) &&
            (identical(other.shippingFeeMru, shippingFeeMru) ||
                other.shippingFeeMru == shippingFeeMru) &&
            (identical(other.serviceFeeMru, serviceFeeMru) ||
                other.serviceFeeMru == serviceFeeMru) &&
            (identical(other.totalMru, totalMru) ||
                other.totalMru == totalMru) &&
            (identical(other.adminNotes, adminNotes) ||
                other.adminNotes == adminNotes) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.trackingNumber, trackingNumber) ||
                other.trackingNumber == trackingNumber) &&
            (identical(other.carrier, carrier) || other.carrier == carrier) &&
            const DeepCollectionEquality()
                .equals(other._trackingEvents, _trackingEvents) &&
            const DeepCollectionEquality().equals(other._payments, _payments) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.purchasedAt, purchasedAt) ||
                other.purchasedAt == purchasedAt) &&
            (identical(other.shippedAt, shippedAt) ||
                other.shippedAt == shippedAt) &&
            (identical(other.arrivedAt, arrivedAt) ||
                other.arrivedAt == arrivedAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        orderNumber,
        userId,
        status,
        productUrl,
        platform,
        productTitle,
        productImage,
        productPrice,
        productCurrency,
        quantity,
        productPriceMru,
        shippingFeeMru,
        serviceFeeMru,
        totalMru,
        adminNotes,
        weightKg,
        trackingNumber,
        carrier,
        const DeepCollectionEquality().hash(_trackingEvents),
        const DeepCollectionEquality().hash(_payments),
        paidAt,
        purchasedAt,
        shippedAt,
        arrivedAt,
        deliveredAt,
        cancelledAt,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderModelImplToJson(
      this,
    );
  }
}

abstract class _OrderModel implements OrderModel {
  const factory _OrderModel(
      {required final String id,
      required final String orderNumber,
      required final String userId,
      final String status,
      required final String productUrl,
      final String platform,
      required final String productTitle,
      final String? productImage,
      final double productPrice,
      final String productCurrency,
      final int quantity,
      final double productPriceMru,
      final double shippingFeeMru,
      final double serviceFeeMru,
      final double totalMru,
      final String? adminNotes,
      final double? weightKg,
      final String? trackingNumber,
      final String? carrier,
      final List<Map<String, dynamic>> trackingEvents,
      final List<Map<String, dynamic>> payments,
      final DateTime? paidAt,
      final DateTime? purchasedAt,
      final DateTime? shippedAt,
      final DateTime? arrivedAt,
      final DateTime? deliveredAt,
      final DateTime? cancelledAt,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$OrderModelImpl;

  factory _OrderModel.fromJson(Map<String, dynamic> json) =
      _$OrderModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderNumber;
  @override
  String get userId;
  @override
  String get status;
  @override
  String get productUrl;
  @override
  String get platform;
  @override
  String get productTitle;
  @override
  String? get productImage;
  @override
  double get productPrice;
  @override
  String get productCurrency;
  @override
  int get quantity;
  @override
  double get productPriceMru;
  @override
  double get shippingFeeMru;
  @override
  double get serviceFeeMru;
  @override
  double get totalMru;
  @override
  String? get adminNotes;
  @override
  double? get weightKg;
  @override
  String? get trackingNumber;
  @override
  String? get carrier;
  @override
  List<Map<String, dynamic>> get trackingEvents;
  @override
  List<Map<String, dynamic>> get payments;
  @override
  DateTime? get paidAt;
  @override
  DateTime? get purchasedAt;
  @override
  DateTime? get shippedAt;
  @override
  DateTime? get arrivedAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime? get cancelledAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
