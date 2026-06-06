import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tw.dart';
import '../../domain/entities/import_request_entity.dart';
import '../providers/requests_provider.dart';

class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> {
  String? _filter; // null = all

  static const _filters = [
    (null, 'Tout'),
    ('pending', 'En attente'),
    ('analysing', 'En analyse'),
    ('quoted', 'Devis reçu'),
    ('approved', 'Accepté'),
    ('ordered', 'Commandé'),
    ('shipping', 'En livraison'),
    ('delivered', 'Livré'),
    ('cancelled', 'Annulé'),
  ];

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(userRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.grey700),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mes demandes',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.grey600),
            tooltip: 'Actualiser',
            onPressed: () => ref.invalidate(userRequestsProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.grey200),
        ),
      ),
      body: requestsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: AppColors.grey400),
              const SizedBox(height: 12),
              Text('Erreur: $e',
                  style: GoogleFonts.poppins(color: AppColors.grey500),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(userRequestsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (all) {
          final requests = _filter == null
              ? all
              : all.where((r) => r.status == _filter).toList();

          return Column(
            children: [
              // ── Filter chips ────────────────────────────────────────────
              if (all.isNotEmpty)
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(
                      Tw.s4, Tw.s2, Tw.s4, Tw.s2),
                  child: SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 6),
                      itemCount: _filters.length,
                      itemBuilder: (_, i) {
                        final (code, label) = _filters[i];
                        final selected = _filter == code;
                        final count = code == null
                            ? all.length
                            : all
                                .where((r) => r.status == code)
                                .length;
                        if (code != null && count == 0) {
                          return const SizedBox.shrink();
                        }
                        return GestureDetector(
                          onTap: () => setState(() => _filter = code),
                          child: AnimatedContainer(
                            duration: Tw.fast,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.grey100,
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.grey200,
                              ),
                            ),
                            child: Text(
                              '$label${count > 0 && code != null ? ' ($count)' : ''}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.grey600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // ── List ────────────────────────────────────────────────────
              Expanded(
                child: requests.isEmpty
                    ? _Empty(hasRequests: all.isNotEmpty)
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async =>
                            ref.invalidate(userRequestsProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(Tw.s4),
                          itemCount: requests.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: Tw.s3),
                          itemBuilder: (_, i) => _RequestCard(
                            request: requests[i],
                          )
                              .animate()
                              .fadeIn(
                                  delay: (i * 40).ms, duration: 300.ms)
                              .slideY(begin: 0.05, end: 0),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/home'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Nouvelle demande',
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Request card ──────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final ImportRequest request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);
    final isQuoted = request.status == 'quoted';

    return GestureDetector(
      onTap: () => context.push('/request-detail', extra: request),
      child: Container(
        padding: const EdgeInsets.all(Tw.s4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Tw.r2xl),
          border: Border.all(
            color: isQuoted
                ? AppColors.secondary.withValues(alpha: 0.5)
                : statusColor.withValues(alpha: 0.2),
            width: isQuoted ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                // Ref number
                Text(
                  'Réf. ${request.shortId}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: request.status),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yy').format(request.createdAt.toLocal()),
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: AppColors.grey400),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Marketplace + URL
            Row(
              children: [
                if (request.marketplace.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      request.marketplaceDisplay,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    request.productUrl,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.grey500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Quote highlight
            if (isQuoted) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.12),
                      AppColors.secondary.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_outlined,
                        size: 14, color: AppColors.secondaryDark),
                    const SizedBox(width: 8),
                    Text(
                      'Devis prêt — Appuyez pour consulter',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 11, color: AppColors.secondaryDark),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final label = _statusLabels[status] ?? status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _Empty extends StatelessWidget {
  final bool hasRequests;
  const _Empty({required this.hasRequests});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            hasRequests
                ? 'Aucune demande dans cette catégorie'
                : 'Aucune demande pour l\'instant',
            style: GoogleFonts.poppins(
                fontSize: 14, color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (!hasRequests)
            Text(
              'Copiez un lien produit depuis n\'importe quelle boutique et soumettez votre première demande.',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

const _statusLabels = {
  'pending': 'En attente',
  'analysing': 'En analyse',
  'quoted': 'Devis reçu',
  'approved': 'Devis accepté',
  'ordered': 'Commandé',
  'shipping': 'En livraison',
  'delivered': 'Livré',
  'cancelled': 'Annulé',
};

Color _statusColor(String s) {
  const map = {
    'pending': AppColors.statusPending,
    'analysing': AppColors.statusPayment,
    'quoted': AppColors.secondary,
    'approved': AppColors.success,
    'ordered': AppColors.statusPurchased,
    'shipping': AppColors.statusTransit,
    'delivered': AppColors.statusDelivered,
    'cancelled': AppColors.statusCancelled,
  };
  return map[s] ?? AppColors.grey400;
}
