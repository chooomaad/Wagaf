import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_entity.freezed.dart';
part 'product_entity.g.dart';

@freezed
class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    String? id,
    required String url,
    required String platform,
    required String title,
    String? description,
    required double price,
    @Default('USD') String currency,
    @Default([]) List<String> images,
    String? category,
    double? rating,
    int? reviewsCount,
    @Default(true) bool isAvailable,
    @Default({}) Map<String, dynamic> metadata,
  }) = _ProductEntity;

  factory ProductEntity.fromJson(Map<String, dynamic> json) =>
      _$ProductEntityFromJson(json);
}
