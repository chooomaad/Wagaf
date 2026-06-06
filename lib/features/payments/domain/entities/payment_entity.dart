import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_entity.freezed.dart';
part 'payment_entity.g.dart';

@freezed
class PaymentEntity with _$PaymentEntity {
  const factory PaymentEntity({
    required String id,
    required String orderId,
    required String userId,
    required double amount,
    @Default('MRU') String currency,
    @Default('manual') String method,
    @Default('pending') String status,
    String? reference,
    String? proofUrl,
    String? adminNotes,
    String? validatedBy,
    DateTime? validatedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PaymentEntity;

  factory PaymentEntity.fromJson(Map<String, dynamic> json) =>
      _$PaymentEntityFromJson(json);
}
