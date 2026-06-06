import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_marketplaces.dart';
import '../../../../core/theme/app_tw.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../providers/requests_provider.dart';

class RequestSubmitScreen extends ConsumerStatefulWidget {
  const RequestSubmitScreen({super.key});

  @override
  ConsumerState<RequestSubmitScreen> createState() =>
      _RequestSubmitScreenState();
}

class _RequestSubmitScreenState extends ConsumerState<RequestSubmitScreen> {
  final _notesCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _url => ref.read(searchProvider).currentUrl;
  String get _marketplace => Validators.detectPlatform(_url);

  Marketplace? get _mp => AppMarketplaces.byCode(_marketplace);

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _submitting = true);

    final request = await ref.read(requestsProvider.notifier).createRequest(
          userId: user.id,
          productUrl: _url,
          marketplace: _marketplace,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (request != null) {
      context.pushReplacement('/request-confirmation', extra: request);
    } else {
      final err = ref.read(requestsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Une erreur est survenue. Réessayez.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mp = _mp;

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
          'Nouvelle demande',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.grey200),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Tw.s4),
        children: [
          // ── URL Card ────────────────────────────────────────────────────
          _UrlCard(url: _url, mp: mp).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: Tw.s4),

          // ── Process info card ───────────────────────────────────────────
          _InfoCard().animate().fadeIn(delay: 60.ms, duration: 300.ms),

          const SizedBox(height: Tw.s4),

          // ── Notes field ─────────────────────────────────────────────────
          _NotesCard(controller: _notesCtrl)
              .animate()
              .fadeIn(delay: 120.ms, duration: 300.ms),

          const SizedBox(height: Tw.s4),

          // ── Privacy note ────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 13, color: AppColors.grey400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Votre lien est traité de façon confidentielle et sécurisée.',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: AppColors.grey400),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 100),
        ],
      ),

      // ── Bottom CTA ────────────────────────────────────────────────────────
      bottomSheet: Container(
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
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Envoyer la demande',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── URL preview card ──────────────────────────────────────────────────────────

class _UrlCard extends StatelessWidget {
  final String url;
  final Marketplace? mp;

  const _UrlCard({required this.url, required this.mp});

  @override
  Widget build(BuildContext context) {
    final color = mp?.bgColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(Tw.s4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Tw.r2xl),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.link_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Produit identifié',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                    if (mp != null)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: color.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          mp!.name,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded,
                    size: 16, color: AppColors.grey400),
                tooltip: 'Copier le lien',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lien copié'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: Tw.s3, vertical: Tw.s2),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              url,
              style: GoogleFonts.sourceCodePro(
                fontSize: 11,
                color: AppColors.grey700,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Process info card ─────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.price_check_rounded, 'Le prix du produit'),
      (Icons.local_shipping_outlined, 'Les frais de transport'),
      (Icons.percent_rounded, 'Les frais de service Wagaf'),
      (Icons.schedule_rounded, 'Le délai estimé de livraison'),
    ];

    return Container(
      padding: const EdgeInsets.all(Tw.s4),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(Tw.r2xl),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.primary, size: 17),
              const SizedBox(width: 8),
              Text(
                'Ce que vous recevrez',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Notre équipe va analyser votre produit et vous enverra un devis complet incluant :',
            style: GoogleFonts.poppins(
                fontSize: 11.5, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(item.$1,
                      size: 14,
                      color: AppColors.primary.withValues(alpha: 0.7)),
                  const SizedBox(width: 8),
                  Text(
                    item.$2,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notes field card ──────────────────────────────────────────────────────────

class _NotesCard extends StatelessWidget {
  final TextEditingController controller;

  const _NotesCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Tw.s4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Tw.r2xl),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded,
                  color: AppColors.grey600, size: 18),
              const SizedBox(width: 8),
              Text(
                'Remarques (optionnel)',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 3,
            minLines: 2,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey800),
            decoration: InputDecoration(
              hintText:
                  'Couleur, taille, variante spécifique, commentaires…',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.grey400),
              filled: true,
              fillColor: AppColors.grey100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
