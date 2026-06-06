import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tw.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/import_request_entity.dart';
import '../providers/requests_provider.dart';

class RequestDetailScreen extends ConsumerStatefulWidget {
  final ImportRequest request;
  const RequestDetailScreen({super.key, required this.request});

  @override
  ConsumerState<RequestDetailScreen> createState() =>
      _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  late ImportRequest _request;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
  }

  Future<void> _openUrl() async {
    final uri = Uri.parse(_request.productUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _acceptQuote() async {
    setState(() => _acting = true);
    final ok =
        await ref.read(requestsProvider.notifier).acceptQuote(_request.id);
    if (!mounted) return;
    setState(() => _acting = false);
    if (ok) {
      setState(() => _request = _request.copyWith(status: 'approved'));
      _showSnack('Devis accepté ! Notre équipe va procéder à la commande.', true);
    } else {
      _showSnack('Erreur. Veuillez réessayer.', false);
    }
  }

  Future<void> _refuseQuote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Refuser le devis',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Êtes-vous sûr de vouloir refuser ce devis ? La demande sera annulée.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('Annuler', style: GoogleFonts.poppins(color: AppColors.grey600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Refuser',
                style:
                    GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _acting = true);
    final ok =
        await ref.read(requestsProvider.notifier).cancelRequest(_request.id);
    if (!mounted) return;
    setState(() => _acting = false);
    if (ok) {
      setState(() => _request = _request.copyWith(status: 'cancelled'));
      _showSnack('Demande annulée.', true);
    }
  }

  void _showSnack(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      backgroundColor: success ? AppColors.success : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(_request.status);

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
          'Réf. ${_request.shortId}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: Tw.s4),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _request.statusLabel,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.grey200),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Tw.s4),
        children: [
          // ── URL card ───────────────────────────────────────────────────
          _UrlCard(request: _request, onOpen: _openUrl)
              .animate()
              .fadeIn(duration: 300.ms),

          const SizedBox(height: Tw.s3),

          // ── Metadata card ──────────────────────────────────────────────
          _MetaCard(request: _request)
              .animate()
              .fadeIn(delay: 60.ms, duration: 300.ms),

          const SizedBox(height: Tw.s3),

          // ── Progress timeline ──────────────────────────────────────────
          _ProgressTimeline(status: _request.status)
              .animate()
              .fadeIn(delay: 120.ms, duration: 300.ms),

          const SizedBox(height: Tw.s3),

          // ── Quote card (shown when status == quoted or later) ──────────
          if (_request.hasQuote || _request.status == 'approved') ...[
            _QuoteCard(request: _request)
                .animate()
                .fadeIn(delay: 180.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: Tw.s3),
          ],

          // ── Admin note ─────────────────────────────────────────────────
          if (_request.adminNotes?.isNotEmpty == true) ...[
            _AdminNoteCard(note: _request.adminNotes!)
                .animate()
                .fadeIn(delay: 220.ms, duration: 300.ms),
            const SizedBox(height: Tw.s3),
          ],

          const SizedBox(height: 80),
        ],
      ),

      // ── Accept / Refuse buttons (only when quoted) ────────────────────────
      bottomSheet: _request.status == 'quoted'
          ? _QuoteActions(
              acting: _acting,
              onAccept: _acceptQuote,
              onRefuse: _refuseQuote,
            )
          : null,
    );
  }
}

// ── URL card ──────────────────────────────────────────────────────────────────

class _UrlCard extends StatelessWidget {
  final ImportRequest request;
  final VoidCallback onOpen;
  const _UrlCard({required this.request, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Tw.s4),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link_rounded,
                  size: 16, color: AppColors.grey500),
              const SizedBox(width: 8),
              Text(
                'Lien du produit',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey600),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onOpen,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.open_in_new_rounded,
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Ouvrir',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: request.productUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Lien copié'),
                    duration: Duration(seconds: 1)),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: Tw.s3, vertical: Tw.s2),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                request.productUrl,
                style: GoogleFonts.sourceCodePro(
                    fontSize: 11, color: AppColors.grey700),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Metadata card ─────────────────────────────────────────────────────────────

class _MetaCard extends StatelessWidget {
  final ImportRequest request;
  const _MetaCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Tw.s4),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _Row('Marketplace', request.marketplaceDisplay),
          _Row('Date de soumission',
              DateFormat('dd/MM/yyyy à HH:mm')
                  .format(request.createdAt.toLocal())),
          if (request.notes?.isNotEmpty == true)
            _Row('Remarques', request.notes!),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.grey500)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey800)),
          ),
        ],
      ),
    );
  }
}

