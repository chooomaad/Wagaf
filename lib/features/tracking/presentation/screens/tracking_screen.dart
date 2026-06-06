import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../tracking/domain/entities/tracking_event_entity.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  static const _allSteps = [
    ('pending', 'Commande reçue', Icons.receipt_outlined),
    ('payment_validated', 'Paiement validé', Icons.verified_outlined),
    ('purchased', 'Produit acheté', Icons.shopping_bag_outlined),
    ('in_transit', 'En transit', Icons.local_shipping_outlined),
    ('arrived_mauritania', 'Arrivé en Mauritanie', Icons.flag_outlined),
    ('delivered', 'Livré', Icons.check_circle_outline),
  ];

  int _stepIndex(String status) {
    for (int i = 0; i < _allSteps.length; i++) {
      if (_allSteps[i].$1 == status) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(ordersProvider).selectedOrder;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Suivi de commande')),
        body: const Center(child: Text('Aucune commande sélectionnée')),
      );
    }

    final currentStep = _stepIndex(order.status);
    final isCancelled = order.status == 'cancelled';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suivi de commande'),
            Text(
              order.orderNumber,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCancelled)
              _CancelledBanner()
            else
              ..._allSteps.asMap().entries.map((entry) {
                final i = entry.key;
                final step = entry.value;
                final isCompleted = i <= currentStep;
                final isLast = i == _allSteps.length - 1;
                final eventForStep = order.trackingEvents
                    .where((e) => e.status == step.$1)
                    .lastOrNull;

                return TimelineTile(
                  alignment: TimelineAlign.start,
                  isFirst: i == 0,
                  isLast: isLast,
                  indicatorStyle: IndicatorStyle(
                    width: 36,
                    height: 36,
                    indicator: _StepIndicator(
                      icon: step.$3,
                      isCompleted: isCompleted,
                      isCurrent: i == currentStep,
                    ),
                  ),
                  beforeLineStyle: LineStyle(
                    color: isCompleted && i < currentStep
                        ? AppColors.primary
                        : AppColors.grey300,
                    thickness: 2,
                  ),
                  endChild: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSizes.md,
                      bottom: AppSizes.lg,
                    ),
                    child: _StepContent(
                      title: step.$2,
                      event: eventForStep,
                      isCompleted: isCompleted,
                      isCurrent: i == currentStep,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: i * 100))
                    .slideX(begin: -0.1, end: 0);
              }),

            if (order.trackingNumber != null) ...[
              const SizedBox(height: AppSizes.lg),
              _TrackingNumberCard(
                trackingNumber: order.trackingNumber!,
                carrier: order.carrier,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;
  const _StepIndicator({
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? AppColors.primary : AppColors.grey200,
        border: isCurrent
            ? Border.all(color: AppColors.secondary, width: 3)
            : null,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Icon(
        isCompleted ? Icons.check : icon,
        size: 18,
        color: isCompleted ? Colors.white : AppColors.grey500,
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  final String title;
  final TrackingEventEntity? event;
  final bool isCompleted;
  final bool isCurrent;
  const _StepContent({
    required this.title,
    this.event,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isCompleted ? AppColors.grey900 : AppColors.grey400,
              ),
        ),
        if (event != null) ...[
          const SizedBox(height: 2),
          Text(
            _formatDate(event!.createdAt),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                ),
          ),
          if (event!.description != null)
            Text(
              event!.description!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
        if (isCurrent && event == null)
          Text(
            'En cours...',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.secondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} à ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _CancelledBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: AppColors.error, size: 32),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande annulée',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.error,
                      ),
                ),
                Text(
                  'Cette commande a été annulée.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingNumberCard extends StatelessWidget {
  final String trackingNumber;
  final String? carrier;
  const _TrackingNumberCard({required this.trackingNumber, this.carrier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_outlined, color: AppColors.primary),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Numéro de suivi',
                    style: Theme.of(context).textTheme.labelSmall),
                Text(
                  trackingNumber,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontFamily: 'monospace',
                      ),
                ),
                if (carrier != null)
                  Text('Transporteur: $carrier',
                      style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
