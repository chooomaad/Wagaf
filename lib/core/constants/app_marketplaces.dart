import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Marketplace brand registry
// Logo files live in assets/marketplaces/{code}.png
// If a file is absent the widget falls back to a branded placeholder.
// ---------------------------------------------------------------------------

class Marketplace {
  final String code;
  final String name;
  final String url;
  final Color bgColor;
  final Color textColor;
  final String tagline;
  final IconData icon;

  const Marketplace({
    required this.code,
    required this.name,
    required this.url,
    required this.bgColor,
    required this.textColor,
    required this.tagline,
    required this.icon,
  });

  /// Local asset path — drop a PNG here to replace the placeholder instantly.
  String get logoAsset => 'assets/marketplaces/$code.png';
}

abstract final class AppMarketplaces {
  static const List<Marketplace> all = [
    Marketplace(
      code: 'aliexpress',
      name: 'AliExpress',
      url: 'https://www.aliexpress.com',
      bgColor: Color(0xFFFF4747),
      textColor: Color(0xFFFFFFFF),
      tagline: 'Chine → Monde',
      icon: Icons.shopping_bag_outlined,
    ),
    Marketplace(
      code: 'amazon',
      name: 'Amazon',
      url: 'https://www.amazon.com',
      bgColor: Color(0xFF232F3E),
      textColor: Color(0xFFFF9900),
      tagline: 'USA → Monde',
      icon: Icons.local_shipping_outlined,
    ),
    Marketplace(
      code: 'temu',
      name: 'Temu',
      url: 'https://www.temu.com',
      bgColor: Color(0xFFFB6107),
      textColor: Color(0xFFFFFFFF),
      tagline: 'Prix ultra bas',
      icon: Icons.discount_outlined,
    ),
    Marketplace(
      code: 'alibaba',
      name: 'Alibaba',
      url: 'https://www.alibaba.com',
      bgColor: Color(0xFFFF6A00),
      textColor: Color(0xFFFFFFFF),
      tagline: 'Gros & Pro',
      icon: Icons.factory_outlined,
    ),
    Marketplace(
      code: 'shein',
      name: 'SHEIN',
      url: 'https://www.shein.com',
      bgColor: Color(0xFF222222),
      textColor: Color(0xFFE74C8B),
      tagline: 'Mode & tendance',
      icon: Icons.checkroom_outlined,
    ),
    Marketplace(
      code: 'noon',
      name: 'Noon',
      url: 'https://www.noon.com',
      bgColor: Color(0xFFFEEE00),
      textColor: Color(0xFF1A1A1A),
      tagline: 'Golfe & Moyen-Orient',
      icon: Icons.wb_sunny_outlined,
    ),
    Marketplace(
      code: 'iherb',
      name: 'iHerb',
      url: 'https://www.iherb.com',
      bgColor: Color(0xFF52A629),
      textColor: Color(0xFFFFFFFF),
      tagline: 'Santé & Bio',
      icon: Icons.eco_outlined,
    ),
    Marketplace(
      code: 'jumia',
      name: 'Jumia',
      url: 'https://www.jumia.com',
      bgColor: Color(0xFFF68B1E),
      textColor: Color(0xFFFFFFFF),
      tagline: 'Afrique',
      icon: Icons.public_outlined,
    ),
    Marketplace(
      code: 'ebay',
      name: 'eBay',
      url: 'https://www.ebay.com',
      bgColor: Color(0xFF1B1B1B),
      textColor: Color(0xFFE53238),
      tagline: 'Neuf & Occasion',
      icon: Icons.gavel_outlined,
    ),
    Marketplace(
      code: 'etsy',
      name: 'Etsy',
      url: 'https://www.etsy.com',
      bgColor: Color(0xFFF1641E),
      textColor: Color(0xFFFFFFFF),
      tagline: 'Artisanat & Vintage',
      icon: Icons.palette_outlined,
    ),
  ];

  static Marketplace? byCode(String code) {
    try {
      return all.firstWhere((m) => m.code == code);
    } catch (_) {
      return null;
    }
  }
}
