import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_marketplaces.dart';

// Re-export so consumers only need to import this file.
export '../../core/constants/app_marketplaces.dart' show Marketplace, AppMarketplaces;

// ── Card ──────────────────────────────────────────────────────────────────────

class MarketplaceCard extends StatefulWidget {
  final Marketplace item;
  final double width;
  final double height;

  const MarketplaceCard({
    super.key,
    required this.item,
    this.width = 88,
    this.height = 76,
  });

  @override
  State<MarketplaceCard> createState() => _MarketplaceCardState();
}

class _MarketplaceCardState extends State<MarketplaceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scale;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 220),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  Future<void> _launch() async {
    final uri = Uri.parse(widget.item.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = widget.item.bgColor;

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _launch,
            onHighlightChanged: (on) =>
                on ? _scale.reverse() : _scale.forward(),
            splashColor: brandColor.withValues(alpha: 0.14),
            highlightColor: brandColor.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                widget.item.logoAsset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) =>
                    _PlaceholderLogo(item: widget.item),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Placeholder shown until real logo is added ────────────────────────────────

class _PlaceholderLogo extends StatelessWidget {
  final Marketplace item;

  const _PlaceholderLogo({required this.item});

  @override
  Widget build(BuildContext context) {
    final initials = item.name.length >= 2
        ? item.name.substring(0, 2).toUpperCase()
        : item.name.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            item.bgColor.withValues(alpha: 0.16),
            item.bgColor.withValues(alpha: 0.07),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: item.bgColor,
            height: 1,
          ),
        ),
      ),
    );
  }
}
