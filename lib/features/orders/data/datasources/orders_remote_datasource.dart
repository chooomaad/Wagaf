import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<OrderModel> getOrderById(String orderId);
  Future<OrderModel> createOrder(Map<String, dynamic> data);
  Future<OrderModel> updateOrderStatus(String orderId, String status, {String? adminNotes});
  Future<OrderModel> updateOrderDetails(String orderId, {
    String? adminNotes,
    double? weightKg,
    double? shippingFeeMru,
    double? serviceFeeMru,
    double? totalMru,
  });
  Future<List<OrderModel>> getAllOrders({int page = 0, int limit = 20});
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final SupabaseClient supabase;
  OrdersRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final data = await supabase
          .from('orders')
          .select('*, tracking_events(*), payments(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (data as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final data = await supabase
          .from('orders')
          .select('*, tracking_events(*), payments(*)')
          .eq('id', orderId)
          .single();
      return OrderModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    try {
      final result = await supabase
          .from('orders')
          .insert(data)
          .select('*, tracking_events(*), payments(*)')
          .single();
      return OrderModel.fromJson(result);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(
    String orderId,
    String status, {
    String? adminNotes,
  }) async {
    try {
      final updates = <String, dynamic>{'status': status};
      if (adminNotes != null) updates['admin_notes'] = adminNotes;

      final now = DateTime.now().toIso8601String();
      switch (status) {
        case 'payment_validated':
          updates['paid_at'] = now;
          break;
        case 'purchased':
          updates['purchased_at'] = now;
          break;
        case 'in_transit':
          updates['shipped_at'] = now;
          break;
        case 'arrived_mauritania':
          updates['arrived_at'] = now;
          break;
        case 'delivered':
          updates['delivered_at'] = now;
          break;
        case 'cancelled':
          updates['cancelled_at'] = now;
          break;
      }

      final result = await supabase
          .from('orders')
          .update(updates)
          .eq('id', orderId)
          .select('*, tracking_events(*), payments(*)')
          .single();
      return OrderModel.fromJson(result);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<OrderModel> updateOrderDetails(
    String orderId, {
    String? adminNotes,
    double? weightKg,
    double? shippingFeeMru,
    double? serviceFeeMru,
    double? totalMru,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (adminNotes != null) updates['admin_notes'] = adminNotes;
      if (weightKg != null) updates['weight_kg'] = weightKg;
      if (shippingFeeMru != null) updates['shipping_fee_mru'] = shippingFeeMru;
      if (serviceFeeMru != null) updates['service_fee_mru'] = serviceFeeMru;
      if (totalMru != null) updates['total_mru'] = totalMru;

      final result = await supabase
          .from('orders')
          .update(updates)
          .eq('id', orderId)
          .select('*, tracking_events(*), payments(*)')
          .single();
      return OrderModel.fromJson(result);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getAllOrders({int page = 0, int limit = 20}) async {
    try {
      final data = await supabase
          .from('orders')
          .select('*, profiles(full_name, email, phone), tracking_events(*), payments(*)')
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);
      return (data as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
