import '../entities/import_request_entity.dart';

abstract class RequestsRepository {
  Future<ImportRequest> createRequest({
    required String userId,
    required String productUrl,
    required String marketplace,
    String? notes,
  });

  Future<List<ImportRequest>> getUserRequests(String userId);

  Future<List<ImportRequest>> getAllRequests();

  Future<ImportRequest> updateStatus(String id, String status);

  Future<ImportRequest> sendQuote({
    required String id,
    required double quotedPrice,
    required double shippingPrice,
    required double serviceFee,
    required double totalPrice,
    String? adminNotes,
  });

  Future<ImportRequest> acceptQuote(String id);

  Future<ImportRequest> cancelRequest(String id);
}
