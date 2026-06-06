import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get _db => GetIt.instance<SupabaseClient>();

// ── Import requests (admin) ───────────────────────────────────────────────────

final adminImportRequestsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await _db
      .from('import_requests')
      .select('*, profiles!import_requests_user_id_fkey(full_name, email)')
      .order('created_at', ascending: false)
      .limit(500);
  return List<Map<String, dynamic>>.from(data as List);
});

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

class AdminStats {
  final int totalUsers;
  final int totalOrders;
  final int pendingOrders;
  final int paymentValidatedOrders;
  final int purchasedOrders;
  final int inTransitOrders;
  final int arrivedOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double revenueToday;
  final double revenueMonth;
  final double revenueTotal;

  const AdminStats({
    this.totalUsers = 0,
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.paymentValidatedOrders = 0,
    this.purchasedOrders = 0,
    this.inTransitOrders = 0,
    this.arrivedOrders = 0,
    this.deliveredOrders = 0,
    this.cancelledOrders = 0,
    this.revenueToday = 0,
    this.revenueMonth = 0,
    this.revenueTotal = 0,
  });

  int get activeOrders =>
      pendingOrders +
      paymentValidatedOrders +
      purchasedOrders +
      inTransitOrders +
      arrivedOrders;
}

// ─────────────────────────────────────────────────────────────────────────────
// Raw data providers (direct Supabase, admin only)
// ─────────────────────────────────────────────────────────────────────────────

final adminOrdersRawProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await _db
      .from('orders')
      .select(
        '*,'
        'profiles!orders_user_id_fkey(full_name, email, phone),'
        'tracking_events(*),'
        'payments(*)',
      )
      .order('created_at', ascending: false)
      .limit(500);
  return List<Map<String, dynamic>>.from(data as List);
});

final adminUsersRawProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await _db
      .from('profiles')
      .select(
        'id, full_name, email, phone, city, role, status,'
        'total_orders, total_spent, created_at',
      )
      .order('created_at', ascending: false)
      .limit(500);
  return List<Map<String, dynamic>>.from(data as List);
});

// ─────────────────────────────────────────────────────────────────────────────
// Computed stats (derived from raw providers — no extra DB call)
// ─────────────────────────────────────────────────────────────────────────────

final adminStatsProvider = Provider<AsyncValue<AdminStats>>((ref) {
  final ordersAsync = ref.watch(adminOrdersRawProvider);
  final usersAsync = ref.watch(adminUsersRawProvider);

  return ordersAsync.when(
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
    data: (orders) => usersAsync.when(
      loading: () => const AsyncValue.loading(),
      error: AsyncValue.error,
      data: (users) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final monthStart = DateTime(now.year, now.month, 1);

        double revenueToday = 0;
        double revenueMonth = 0;
        double revenueTotal = 0;

        for (final o in orders) {
          if (o['status'] != 'delivered') continue;
          final amount = (o['total_mru'] as num?)?.toDouble() ?? 0;
          revenueTotal += amount;
          final created =
              DateTime.tryParse(o['created_at'] as String? ?? '');
          if (created != null) {
            if (!created.isBefore(todayStart)) revenueToday += amount;
            if (!created.isBefore(monthStart)) revenueMonth += amount;
          }
        }

        return AsyncValue.data(AdminStats(
          totalUsers: users.length,
          totalOrders: orders.length,
          pendingOrders:
              orders.where((o) => o['status'] == 'pending').length,
          paymentValidatedOrders: orders
              .where((o) => o['status'] == 'payment_validated')
              .length,
          purchasedOrders:
              orders.where((o) => o['status'] == 'purchased').length,
          inTransitOrders:
              orders.where((o) => o['status'] == 'in_transit').length,
          arrivedOrders: orders
              .where((o) => o['status'] == 'arrived_mauritania')
              .length,
          deliveredOrders:
              orders.where((o) => o['status'] == 'delivered').length,
          cancelledOrders:
              orders.where((o) => o['status'] == 'cancelled').length,
          revenueToday: revenueToday,
          revenueMonth: revenueMonth,
          revenueTotal: revenueTotal,
        ));
      },
    ),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// User management actions
// ─────────────────────────────────────────────────────────────────────────────

Future<void> adminSetUserStatus(String userId, String status) async {
  await _db
      .from('profiles')
      .update({'status': status})
      .eq('id', userId);
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification creation
// ─────────────────────────────────────────────────────────────────────────────

Future<void> adminSendNotification({
  required String userId,
  required String title,
  required String body,
  String type = 'system',
}) async {
  await _db.from('notifications').insert({
    'user_id': userId,
    'type': type,
    'title': title,
    'body': body,
    'data': <String, dynamic>{},
  });
}

Future<void> adminBroadcastNotification({
  required String title,
  required String body,
  String type = 'system',
}) async {
  final users = await _db.from('profiles').select('id').eq('status', 'active');
  final List rows = users as List;
  if (rows.isEmpty) return;

  final inserts = rows
      .map((u) => {
            'user_id': u['id'] as String,
            'type': type,
            'title': title,
            'body': body,
            'data': <String, dynamic>{},
          })
      .toList();

  await _db.from('notifications').insert(inserts);
}
