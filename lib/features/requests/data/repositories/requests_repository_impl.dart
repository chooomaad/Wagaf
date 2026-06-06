import '../../domain/entities/import_request_entity.dart';
import '../../domain/repositories/requests_repository.dart';
import '../datasources/requests_remote_datasource.dart';

class RequestsRepositoryImpl implements RequestsRepository {
  final RequestsRemoteDataSource _ds;

  RequestsRepositoryImpl({required RequestsRemoteDataSource dataSource})
      : _ds = dataSource;

  @override
  Future<ImportRequest> createRequest({
    required String userId,
    required String productUrl,
    required String marketplace,
    String? notes,
  }) =>
      _ds.createRequest({
        'user_id': userId,
        'product_url': productUrl,
        'marketplace': marketplace,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });

  @override
  Future<List<ImportRequest>> getUserRequests(String userId) =>
      _ds.getUserRequests(userId);

  @override
  Future<List<ImportRequest>> getAllRequests() => _ds.getAllRequests();

  @override
  Future<ImportRequest> updateStatus(String id, String status) =>
      _ds.updateRequest(id, {'status': status});

  @override
  Future<ImportRequest> sendQuote({
    required String id,
    required double quotedPrice,
    required double shippingPrice,
    required double serviceFee,
    required double totalPrice,
    String? adminNotes,
  }) =>
      _ds.updateRequest(id, {
        'status': 'quoted',
        'quoted_price': quotedPrice,
        'shipping_price': shippingPrice,
        'service_fee': serviceFee,
        'total_price': totalPrice,
        if (adminNotes != null && adminNotes.isNotEmpty)
          'admin_notes': adminNotes,
      });

  @override
  Future<ImportRequest> acceptQuote(String id) =>
      _ds.updateRequest(id, {'status': 'approved'});

  @override
  Future<ImportRequest> cancelRequest(String id) =>
      _ds.updateRequest(id, {'status': 'cancelled'});
}
