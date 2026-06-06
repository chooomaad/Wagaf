import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/orders_provider.dart';
import 'orders_screen.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(ordersProvider).selectedOrder;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail commande')),
        body: const Center(child: Text('Commande introuvable')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(order.orderNumber),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.track_changes_outlined, size: 18),
            label: const Text('Suivi'),
            onPressed: () => context.push('/order-detail'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: Column(
                children: [
                  OrderStatusChip(status: order.status),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Commandé le ${DateFormat('dd MMMM yyyy', 'fr').format(order.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Product info
            _Section(
              title: 'Produit',
              child: Row(
                children: [
                  if (order.productImage != null)
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      child: Image.network(
                        order.productImage!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _imgPlaceholder,
                      ),
                    )
                  else
                    _imgPlaceholder,
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.productTitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.w500),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('Plateforme: ${order.platform.toUpperCase()}',
                            style: Theme.of(context).textTheme.labelSmall),
                        Text('Quantité: ${order.quantity}',
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Pricing
            _Section(
              title: 'Récapitulatif des prix',
              child: Column(
                children: [
                  _PriceRow('Prix produit',
                      CurrencyFormatter.formatMRU(order.productPriceMru)),
                  const SizedBox(height: AppSizes.xs),
                  _PriceRow('Transport',
                      CurrencyFormatter.formatMRU(order.shippingFeeMru)),
                  const SizedBox(height: AppSizes.xs),
                  _PriceRow('Service',
                      CurrencyFormatter.formatMRU(order.serviceFeeMru)),
                  const Divider(height: AppSizes.lg),
                  _PriceRow(
                    'Total',
                    CurrencyFormatter.formatMRU(order.totalMru),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Timeline mini
            _Section(
              title: 'Historique',
              child: order.trackingEvents.isEmpty
                  ? Text('Aucun événement',
                      style: Theme.of(context).textTheme.bodySmall)
                  : Column(
                      children: order.trackingEvents
                          .map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSizes.sm),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.circle,
                                      size: 8, color: AppColors.primary),
                                  const SizedBox(width: AppSizes.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(e.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium),
                                        Text(
                                          DateFormat('dd/MM/yyyy HH:mm')
                                              .format(e.createdAt),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }

  Widget get _imgPlaceholder => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: const Icon(Icons.image_outlined,
            color: AppColors.grey400, size: 32),
      );
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSizes.sm),
          child,
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _PriceRow(this.label, this.value, {this.isTotal = false});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isTotal
                  ? Theme.of(context).textTheme.titleMedium
                  : Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: isTotal
                  ? Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      )
                  : Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500)),
        ],
      );
}
