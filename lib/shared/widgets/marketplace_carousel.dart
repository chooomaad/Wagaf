import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tw.dart';
import 'marketplace_card.dart';

// ---------------------------------------------------------------------------
// MarketplaceCarousel — infinite auto-scrolling horizontal marquee
// ---------------------------------------------------------------------------
//
// Usage:
//   MarketplaceCarousel()                     // all 12 default marketplaces
//   MarketplaceCarousel(title: 'Nos marchés') // with section header
//   MarketplaceCarousel(items: myList)        // custom subset
//
// The marquee runs continuously at ~60 FPS driven by an AnimationController.
// On web / desktop it pauses on mouse-hover and resumes seamlessly.
// If a logo asset is missing, an elegant branded placeholder is shown.
// ---------------------------------------------------------------------------

class MarketplaceCarousel extends StatefulWidget {
  final List<Marketplace> items;
  final double cardWidth;
  final double cardHeight;
  final double spacing;
  final Duration duration;
  final String? title;
  final EdgeInsetsGeometry padding;

  const MarketplaceCarousel({
    super.key,
    this.items = AppMarketplaces.all,
    this.cardWidth = 88,
    this.cardHeight = 76,
    this.spacing = 12,
    this.duration = const Duration(seconds: 34),
    this.title,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  State<MarketplaceCarousel> createState() => _MarketplaceCarouselState();
}

class _MarketplaceCarouselState extends State<MarketplaceCarousel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _offset;

  double get _itemStep => widget.cardWidth + widget.spacing;
  double get _listWidth => _itemStep * widget.items.length;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: widget.duration, vsync: this);
    _offset = Tween<double>(begin: 0, end: -_listWidth).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
    _startLoop();
  }

  // Run to end then restart from 0 — creates a seamless infinite loop.
  void _startLoop() {
    _ctrl.forward(from: _ctrl.value).then((_) {
      if (mounted) {
        _ctrl.value = 0;
        _startLoop();
      }
    });
  }

  // Pause at current position (hover on desktop/web).
  void _pause() => _ctrl.stop();

  // Resume from exact paused position.
  void _resume() {
    if (mounted && !_ctrl.isAnimating) {
      final remaining = Duration(
        milliseconds:
            ((1.0 - _ctrl.value) * widget.duration.inMilliseconds).round(),
      );
      _ctrl
          .animateTo(1.0, duration: remaining, curve: Curves.linear)
          .then((_) {
        if (mounted) {
          _ctrl.value = 0;
          _startLoop();
        }
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    final scale = sw > 900 ? 1.15 : sw > 600 ? 1.07 : 1.0;
    final cardW = widget.cardWidth * scale;
    final cardH = widget.cardHeight * scale;

    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title != null) _SectionTitle(title: widget.title!),
          MouseRegion(
            onEnter: (_) => _pause(),
            onExit: (_) => _resume(),
            // Extra height for card shadows (top + bottom).
            child: SizedBox(
              height: cardH + 12,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _offset,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(_offset.value, 0),
                    child: child,
                  ),
                  // OverflowBox lets the Row be as wide as it needs —
                  // ClipRect handles the visual clipping.
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ..._row(cardW, cardH, 0),
                        ..._row(cardW, cardH, 1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _row(double w, double h, int copy) {
    return widget.items.indexed.map((e) {
      final (i, item) = e;
      return Padding(
        key: ValueKey('mp-$copy-$i'),
        padding: EdgeInsets.only(right: widget.spacing, top: 4, bottom: 4),
        child: MarketplaceCard(
          key: ValueKey('card-$copy-${item.code}'),
          item: item,
          width: w,
          height: h,
        ),
      );
    }).toList();
  }
}

// ---------------------------------------------------------------------------
// MarketplacesSection — full home-screen section (title + two-row marquee)
// ---------------------------------------------------------------------------
//
// Displays two offset rows for a staggered Pinterest-style look.
// The onTap callback receives the tapped Marketplace for navigation.
// ---------------------------------------------------------------------------

class MarketplacesSection extends StatelessWidget {
  final void Function(Marketplace)? onTap;

  const MarketplacesSection({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Tw.s6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marchés supportés',
                    style: GoogleFonts.poppins(
                      fontSize: Tw.textLg,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey900,
                    ),
                  ),
                  Text(
                    '${AppMarketplaces.all.length} plateformes mondiales',
                    style: GoogleFonts.poppins(
                      fontSize: Tw.textXs,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Tw.s3,
                  vertical: Tw.s1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: Tw.radiusFull,
                ),
                child: Text(
                  '+ à venir',
                  style: GoogleFonts.poppins(
                    fontSize: Tw.textXs,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: Tw.s3),

        // ── Row 1 — items 0–9 ─────────────────────────────────────────────
        MarketplaceCarousel(
          items: AppMarketplaces.all,
          cardWidth: 92,
          cardHeight: 78,
          spacing: 14,
          duration: const Duration(seconds: 34),
        ),

        const SizedBox(height: Tw.s3),

        // ── Row 2 — shifted by 5 for staggered look ───────────────────────
        MarketplaceCarousel(
          items: [
            ...AppMarketplaces.all.skip(5),
            ...AppMarketplaces.all.take(5),
          ],
          cardWidth: 92,
          cardHeight: 78,
          spacing: 14,
          duration: const Duration(seconds: 40),
        ),
      ],
    );
  }
}

// ── Section title with accent bar ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
            ),
          ),
        ],
      ),
    );
  }
}
