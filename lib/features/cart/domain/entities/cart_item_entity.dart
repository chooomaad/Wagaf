import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../search/domain/entities/product_entity.dart';

part 'cart_item_entity.freezed.dart';
part 'cart_item_entity.g.dart';

@freezed
class CartItemEntity with _$CartItemEntity {
  const factory CartItemEntity({
    required String id,
    required ProductEntity product,
    @Default(1) int quantity,
    double? shippingFeeMru,
    double? serviceFeeMru,
  }) = _CartItemEntity;

  factory CartItemEntity.fromJson(Map<String, dynamic> json) =>
      _$CartItemEntityFromJson(json);
}
