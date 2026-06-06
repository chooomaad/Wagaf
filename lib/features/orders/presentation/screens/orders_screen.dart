import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../../domain/entities/order_entity.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(ordersProvider.notifier).loadUserOrders(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commandes'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, OrdersState state) {
    if (state.status == OrdersStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 80, color: AppColors.grey300),
            const SizedBox(height: AppSizes.lg),
            Text(
              'Aucune commande pour l\'instant',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.grey500,
                  ),
            ),
            const SizedBox(height: AppSizes.md),
            TextButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Passer une commande'),
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.paddingScreen),
      itemCount: state.orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      itemBuilder: (ctx, i) => OrderCard(
        order: state.orders[i],
        onTap: () {
          ref.read(ordersProvider.notifier).selectOrder(state.orders[i]);
          context.push('/order-detail');
        },
      ).animate().fadeIn(delay: Duration(milliseconds: i * 60)).slideY(begin: 0.1, end: 0),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;
  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: order.productImage != null
                      ? Image.network(
                          order.productImage!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imgPlaceholder,
                        )
                      : _imgPlaceholder,
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productTitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qté: ${order.quantity}  •  ${CurrencyFormatter.formatMRU(order.totalMru)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.grey400),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Commandé le ${DateFormat('dd MMM yyyy', 'fr').format(order.createdAt)}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget get _imgPlaceholder => Container(
        width: 56,
        height: 56,
        color: AppColors.grey100,
        child: const Icon(Icons.image_outlined,
            color: AppColors.grey400, size: 28),
      );
}

class OrderStatusChip extends StatelessWidget {
  final String status;
  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: info.$1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        info.$2,
        style: TextStyle(
          color: info.$1,
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _statusInfo(String status) {
    switch (status) {
      case 'pending':
        return (AppColors.statusPending, 'En attente');
      case 'payment_validated':
        return (AppColors.statusPayment, 'Paiement validé');
      case 'purchased':
        return (AppColors.statusPurchased, 'Acheté');
      case 'in_transit':
        return (AppColors.statusTransit, 'En transit');
      case 'arrived_mauritania':
        return (AppColors.statusArrived, 'Arrivé');
      case 'delivered':
        return (AppColors.statusDelivered, 'Livré');
      case 'cancelled':
        return (AppColors.statusCancelled, 'Annulé');
      default:
        return (AppColors.grey500, status);
    }
  }
}
