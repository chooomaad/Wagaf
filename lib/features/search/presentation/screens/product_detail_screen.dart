import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../providers/search_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedImage = 0;
  static const double _serviceFeePercent = 0.15;
  static const double _shippingMru = 800;

  double get _priceMru {
    final product = ref.read(searchProvider).product;
    if (product == null) return 0;
    return CurrencyFormatter.usdToMRU(product.price) * _quantity;
  }

  double get _serviceFee => _priceMru * _serviceFeePercent;
  double get _total => _priceMru + _shippingMru + _serviceFee;

  Future<void> _orderNow() async {
    final product = ref.read(searchProvider).product;
    final user = ref.read(currentUserProvider);
    if (product == null || user == null) return;

    final success = await ref.read(ordersProvider.notifier).createOrder({
      'user_id': user.id,
      'product_url': product.url,
      'platform': product.platform,
      'product_title': product.title,
      'product_image':
          product.images.isNotEmpty ? product.images.first : null,
      'product_price': product.price,
      'product_currency': product.currency,
      'quantity': _quantity,
      'product_price_mru': _priceMru,
      'shipping_fee_mru': _shippingMru,
      'service_fee_mru': _serviceFee,
      'total_mru': _total,
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande passée avec succès ! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/orders');
    }
  }

  void _addToCart() {
    final product = ref.read(searchProvider).product;
    if (product == null) return;
    ref.read(cartProvider.notifier).addItem(product, quantity: _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produit ajouté au panier !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final product = state.product;
    final ordersState = ref.watch(ordersProvider);

    if (product == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Image gallery AppBar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.white,
            leading: CircleAvatar(
              backgroundColor: AppColors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: product.images.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          onPageChanged: (i) =>
                              setState(() => _selectedImage = i),
                          itemCount: product.images.length,
                          itemBuilder: (_, i) => CachedNetworkImage(
                            imageUrl: product.images[i],
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                                color: AppColors.grey100),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.grey100,
                              child: const Icon(Icons.image_not_supported,
                                  size: 60, color: AppColors.grey400),
                            ),
                          ),
                        ),
                        if (product.images.length > 1)
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                product.images.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: _selectedImage == i ? 20 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _selectedImage == i
                                        ? AppColors.primary
                                        : AppColors.grey400,
                                    borderRadius:
                                        BorderRadius.circular(AppSizes.radiusFull),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: AppColors.grey100,
                      child: const Icon(Icons.image_outlined,
                          size: 80, color: AppColors.grey400),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
              ),
              child: Column(
                children: [
                  // Main info card
                  Container(
                    margin: const EdgeInsets.all(AppSizes.paddingScreen),
                    padding: const EdgeInsets.all(AppSizes.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Platform badge
                        _PlatformBadge(platform: product.platform),
                        const SizedBox(height: AppSizes.sm),
                        // Title
                        Text(
                          product.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        // Rating
                        if (product.rating != null)
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  i < product.rating!.round()
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: AppColors.secondary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: AppSizes.xs),
                              Text(
                                '${product.rating!.toStringAsFixed(1)} '
                                '(${product.reviewsCount ?? 0} avis)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        const SizedBox(height: AppSizes.md),
                        const Divider(),
                        const SizedBox(height: AppSizes.md),

                        // Quantity selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quantité',
                                style: Theme.of(context).textTheme.titleMedium),
                            Row(
                              children: [
                                _QtyButton(
                                  icon: Icons.remove,
                                  onTap: () {
                                    if (_quantity > 1) {
                                      setState(() => _quantity--);
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.md),
                                  child: Text(
                                    '$_quantity',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                _QtyButton(
                                  icon: Icons.add,
                                  onTap: () => setState(() => _quantity++),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                  // Price breakdown
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingScreen),
                    padding: const EdgeInsets.all(AppSizes.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Récapitulatif des prix',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSizes.md),
                        _PriceRow(
                          label: 'Prix produit',
                          value: CurrencyFormatter.formatMRU(_priceMru),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        _PriceRow(
                          label: 'Frais de transport',
                          value: CurrencyFormatter.formatMRU(_shippingMru),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        _PriceRow(
                          label: 'Frais de service (15%)',
                          value: CurrencyFormatter.formatMRU(_serviceFee),
                        ),
                        const SizedBox(height: AppSizes.md),
                        const Divider(),
                        const SizedBox(height: AppSizes.md),
                        _PriceRow(
                          label: 'Total',
                          value: CurrencyFormatter.formatMRU(_total),
                          isTotal: true,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  // Description
                  if (product.description != null)
                    Container(
                      margin: const EdgeInsets.all(AppSizes.paddingScreen),
                      padding: const EdgeInsets.all(AppSizes.lg),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            product.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom action buttons
      bottomSheet: Container(
        padding: EdgeInsets.only(
          left: AppSizes.paddingScreen,
          right: AppSizes.paddingScreen,
          top: AppSizes.md,
          bottom: MediaQuery.of(context).padding.bottom + AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Panier',
                onPressed: _addToCart,
                isOutlined: true,
                icon: Icons.shopping_cart_outlined,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              flex: 2,
              child: AppButton(
                label: 'Commander',
                onPressed: _orderNow,
                isLoading: ordersState.status == OrdersStatus.loading,
                icon: Icons.flash_on_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  final String platform;
  const _PlatformBadge({required this.platform});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'aliexpress': const Color(0xFFE62A10),
      'amazon': const Color(0xFFFF9900),
      'temu': const Color(0xFFE55B13),
      'alibaba': const Color(0xFFFF6A00),
    };
    final color = colors[platform] ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        platform.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Icon(icon, size: 18, color: AppColors.grey700),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _PriceRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  )
              : Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
        ),
      ],
    );
  }
}
