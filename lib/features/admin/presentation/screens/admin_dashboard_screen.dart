import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tw.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../providers/admin_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

const _kPad = 16.0;

String _statusLabel(String s) {
  const map = {
    'pending': 'En attente',
    'payment_validated': 'Paiement validé',
    'purchased': 'Commandé',
    'in_transit': 'En transit',
    'arrived_mauritania': 'Arrivé MR',
    'delivered': 'Livré',
    'cancelled': 'Annulé',
  };
  return map[s] ?? s;
}

Color _statusColor(String s) {
  const map = {
    'pending': AppColors.statusPending,
    'payment_validated': AppColors.statusPayment,
    'purchased': AppColors.statusPurchased,
    'in_transit': AppColors.statusTransit,
    'arrived_mauritania': AppColors.statusArrived,
    'delivered': AppColors.statusDelivered,
    'cancelled': AppColors.statusCancelled,
  };
  return map[s] ?? AppColors.grey400;
}

String _formatDate(String? iso) {
  if (iso == null) return '—';
  try {
    return DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(iso).toLocal());
  } catch (_) {
    return iso;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _tabs = const [
    Tab(icon: Icon(Icons.dashboard_outlined), text: 'Vue d\'ensemble'),
    Tab(icon: Icon(Icons.inbox_outlined), text: 'Demandes'),
    Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Commandes'),
    Tab(icon: Icon(Icons.people_outline), text: 'Utilisateurs'),
    Tab(icon: Icon(Icons.payment_outlined), text: 'Paiements'),
    Tab(icon: Icon(Icons.notifications_outlined), text: 'Notifications'),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(adminOrdersRawProvider);
    ref.invalidate(adminUsersRawProvider);
    ref.invalidate(adminImportRequestsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.grey700),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF004D2C)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              'Administration',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.grey600),
            onPressed: _refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey500,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _OverviewTab(onSwitchTab: (i) => _tab.animateTo(i)),
          const _ImportRequestsTab(),
          const _OrdersTab(),
          const _UsersTab(),
          const _PaymentsTab(),
          const _NotificationsTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overview Tab
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  final void Function(int) onSwitchTab;
  const _OverviewTab({required this.onSwitchTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final ordersAsync = ref.watch(adminOrdersRawProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(adminOrdersRawProvider);
        ref.invalidate(adminUsersRawProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(_kPad),
        children: [
          // ── Revenue cards ────────────────────────────────────────
          statsAsync.when(
            loading: () => _buildRevenueLoading(),
            error: (e, _) => _buildError(e),
            data: (stats) => Column(
              children: [
                _buildRevenueRow(stats),
                const SizedBox(height: _kPad),
                _buildKpiGrid(stats, onSwitchTab),
              ],
            ),
          ),
          const SizedBox(height: _kPad),

          // ── Recent orders ────────────────────────────────────────
          _SectionHeader(
            label: 'Commandes récentes',
            action: TextButton(
              onPressed: () => onSwitchTab(1),
              child: Text(
                'Voir tout',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ordersAsync.when(
            loading: () => const Center(
                child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColors.primary),
            )),
            error: (e, _) => _buildError(e),
            data: (orders) {
              final recent = orders.take(8).toList();
              if (recent.isEmpty) {
                return _buildEmpty('Aucune commande');
              }
              return Column(
                children: recent
                    .asMap()
                    .entries
                    .map((e) => _MiniOrderCard(order: e.value)
                        .animate()
                        .fadeIn(delay: (e.key * 50).ms)
                        .slideX(begin: 0.05))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueRow(AdminStats s) {
    return Row(
      children: [
        Expanded(
          child: _RevenueCard(
            label: "Aujourd'hui",
            value: CurrencyFormatter.formatMRU(s.revenueToday),
            icon: Icons.wb_sunny_outlined,
            color: const Color(0xFFFF9800),
          ).animate().fadeIn(delay: 0.ms).slideY(begin: 0.1),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RevenueCard(
            label: 'Ce mois',
            value: CurrencyFormatter.formatMRU(s.revenueMonth),
            icon: Icons.calendar_month_outlined,
            color: const Color(0xFF6C63FF),
          ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.1),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RevenueCard(
            label: 'Total',
            value: CurrencyFormatter.formatMRU(s.revenueTotal),
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.primary,
          ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.1),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(AdminStats s, void Function(int) onTab) {
    final kpis = [
      (
        label: 'Utilisateurs',
        value: '${s.totalUsers}',
        icon: Icons.people_outline,
        color: const Color(0xFF3B82F6),
        onTap: () => onTab(2),
      ),
      (
        label: 'Commandes',
        value: '${s.totalOrders}',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF8B5CF6),
        onTap: () => onTab(1),
      ),
      (
        label: 'En attente',
        value: '${s.pendingOrders}',
        icon: Icons.hourglass_empty_rounded,
        color: AppColors.statusPending,
        onTap: () => onTab(1),
      ),
      (
        label: 'Pmt validé',
        value: '${s.paymentValidatedOrders}',
        icon: Icons.check_circle_outline,
        color: AppColors.statusPayment,
        onTap: () => onTab(1),
      ),
      (
        label: 'En transit',
        value: '${s.inTransitOrders}',
        icon: Icons.local_shipping_outlined,
        color: AppColors.statusTransit,
        onTap: () => onTab(1),
      ),
      (
        label: 'Livrés',
        value: '${s.deliveredOrders}',
        icon: Icons.check_circle_rounded,
        color: AppColors.statusDelivered,
        onTap: () => onTab(1),
      ),
      (
        label: 'Arrivés MR',
        value: '${s.arrivedOrders}',
        icon: Icons.location_on_outlined,
        color: AppColors.statusArrived,
        onTap: () => onTab(1),
      ),
      (
        label: 'Annulés',
        value: '${s.cancelledOrders}',
        icon: Icons.cancel_outlined,
        color: AppColors.statusCancelled,
        onTap: () => onTab(1),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: kpis.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: kpis[i].onTap,
        child: _KpiCard(
          label: kpis[i].label,
          value: kpis[i].value,
          icon: kpis[i].icon,
          color: kpis[i].color,
        ).animate().fadeIn(delay: (i * 40).ms),
      ),
    );
  }

  Widget _buildRevenueLoading() => Row(
        children: List.generate(
            3,
            (_) => Expanded(
                  child: Container(
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )),
      );

  Widget _buildError(Object e) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Erreur: $e',
          style: GoogleFonts.poppins(
              fontSize: 12, color: AppColors.error),
        ),
      );

  Widget _buildEmpty(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(msg,
              style: GoogleFonts.poppins(color: AppColors.grey500)),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Orders Tab
// ─────────────────────────────────────────────────────────────────────────────

class _OrdersTab extends ConsumerStatefulWidget {
  const _OrdersTab();

  @override
  ConsumerState<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<_OrdersTab> {
  final _searchCtrl = TextEditingController();
  String? _filterStatus;
  String _query = '';

  static const _statuses = [
    null,
    'pending',
    'payment_validated',
    'purchased',
    'in_transit',
    'arrived_mauritania',
    'delivered',
    'cancelled',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> orders) {
    var list = orders;
    if (_filterStatus != null) {
      list = list.where((o) => o['status'] == _filterStatus).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((o) {
        final title = (o['product_title'] as String? ?? '').toLowerCase();
        final num = (o['order_number'] as String? ?? '').toLowerCase();
        final profile = o['profiles'] as Map?;
        final name = (profile?['full_name'] as String? ?? '').toLowerCase();
        final email = (profile?['email'] as String? ?? '').toLowerCase();
        return title.contains(q) ||
            num.contains(q) ||
            name.contains(q) ||
            email.contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersRawProvider);

    return Column(
      children: [
        // ── Search + filter ─────────────────────────────────────
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(_kPad, 12, _kPad, 0),
          child: Column(
            children: [
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                      'Rechercher commande, produit, client…',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.grey400),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 20, color: AppColors.grey500),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 6),
                  itemCount: _statuses.length,
                  itemBuilder: (_, i) {
                    final s = _statuses[i];
                    final selected = _filterStatus == s;
                    final label = s == null ? 'Tout' : _statusLabel(s);
                    final color = s == null
                        ? AppColors.primary
                        : _statusColor(s);
                    return GestureDetector(
                      onTap: () => setState(() => _filterStatus = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? color
                              : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? color
                                : color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : color,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // ── Orders list ──────────────────────────────────────────
        Expanded(
          child: ordersAsync.when(
            loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Center(
              child: Text('Erreur : $e',
                  style: GoogleFonts.poppins(color: AppColors.error)),
            ),
            data: (orders) {
              final filtered = _filtered(orders);
              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox_outlined,
                          size: 56, color: AppColors.grey400),
                      const SizedBox(height: 12),
                      Text(
                        'Aucune commande trouvée',
                        style: GoogleFonts.poppins(
                            color: AppColors.grey500),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(_kPad),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                itemBuilder: (ctx, i) =>
                    _AdminOrderCard(order: filtered[i])
                        .animate()
                        .fadeIn(delay: (i * 30).ms, duration: 250.ms),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Import Requests Tab
// ─────────────────────────────────────────────────────────────────────────────

const _reqStatusLabels = {
  'pending': 'En attente',
  'analysing': 'En analyse',
  'quoted': 'Devis envoyé',
  'approved': 'Devis accepté',
  'ordered': 'Commandé',
  'shipping': 'En livraison',
  'delivered': 'Livré',
  'cancelled': 'Annulé',
};

Color _reqStatusColor(String s) {
  const m = {
    'pending': AppColors.statusPending,
    'analysing': AppColors.statusPayment,
    'quoted': AppColors.secondary,
    'approved': AppColors.success,
    'ordered': AppColors.statusPurchased,
    'shipping': AppColors.statusTransit,
    'delivered': AppColors.statusDelivered,
    'cancelled': AppColors.statusCancelled,
  };
  return m[s] ?? AppColors.grey400;
}

class _ImportRequestsTab extends ConsumerStatefulWidget {
  const _ImportRequestsTab();

  @override
  ConsumerState<_ImportRequestsTab> createState() =>
      _ImportRequestsTabState();
}

class _ImportRequestsTabState extends ConsumerState<_ImportRequestsTab> {
  String? _filterStatus;

  static const _statuses = [
    null,
    'pending',
    'analysing',
    'quoted',
    'approved',
    'ordered',
    'shipping',
    'delivered',
    'cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminImportRequestsProvider);

    return Column(
      children: [
        // ── Filter ──────────────────────���────────────────────────
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(_kPad, 8, _kPad, 0),
          child: Column(
            children: [
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemCount: _statuses.length,
                  itemBuilder: (_, i) {
                    final s = _statuses[i];
                    final label = s == null ? 'Tout' : (_reqStatusLabels[s] ?? s);
                    final selected = _filterStatus == s;
                    final color = s == null ? AppColors.primary : _reqStatusColor(s);
                    return GestureDetector(
                      onTap: () => setState(() => _filterStatus = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? color : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? color : color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : color,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // ── List ─────────────────────────────────────────────────
        Expanded(
          child: async.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Center(
              child: Text('Erreur : $e',
                  style: GoogleFonts.poppins(color: AppColors.error)),
            ),
            data: (all) {
              final list = _filterStatus == null
                  ? all
                  : all.where((r) => r['status'] == _filterStatus).toList();

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox_outlined,
                          size: 56, color: AppColors.grey400),
                      const SizedBox(height: 12),
                      Text('Aucune demande',
                          style: GoogleFonts.poppins(color: AppColors.grey500)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async =>
                    ref.invalidate(adminImportRequestsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(_kPad),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _AdminRequestCard(req: list[i])
                      .animate()
                      .fadeIn(delay: (i * 30).ms, duration: 250.ms),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdminRequestCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> req;
  const _AdminRequestCard({required this.req});

  @override
  ConsumerState<_AdminRequestCard> createState() => _AdminRequestCardState();
}

class _AdminRequestCardState extends ConsumerState<_AdminRequestCard> {
  bool _expanded = false;

  Map<String, dynamic> get r => widget.req;
  String get status => r['status'] as String? ?? 'pending';
  String get shortId {
    final id = r['id'] as String? ?? '';
    return id.length >= 8 ? id.substring(0, 8).toUpperCase() : id;
  }
  Map? get profile => r['profiles'] as Map?;
  String get clientName => profile?['full_name'] as String? ?? '—';
  String get clientEmail => profile?['email'] as String? ?? '—';
  String get url => r['product_url'] as String? ?? '';
  String get marketplace => r['marketplace'] as String? ?? '';

  Future<void> _updateStatus(String newStatus) async {
    try {
      await GetIt.instance<SupabaseClient>()
          .from('import_requests')
          .update({'status': newStatus})
          .eq('id', r['id'] as String);
      ref.invalidate(adminImportRequestsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Statut mis à jour : ${_reqStatusLabels[newStatus] ?? newStatus}'),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : $e'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  void _showQuoteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuoteSheet(
        requestId: r['id'] as String,
        onSent: () => ref.invalidate(adminImportRequestsProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _reqStatusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('Réf. $shortId',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey900)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _reqStatusLabels[status] ?? status,
                              style: GoogleFonts.poppins(
                                  fontSize: 9, fontWeight: FontWeight.w700, color: color),
                            ),
                          ),
                        ]),
                        Text('$clientName · $clientEmail',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: AppColors.grey500)),
                        if (marketplace.isNotEmpty)
                          Text(marketplace.toUpperCase(),
                              style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey400)),
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(r['created_at'] as String?),
                    style: GoogleFonts.poppins(fontSize: 9, color: AppColors.grey400),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.grey400,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: color.withValues(alpha: 0.2)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // URL
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(url,
                        style: GoogleFonts.sourceCodePro(
                            fontSize: 10, color: AppColors.grey700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if ((r['notes'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    _InfoRow(label: 'Notes client', value: r['notes'] as String),
                  ],
                  if ((r['quoted_price'] as num?) != null) ...[
                    const SizedBox(height: 6),
                    _InfoRow(
                        label: 'Prix devis',
                        value: CurrencyFormatter.formatMRU(
                            (r['total_price'] as num?)?.toDouble() ?? 0)),
                  ],
                  const SizedBox(height: 10),
                  // Actions
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (status == 'pending')
                        _ActionChip(
                          label: 'En analyse',
                          icon: Icons.science_outlined,
                          color: AppColors.statusPayment,
                          onTap: () => _updateStatus('analysing'),
                        ),
                      if (status == 'pending' || status == 'analysing')
                        _ActionChip(
                          label: 'Envoyer devis',
                          icon: Icons.send_rounded,
                          color: AppColors.secondary,
                          onTap: _showQuoteSheet,
                        ),
                      if (status == 'approved')
                        _ActionChip(
                          label: 'Marquer commandé',
                          icon: Icons.shopping_cart_outlined,
                          color: AppColors.statusPurchased,
                          onTap: () => _updateStatus('ordered'),
                        ),
                      if (status == 'ordered')
                        _ActionChip(
                          label: 'En livraison',
                          icon: Icons.local_shipping_outlined,
                          color: AppColors.statusTransit,
                          onTap: () => _updateStatus('shipping'),
                        ),
                      if (status == 'shipping')
                        _ActionChip(
                          label: 'Livré',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.statusDelivered,
                          onTap: () => _updateStatus('delivered'),
                        ),
                      if (!['delivered', 'cancelled'].contains(status))
                        _ActionChip(
                          label: 'Annuler',
                          icon: Icons.cancel_outlined,
                          color: AppColors.statusCancelled,
                          onTap: () => _updateStatus('cancelled'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Quote sheet ───────────────────────────────────────────────────────────────

class _QuoteSheet extends ConsumerStatefulWidget {
  final String requestId;
  final VoidCallback onSent;
  const _QuoteSheet({required this.requestId, required this.onSent});

  @override
  ConsumerState<_QuoteSheet> createState() => _QuoteSheetState();
}

class _QuoteSheetState extends ConsumerState<_QuoteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _shipCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _shipCtrl.dispose();
    _feeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _total =>
      (double.tryParse(_priceCtrl.text) ?? 0) +
      (double.tryParse(_shipCtrl.text) ?? 0) +
      (double.tryParse(_feeCtrl.text) ?? 0);

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await GetIt.instance<SupabaseClient>()
          .from('import_requests')
          .update({
            'status': 'quoted',
            'quoted_price': double.tryParse(_priceCtrl.text) ?? 0,
            'shipping_price': double.tryParse(_shipCtrl.text) ?? 0,
            'service_fee': double.tryParse(_feeCtrl.text) ?? 0,
            'total_price': _total,
            if (_notesCtrl.text.trim().isNotEmpty)
              'admin_notes': _notesCtrl.text.trim(),
          })
          .eq('id', widget.requestId);

      widget.onSent();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devis envoyé au client !'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(Tw.s5, Tw.s5, Tw.s5, bottom + Tw.s5),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.send_rounded,
                    color: AppColors.secondary, size: 18),
                const SizedBox(width: 8),
                Text('Envoyer le devis',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900)),
              ],
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: AppTextField(
                  label: 'Prix produit (MRU) *',
                  controller: _priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.price_check_rounded),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Requis' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Transport (MRU) *',
                  controller: _shipCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.local_shipping_outlined),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Requis' : null,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Commission Wagaf (MRU) *',
              controller: _feeCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.percent_rounded),
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Note pour le client (optionnel)',
              controller: _notesCtrl,
              prefixIcon: const Icon(Icons.note_outlined),
              maxLines: 2,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _send(),
            ),
            const SizedBox(height: 16),
            // Total preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total devis',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                  Text(
                    CurrencyFormatter.formatMRU(_total),
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Envoyer le devis au client',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Users Tab
// ─────────────────────────────────────────────────────────────────────────────

class _UsersTab extends ConsumerStatefulWidget {
  const _UsersTab();

  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersRawProvider);

    return Column(
      children: [
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.all(_kPad),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Rechercher un utilisateur…',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.grey400),
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 20, color: AppColors.grey500),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
            ),
          ),
        ),
        Expanded(
          child: usersAsync.when(
            loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Center(
              child: Text('Erreur : $e',
                  style: GoogleFonts.poppins(color: AppColors.error)),
            ),
            data: (users) {
              final filtered = _query.isEmpty
                  ? users
                  : users.where((u) {
                      final q = _query.toLowerCase();
                      return (u['full_name'] as String? ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (u['email'] as String? ?? '')
                              .toLowerCase()
                              .contains(q) ||
                          (u['phone'] as String? ?? '')
                              .toLowerCase()
                              .contains(q);
                    }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_off_outlined,
                          size: 56, color: AppColors.grey400),
                      const SizedBox(height: 12),
                      Text('Aucun utilisateur trouvé',
                          style: GoogleFonts.poppins(
                              color: AppColors.grey500)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(_kPad),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) =>
                    _AdminUserCard(profile: filtered[i])
                        .animate()
                        .fadeIn(delay: (i * 30).ms, duration: 250.ms),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payments Tab
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersRawProvider);

    return ordersAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
        child: Text('Erreur : $e',
            style: GoogleFonts.poppins(color: AppColors.error)),
      ),
      data: (orders) {
        final pending =
            orders.where((o) => o['status'] == 'pending').toList();
        final validated = orders
            .where((o) => o['status'] == 'payment_validated')
            .toList();
        final others = orders
            .where((o) => !['pending', 'payment_validated']
                .contains(o['status']))
            .take(50)
            .toList();

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment_outlined,
                    size: 56, color: AppColors.grey400),
                const SizedBox(height: 12),
                Text('Aucun paiement',
                    style:
                        GoogleFonts.poppins(color: AppColors.grey500)),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(_kPad),
          children: [
            if (pending.isNotEmpty) ...[
              _SectionHeader(
                label:
                    'En attente de validation (${pending.length})',
                badge: pending.length,
              ),
              const SizedBox(height: 8),
              ...pending.map((o) => _PaymentCard(order: o, ref: ref)),
              const SizedBox(height: 16),
            ],
            if (validated.isNotEmpty) ...[
              _SectionHeader(
                label: 'Paiements validés (${validated.length})',
              ),
              const SizedBox(height: 8),
              ...validated
                  .map((o) => _PaymentCard(order: o, ref: ref)),
              const SizedBox(height: 16),
            ],
            if (others.isNotEmpty) ...[
              _SectionHeader(label: 'Historique'),
              const SizedBox(height: 8),
              ...others
                  .map((o) => _PaymentCard(order: o, ref: ref)),
            ],
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifications Tab
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationsTab extends ConsumerStatefulWidget {
  const _NotificationsTab();

  @override
  ConsumerState<_NotificationsTab> createState() =>
      _NotificationsTabState();
}

class _NotificationsTabState extends ConsumerState<_NotificationsTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _type = 'system';
  bool _broadcast = true;
  String? _targetUserId;
  bool _sending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    try {
      if (_broadcast) {
        await adminBroadcastNotification(
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          type: _type,
        );
      } else if (_targetUserId != null) {
        await adminSendNotification(
          userId: _targetUserId!,
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          type: _type,
        );
      }
      _titleCtrl.clear();
      _bodyCtrl.clear();
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification envoyée !'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersRawProvider);

    return ListView(
      padding: const EdgeInsets.all(_kPad),
      children: [
        // ── Create notification form ─────────────────────────────
        Container(
          padding: const EdgeInsets.all(_kPad),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                          Icons.notifications_active_outlined,
                          color: AppColors.primary,
                          size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Créer une notification',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey900),
                    ),
                  ],
                ),
                const SizedBox(height: _kPad),

                // Type selector
                Text('Type',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'system',
                    'order_created',
                    'payment_validated',
                    'order_in_transit',
                    'order_delivered',
                  ]
                      .map((t) => ChoiceChip(
                            label: Text(t,
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500)),
                            selected: _type == t,
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                                color: _type == t
                                    ? AppColors.primary
                                    : AppColors.grey600),
                            onSelected: (_) =>
                                setState(() => _type = t),
                          ))
                      .toList(),
                ),
                const SizedBox(height: _kPad),

                // Broadcast toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _broadcast,
                  onChanged: (v) => setState(() => _broadcast = v),
                  activeColor: AppColors.primary,
                  title: Text(
                    'Envoyer à tous les utilisateurs',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey800),
                  ),
                  subtitle: Text(
                    _broadcast
                        ? 'Diffusion globale'
                        : 'Sélectionner un utilisateur',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.grey500),
                  ),
                ),

                // User selector (if not broadcast)
                if (!_broadcast) ...[
                  const SizedBox(height: 8),
                  usersAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (users) => DropdownButtonFormField<String>(
                      value: _targetUserId,
                      hint: Text('Choisir un utilisateur',
                          style: GoogleFonts.poppins(fontSize: 13)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      items: users
                          .map((u) => DropdownMenuItem(
                                value: u['id'] as String,
                                child: Text(
                                  '${u['full_name'] ?? '—'} · ${u['email'] ?? ''}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _targetUserId = v),
                      validator: (v) => !_broadcast && v == null
                          ? 'Sélectionner un utilisateur'
                          : null,
                    ),
                  ),
                ],

                const SizedBox(height: _kPad),
                AppTextField(
                  label: 'Titre *',
                  controller: _titleCtrl,
                  prefixIcon: const Icon(Icons.title_rounded),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Message *',
                  controller: _bodyCtrl,
                  prefixIcon: const Icon(Icons.message_outlined),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: _kPad),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _sending ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                    label: Text(
                      _sending ? 'Envoi en cours…' : 'Envoyer',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Admin Order Card
// ─────────────────────────────────────────────────────────────────────────────

class _AdminOrderCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;
  const _AdminOrderCard({required this.order});

  @override
  ConsumerState<_AdminOrderCard> createState() => _AdminOrderCardState();
}

class _AdminOrderCardState extends ConsumerState<_AdminOrderCard> {
  bool _expanded = false;

  Map<String, dynamic> get o => widget.order;

  String get status => o['status'] as String? ?? '';
  String get orderNum =>
      (o['order_number'] as String? ?? '').isNotEmpty
          ? o['order_number'] as String
          : (o['id'] as String? ?? '').substring(0, 8);
  String get title =>
      o['product_title'] as String? ?? 'Produit inconnu';
  double get total =>
      (o['total_mru'] as num?)?.toDouble() ?? 0;
  Map? get profile => o['profiles'] as Map?;
  String get clientName =>
      profile?['full_name'] as String? ?? '—';
  String get clientEmail => profile?['email'] as String? ?? '—';

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: statusColor.withValues(alpha: 0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              orderNum,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.grey900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _StatusBadge(status: status),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.grey600),
                        ),
                        Text(
                          '$clientName · $clientEmail',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.formatMRU(total),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        _formatDate(o['created_at'] as String?),
                        style: GoogleFonts.poppins(
                            fontSize: 9, color: AppColors.grey400),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.grey400,
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded details ───────────────────────────────────
          if (_expanded) ...[
            Divider(
                height: 1,
                color: statusColor.withValues(alpha: 0.2)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order details
                  _InfoRow(
                      label: 'Prix produit',
                      value: CurrencyFormatter.formatMRU(
                          (o['product_price_mru'] as num?)
                                  ?.toDouble() ??
                              0)),
                  _InfoRow(
                      label: 'Transport',
                      value: CurrencyFormatter.formatMRU(
                          (o['shipping_fee_mru'] as num?)
                                  ?.toDouble() ??
                              0)),
                  _InfoRow(
                      label: 'Service',
                      value: CurrencyFormatter.formatMRU(
                          (o['service_fee_mru'] as num?)
                                  ?.toDouble() ??
                              0)),
                  if (o['weight_kg'] != null)
                    _InfoRow(
                        label: 'Poids',
                        value: '${o['weight_kg']} kg'),
                  if ((o['admin_notes'] as String?)?.isNotEmpty ==
                      true)
                    _InfoRow(
                        label: 'Notes',
                        value: o['admin_notes'] as String),
                  const SizedBox(height: 10),

                  // Action buttons
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      // Edit
                      _ActionChip(
                        label: 'Modifier',
                        icon: Icons.edit_outlined,
                        color: AppColors.grey700,
                        onTap: () => _showEditSheet(context),
                      ),
                      // Status transitions
                      if (status == 'pending') ...[
                        _ActionChip(
                          label: 'Valider paiement',
                          icon: Icons.check_circle_outline,
                          color: AppColors.statusPayment,
                          onTap: () => _updateStatus(
                              'payment_validated'),
                        ),
                        _ActionChip(
                          label: 'Annuler',
                          icon: Icons.cancel_outlined,
                          color: AppColors.statusCancelled,
                          onTap: () =>
                              _confirmCancel(context),
                        ),
                      ],
                      if (status == 'payment_validated')
                        _ActionChip(
                          label: 'Marquer commandé',
                          icon: Icons.shopping_cart_outlined,
                          color: AppColors.statusPurchased,
                          onTap: () =>
                              _updateStatus('purchased'),
                        ),
                      if (status == 'purchased')
                        _ActionChip(
                          label: 'En transit',
                          icon: Icons.local_shipping_outlined,
                          color: AppColors.statusTransit,
                          onTap: () =>
                              _updateStatus('in_transit'),
                        ),
                      if (status == 'in_transit')
                        _ActionChip(
                          label: 'Arrivé MR',
                          icon: Icons.location_on_outlined,
                          color: AppColors.statusArrived,
                          onTap: () => _updateStatus(
                              'arrived_mauritania'),
                        ),
                      if (status == 'arrived_mauritania')
                        _ActionChip(
                          label: 'Livré ✓',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.statusDelivered,
                          onTap: () =>
                              _updateStatus('delivered'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    final ok = await ref
        .read(ordersProvider.notifier)
        .updateStatus(o['id'] as String, newStatus);
    if (ok) {
      ref.invalidate(adminOrdersRawProvider);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Statut mis à jour : ${_statusLabel(newStatus)}'
          : 'Erreur lors de la mise à jour'),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Annuler la commande',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Confirmer l\'annulation de $orderNum ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Non',
                style: GoogleFonts.poppins(color: AppColors.grey600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              _updateStatus('cancelled');
            },
            child: Text('Annuler la commande',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OrderEditSheet(order: o),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Edit Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _OrderEditSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;
  const _OrderEditSheet({required this.order});

  @override
  ConsumerState<_OrderEditSheet> createState() => _OrderEditSheetState();
}

class _OrderEditSheetState extends ConsumerState<_OrderEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _notesCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _shippingCtrl;
  late final TextEditingController _serviceFeeCtrl;
  bool _saving = false;

  Map<String, dynamic> get o => widget.order;

  @override
  void initState() {
    super.initState();
    _notesCtrl =
        TextEditingController(text: o['admin_notes'] as String? ?? '');
    _weightCtrl = TextEditingController(
        text: o['weight_kg']?.toString() ?? '');
    _shippingCtrl = TextEditingController(
        text: (o['shipping_fee_mru'] as num?)?.toStringAsFixed(0) ??
            '0');
    _serviceFeeCtrl = TextEditingController(
        text: (o['service_fee_mru'] as num?)?.toStringAsFixed(0) ??
            '0');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _weightCtrl.dispose();
    _shippingCtrl.dispose();
    _serviceFeeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final shipping = double.tryParse(_shippingCtrl.text) ?? 0;
    final service = double.tryParse(_serviceFeeCtrl.text) ?? 0;
    final productMru =
        (o['product_price_mru'] as num?)?.toDouble() ?? 0;
    final newTotal = productMru + shipping + service;

    final ok = await ref.read(ordersProvider.notifier).updateDetails(
          o['id'] as String,
          adminNotes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          weightKg: double.tryParse(_weightCtrl.text),
          shippingFeeMru: shipping,
          serviceFeeMru: service,
          totalMru: newTotal,
        );

    setState(() => _saving = false);
    if (ok) ref.invalidate(adminOrdersRawProvider);
    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Commande mise à jour' : 'Erreur'),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(Tw.s5, Tw.s5, Tw.s5, bottom + Tw.s5),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Text(
              'Modifier la commande',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900),
            ),
            const SizedBox(height: 4),
            Text(
              o['order_number'] as String? ?? '',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.grey500),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Notes admin (visibles par le client)',
              controller: _notesCtrl,
              prefixIcon: const Icon(Icons.note_outlined),
              maxLines: 2,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Poids (kg)',
                    controller: _weightCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    prefixIcon: const Icon(Icons.scale_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Transport (MRU)',
                    controller: _shippingCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    prefixIcon:
                        const Icon(Icons.local_shipping_outlined),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Frais de service (MRU)',
              controller: _serviceFeeCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.percent_outlined),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text('Enregistrer',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Admin User Card
// ─────────────────────────────────────────────────────────────────────────────

class _AdminUserCard extends ConsumerWidget {
  final Map<String, dynamic> profile;
  const _AdminUserCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = profile['full_name'] as String? ?? '—';
    final email = profile['email'] as String? ?? '—';
    final role = profile['role'] as String? ?? 'user';
    final status = profile['status'] as String? ?? 'active';
    final totalOrders = profile['total_orders'] as int? ?? 0;
    final totalSpent =
        (profile['total_spent'] as num?)?.toDouble() ?? 0.0;
    final isAdmin = role == 'admin' || role == 'super_admin';
    final isSuspended = status == 'suspended';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuspended
            ? AppColors.errorLight
            : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSuspended
              ? AppColors.error.withValues(alpha: 0.3)
              : isAdmin
                  ? AppColors.secondary.withValues(alpha: 0.4)
                  : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isAdmin
                ? AppColors.secondary.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isAdmin
                    ? AppColors.secondaryDark
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isAdmin)
                      _RoleBadge(role: role),
                    if (isSuspended)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SUSPENDU',
                          style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error),
                        ),
                      ),
                  ],
                ),
                Text(email,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.grey500),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '$totalOrders commandes · ${CurrencyFormatter.formatMRU(totalSpent)}',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.grey600),
                ),
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                size: 18, color: AppColors.grey500),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (action) =>
                _handleAction(context, ref, action),
            itemBuilder: (_) => [
              if (!isSuspended && !isAdmin)
                PopupMenuItem(
                  value: 'suspend',
                  child: Row(
                    children: [
                      const Icon(Icons.block_outlined,
                          size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Suspendre',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.error)),
                    ],
                  ),
                ),
              if (isSuspended)
                PopupMenuItem(
                  value: 'activate',
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text('Réactiver',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.success)),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    const Icon(Icons.copy_outlined,
                        size: 16, color: AppColors.grey600),
                    const SizedBox(width: 8),
                    Text('Copier l\'ID',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.grey700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAction(
      BuildContext context, WidgetRef ref, String action) async {
    if (action == 'copy') {
      Clipboard.setData(
          ClipboardData(text: profile['id'] as String? ?? ''));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID copié dans le presse-papiers')),
      );
      return;
    }

    final newStatus = action == 'suspend' ? 'suspended' : 'active';
    final label = action == 'suspend' ? 'Suspendre' : 'Réactiver';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          '$label le compte de ${profile['full_name'] ?? profile['email']} ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler',
                style:
                    GoogleFonts.poppins(color: AppColors.grey600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: action == 'suspend'
                    ? AppColors.error
                    : AppColors.success),
            onPressed: () => Navigator.pop(context, true),
            child: Text(label,
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await adminSetUserStatus(
          profile['id'] as String, newStatus);
      ref.invalidate(adminUsersRawProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compte ${action == 'suspend' ? 'suspendu' : 'réactivé'}'),
          backgroundColor: action == 'suspend'
              ? AppColors.error
              : AppColors.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Card
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final WidgetRef ref;
  const _PaymentCard({required this.order, required this.ref});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String? ?? '';
    final isPending = status == 'pending';
    final statusColor = _statusColor(status);
    final total =
        (order['total_mru'] as num?)?.toDouble() ?? 0;
    final orderNum = (order['order_number'] as String? ?? '').isNotEmpty
        ? order['order_number'] as String
        : (order['id'] as String? ?? '').substring(0, 8);
    final profile = order['profiles'] as Map?;
    final clientName = profile?['full_name'] as String? ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPending
                  ? Icons.hourglass_empty_rounded
                  : Icons.check_circle_outline,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(orderNum,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900)),
                Text(
                  (order['product_title'] as String? ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.grey500),
                ),
                Text(
                  '$clientName · ${CurrencyFormatter.formatMRU(total)}',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),
          if (isPending)
            GestureDetector(
              onTap: () async {
                final ok = await ref
                    .read(ordersProvider.notifier)
                    .updateStatus(order['id'] as String,
                        'payment_validated');
                if (ok) ref.invalidate(adminOrdersRawProvider);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      ok ? 'Paiement validé !' : 'Erreur'),
                  backgroundColor:
                      ok ? AppColors.success : AppColors.error,
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Valider',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _RevenueCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _RevenueCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.grey900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 10, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.grey900,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 9, color: AppColors.grey500),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _MiniOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _MiniOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String? ?? '';
    final statusColor = _statusColor(status);
    final orderNum =
        (order['order_number'] as String? ?? '').isNotEmpty
            ? order['order_number'] as String
            : (order['id'] as String? ?? '').substring(0, 8);
    final total =
        (order['total_mru'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              orderNum,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900),
            ),
          ),
          Text(
            (order['product_title'] as String? ?? ''),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
                fontSize: 11, color: AppColors.grey500),
          ),
          const SizedBox(width: 8),
          Text(
            CurrencyFormatter.formatMRU(total),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          _StatusBadge(status: status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _statusLabel(status),
        style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.toUpperCase(),
        style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryDark),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Widget? action;
  final int? badge;
  const _SectionHeader({required this.label, this.action, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.grey800),
          ),
        ),
        if (badge != null && badge! > 0)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$badge',
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        if (action != null) action!,
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionChip(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.grey500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
