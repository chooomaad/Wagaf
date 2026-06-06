import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/import_request_entity.dart';
import '../../domain/repositories/requests_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

enum RequestsStatus { idle, loading, success, error }

class RequestsState {
  final RequestsStatus status;
  final List<ImportRequest> requests;
  final ImportRequest? lastCreated;
  final String? error;

  const RequestsState({
    this.status = RequestsStatus.idle,
    this.requests = const [],
    this.lastCreated,
    this.error,
  });

  RequestsState copyWith({
    RequestsStatus? status,
    List<ImportRequest>? requests,
    ImportRequest? lastCreated,
    String? error,
  }) =>
      RequestsState(
        status: status ?? this.status,
        requests: requests ?? this.requests,
        lastCreated: lastCreated ?? this.lastCreated,
        error: error,
      );
}

class RequestsNotifier extends StateNotifier<RequestsState> {
  final RequestsRepository _repo;

  RequestsNotifier(this._repo) : super(const RequestsState());

  Future<ImportRequest?> createRequest({
    required String userId,
    required String productUrl,
    required String marketplace,
    String? notes,
  }) async {
    state = state.copyWith(status: RequestsStatus.loading, error: null);
    try {
      final request = await _repo.createRequest(
        userId: userId,
        productUrl: productUrl,
        marketplace: marketplace,
        notes: notes,
      );
      state = state.copyWith(
        status: RequestsStatus.success,
        requests: [request, ...state.requests],
        lastCreated: request,
      );
      return request;
    } catch (e) {
      state = state.copyWith(
        status: RequestsStatus.error,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<void> loadUserRequests(String userId) async {
    state = state.copyWith(status: RequestsStatus.loading, error: null);
    try {
      final requests = await _repo.getUserRequests(userId);
      state = state.copyWith(
        status: RequestsStatus.success,
        requests: requests,
      );
    } catch (e) {
      state = state.copyWith(
        status: RequestsStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<bool> acceptQuote(String requestId) async {
    try {
      final updated = await _repo.acceptQuote(requestId);
      _replace(updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelRequest(String requestId) async {
    try {
      final updated = await _repo.cancelRequest(requestId);
      _replace(updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _replace(ImportRequest updated) {
    state = state.copyWith(
      requests: state.requests
          .map((r) => r.id == updated.id ? updated : r)
          .toList(),
    );
  }
}

final requestsRepositoryProvider = Provider<RequestsRepository>(
  (_) => GetIt.instance<RequestsRepository>(),
);

final requestsProvider =
    StateNotifierProvider<RequestsNotifier, RequestsState>((ref) {
  return RequestsNotifier(ref.watch(requestsRepositoryProvider));
});

// FutureProvider for the current user's requests (used in MyRequestsScreen)
final userRequestsProvider = FutureProvider<List<ImportRequest>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  try {
    final repo = ref.watch(requestsRepositoryProvider);
    return await repo.getUserRequests(user.id);
  } catch (e) {
    throw Exception('Impossible de charger vos demandes. Vérifiez votre connexion.');
  }
});

// Admin: all requests with profiles join
final adminRequestsRawProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = GetIt.instance<SupabaseClient>();
  final data = await db
      .from('import_requests')
      .select('*, profiles!import_requests_user_id_fkey(full_name, email)')
      .order('created_at', ascending: false)
      .limit(500);
  return List<Map<String, dynamic>>.from(data as List);
});