// ── Progress timeline ─────────────────────────────────────────────────────────

class _ProgressTimeline extends StatelessWidget {
  final String status;
  const _ProgressTimeline({required this.status});

  static const _steps = [
    ('pending', 'Demande reçue'),
    ('analysing', 'Analyse du produit'),
    ('quoted', 'Devis envoyé'),
    ('approved', 'Devis accepté'),
    ('ordered', 'Commande passée'),
    ('shipping', 'En livraison'),
    ('delivered', 'Livré'),
  ];

  static const _order = [
    'pending', 'analysing', 'quoted', 'approved',
    'ordered', 'shipping', 'delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _order.indexOf(status);

    return Container(
      padding: const EdgeInsets.all(Tw.s4),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progression',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey800)),
          const SizedBox(height: 12),
          ..._steps.indexed.map((entry) {
            final (i, step) = entry;
            final (code, label) = step;
            final stepIdx = _order.indexOf(code);
            final isDone = currentIdx >= stepIdx;
            final isCurrent = currentIdx == stepIdx;
            final isLast = i == _steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? (isCurrent
                                ? AppColors.primary
                                : AppColors.success.withValues(alpha: 0.15))
                            : AppColors.grey100,
                        border: Border.all(
                          color: isDone
                              ? (isCurrent
                                  ? AppColors.primary
                                  : AppColors.success)
                              : AppColors.grey300,
                          width: 1.5,
                        ),
                      ),
                      child: isDone
                          ? Icon(
                              isCurrent
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.check_rounded,
                              size: 11,
                              color: isCurrent
                                  ? AppColors.primary
                                  : AppColors.success,
                            )
                          : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 1.5,
                        height: 24,
                        color: isDone
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.grey200,
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 24),
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w400,
                      color: isDone
                          ? (isCurrent
                              ? AppColors.primary
                              : AppColors.grey800)
                          : AppColors.grey400,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Quote card ────────────────────────────────────────────────────────────────

class _QuoteCard extends StatelessWidget {
  final ImportRequest request;
  const _QuoteCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final r = request;
    return Container(
      padding: const EdgeInsets.all(Tw.s4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Tw.r2xl),
        border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_outlined,
                    color: AppColors.secondaryDark, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Votre devis',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
          const SizedBox(height: Tw.s3),
          const Divider(),
          const SizedBox(height: Tw.s2),
          _PriceLine('Prix produit',
              CurrencyFormatter.formatMRU(r.quotedPrice ?? 0)),
          _PriceLine('Frais de transport',
              CurrencyFormatter.formatMRU(r.shippingPrice ?? 0)),
          _PriceLine('Commission Wagaf',
              CurrencyFormatter.formatMRU(r.serviceFee ?? 0)),
          const SizedBox(height: Tw.s2),
          const Divider(),
          const SizedBox(height: Tw.s2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total à payer',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey900)),
              Text(
                CurrencyFormatter.formatMRU(r.totalPrice ?? 0),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  const _PriceLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.grey600)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey800)),
        ],
      ),
    );
  }
}

// ── Admin note card ───────────────────────────────────────────────────────────

class _AdminNoteCard extends StatelessWidget {
  final String note;
  const _AdminNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Tw.s4),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(Tw.r2xl),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.note_outlined, size: 16, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Note de notre équipe',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.info)),
                const SizedBox(height: 4),
                Text(note,
                    style: GoogleFonts.poppins(
                        fontSize: 12.5, color: AppColors.grey800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Accept / Refuse bottom sheet ──────────────────────────────────────────────

class _QuoteActions extends StatelessWidget {
  final bool acting;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  const _QuoteActions({
    required this.acting,
    required this.onAccept,
    required this.onRefuse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: Tw.s4,
        right: Tw.s4,
        top: Tw.s3,
        bottom: MediaQuery.of(context).padding.bottom + Tw.s3,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Voulez-vous accepter ce devis ?',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: Tw.s3),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: acting ? null : onRefuse,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Refuser',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: Tw.s3),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: acting ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: acting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Accepter le devis',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

BoxDecoration _cardDecoration() => BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(Tw.r2xl),
      border: Border.all(color: AppColors.grey200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

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
