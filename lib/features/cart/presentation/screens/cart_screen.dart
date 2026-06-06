import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../providers/cart_provider.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Panier (${cart.itemCount})'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(cartProvider.notifier).clear(),
              child: const Text('Vider',
                  style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.all(AppSizes.paddingScreen),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.md),
                    itemBuilder: (ctx, i) =>
                        _CartItemCard(item: cart.items[i]),
                  ),
                ),
                _CartSummary(cart: cart),
              ],
            ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final CartItemEntity item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: item.product.images.isNotEmpty
                ? Image.network(
                    item.product.images.first,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder,
                  )
                : _placeholder,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatMRU(
                      CurrencyFormatter.usdToMRU(item.product.price)),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _QtyBtn(
                    icon: Icons.remove,
                    onTap: () =>
                        cart.updateQuantity(item.id, item.quantity - 1),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                    child: Text('${item.quantity}',
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  _QtyBtn(
                    icon: Icons.add,
                    onTap: () =>
                        cart.updateQuantity(item.id, item.quantity + 1),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xs),
              GestureDetector(
                onTap: () => cart.removeItem(item.id),
                child: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget get _placeholder => Container(
        width: 64,
        height: 64,
        color: AppColors.grey100,
        child: const Icon(Icons.image_outlined,
            color: AppColors.grey400, size: 28),
      );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(icon, size: 16, color: AppColors.grey700),
        ),
      );
}

class _CartSummary extends ConsumerStatefulWidget {
  final CartState cart;
  const _CartSummary({required this.cart});

  @override
  ConsumerState<_CartSummary> createState() => _CartSummaryState();
}

class _CartSummaryState extends ConsumerState<_CartSummary> {
  bool _isLoading = false;

  static const double _shippingPerItem = 800.0;
  static const double _serviceFeePercent = 0.15;

  Future<void> _checkout() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    int successCount = 0;
    for (final item in widget.cart.items) {
      final priceMru =
          CurrencyFormatter.usdToMRU(item.product.price) * item.quantity;
      final shippingMru = _shippingPerItem * item.quantity;
      final serviceMru = priceMru * _serviceFeePercent;
      final totalMru = priceMru + shippingMru + serviceMru;

      final ok = await ref.read(ordersProvider.notifier).createOrder({
        'user_id': user.id,
        'product_url': item.product.url,
        'platform': item.product.platform,
        'product_title': item.product.title,
        'product_image':
            item.product.images.isNotEmpty ? item.product.images.first : null,
        'product_price': item.product.price,
        'product_currency': item.product.currency,
        'quantity': item.quantity,
        'product_price_mru': priceMru,
        'shipping_fee_mru': shippingMru,
        'service_fee_mru': serviceMru,
        'total_mru': totalMru,
      });
      if (ok) successCount++;
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (successCount == widget.cart.items.length) {
      ref.read(cartProvider.notifier).clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commandes passées avec succès !'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/orders');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certaines commandes ont échoué. Vérifiez votre connexion.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.paddingScreen,
        right: AppSizes.paddingScreen,
        top: AppSizes.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSizes.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _Row('Sous-total',
              CurrencyFormatter.formatMRU(widget.cart.subtotalMru)),
          const SizedBox(height: AppSizes.xs),
          _Row('Transport estimé',
              CurrencyFormatter.formatMRU(widget.cart.totalShippingMru)),
          const SizedBox(height: AppSizes.xs),
          _Row('Frais de service',
              CurrencyFormatter.formatMRU(widget.cart.totalServiceMru)),
          const Divider(height: AppSizes.lg),
          _Row(
            'Total',
            CurrencyFormatter.formatMRU(widget.cart.totalMru),
            isTotal: true,
          ),
          const SizedBox(height: AppSizes.md),
          AppButton(
            label: 'Passer la commande',
            onPressed: _checkout,
            isLoading: _isLoading,
            icon: Icons.flash_on_rounded,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _Row(this.label, this.value, {this.isTotal = false});

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
                        color: AppColors.primary, fontWeight: FontWeight.w700)
                  : Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500)),
        ],
      );
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 80, color: AppColors.grey300),
            const SizedBox(height: AppSizes.lg),
            Text('Votre panier est vide',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.grey500)),
            const SizedBox(height: AppSizes.md),
            TextButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Commencer vos achats'),
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      );
}
