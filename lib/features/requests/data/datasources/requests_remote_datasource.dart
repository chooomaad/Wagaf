import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/import_request_entity.dart';

abstract class RequestsRemoteDataSource {
  Future<ImportRequest> createRequest(Map<String, dynamic> data);
  Future<List<ImportRequest>> getUserRequests(String userId);
  Future<List<ImportRequest>> getAllRequests();
  Future<ImportRequest> updateRequest(String id, Map<String, dynamic> data);
}

class RequestsRemoteDataSourceImpl implements RequestsRemoteDataSource {
  final SupabaseClient _db;

  RequestsRemoteDataSourceImpl({required SupabaseClient db}) : _db = db;

  static const _table = 'import_requests';

  @override
  Future<ImportRequest> createRequest(Map<String, dynamic> data) async {
    final rows = await _db.from(_table).insert(data).select();
    return ImportRequest.fromMap((rows as List).first as Map<String, dynamic>);
  }

  @override
  Future<List<ImportRequest>> getUserRequests(String userId) async {
    final rows = await _db
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => ImportRequest.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ImportRequest>> getAllRequests() async {
    final rows = await _db
        .from(_table)
        .select('*, profiles!import_requests_user_id_fkey(full_name, email)')
        .order('created_at', ascending: false)
        .limit(500);
    return (rows as List)
        .map((r) => ImportRequest.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ImportRequest> updateRequest(
      String id, Map<String, dynamic> data) async {
    final rows = await _db
        .from(_table)
        .update(data)
        .eq('id', id)
        .select();
    return ImportRequest.fromMap((rows as List).first as Map<String, dynamic>);
  }
}
