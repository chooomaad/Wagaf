import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_marketplaces.dart';
import '../../core/theme/app_tw.dart';

// ---------------------------------------------------------------------------
// MarketplaceLogo — inline logo with local asset + icon fallback
// ---------------------------------------------------------------------------

class MarketplaceLogo extends StatelessWidget {
  final Marketplace marketplace;
  final double size;

  const MarketplaceLogo({
    super.key,
    required this.marketplace,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      marketplace.logoAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) =>
          Icon(marketplace.icon, size: size, color: marketplace.bgColor),
    );
  }
}

// ---------------------------------------------------------------------------
// MarketplaceLogoCard — compact card for carousels / chips
// ---------------------------------------------------------------------------

class MarketplaceLogoCard extends StatelessWidget {
  final Marketplace marketplace;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool showTagline;

  const MarketplaceLogoCard({
    super.key,
    required this.marketplace,
    this.onTap,
    this.width = 100,
    this.height = 68,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = showTagline ? 22.0 : 26.0;
    final logoSize = showTagline ? 32.0 : 36.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: marketplace.bgColor,
          borderRadius: Tw.radiusLg,
          boxShadow: Tw.shadowSm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              marketplace.logoAsset,
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => Icon(
                marketplace.icon,
                color: marketplace.textColor,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                marketplace.name,
                style: GoogleFonts.poppins(
                  fontSize: Tw.textXs,
                  fontWeight: FontWeight.w700,
                  color: marketplace.textColor,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showTagline)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  marketplace.tagline,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: marketplace.textColor.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MarketplaceFeatureCard — large card for detail / selection screens
// ---------------------------------------------------------------------------

class MarketplaceFeatureCard extends StatelessWidget {
  final Marketplace marketplace;
  final VoidCallback? onTap;

  const MarketplaceFeatureCard({
    super.key,
    required this.marketplace,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(Tw.s4),
        decoration: BoxDecoration(
          color: marketplace.bgColor,
          borderRadius: Tw.radiusXl,
          boxShadow: Tw.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              marketplace.logoAsset,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) =>
                  Icon(marketplace.icon, color: marketplace.textColor, size: 32),
            ),
            const SizedBox(height: Tw.s2),
            Text(
              marketplace.name,
              style: GoogleFonts.poppins(
                fontSize: Tw.textBase,
                fontWeight: FontWeight.w700,
                color: marketplace.textColor,
              ),
            ),
            Text(
              marketplace.tagline,
              style: GoogleFonts.poppins(
                fontSize: Tw.textXs,
                color: marketplace.textColor.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
