// Plain Dart class — no code generation needed.
class ImportRequest {
  final String id;
  final String userId;
  final String productUrl;
  final String marketplace;
  final String status;
  final String? notes;
  final String? adminNotes;
  final double? quotedPrice;
  final double? shippingPrice;
  final double? serviceFee;
  final double? totalPrice;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ImportRequest({
    required this.id,
    required this.userId,
    required this.productUrl,
    required this.marketplace,
    required this.status,
    this.notes,
    this.adminNotes,
    this.quotedPrice,
    this.shippingPrice,
    this.serviceFee,
    this.totalPrice,
    required this.createdAt,
    this.updatedAt,
  });

  factory ImportRequest.fromMap(Map<String, dynamic> map) => ImportRequest(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        productUrl: map['product_url'] as String,
        marketplace: map['marketplace'] as String? ?? '',
        status: map['status'] as String? ?? 'pending',
        notes: map['notes'] as String?,
        adminNotes: map['admin_notes'] as String?,
        quotedPrice: (map['quoted_price'] as num?)?.toDouble(),
        shippingPrice: (map['shipping_price'] as num?)?.toDouble(),
        serviceFee: (map['service_fee'] as num?)?.toDouble(),
        totalPrice: (map['total_price'] as num?)?.toDouble(),
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
      );

  ImportRequest copyWith({
    String? status,
    String? adminNotes,
    double? quotedPrice,
    double? shippingPrice,
    double? serviceFee,
    double? totalPrice,
  }) =>
      ImportRequest(
        id: id,
        userId: userId,
        productUrl: productUrl,
        marketplace: marketplace,
        status: status ?? this.status,
        notes: notes,
        adminNotes: adminNotes ?? this.adminNotes,
        quotedPrice: quotedPrice ?? this.quotedPrice,
        shippingPrice: shippingPrice ?? this.shippingPrice,
        serviceFee: serviceFee ?? this.serviceFee,
        totalPrice: totalPrice ?? this.totalPrice,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  bool get hasQuote =>
      status == 'quoted' &&
      quotedPrice != null &&
      shippingPrice != null &&
      serviceFee != null &&
      totalPrice != null;
}

// ── Status helpers ────────────────────────────────────────────────────────────

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

const _marketplaceNames = {
  'aliexpress': 'AliExpress',
  'amazon': 'Amazon',
  'temu': 'Temu',
  'alibaba': 'Alibaba',
  'shein': 'SHEIN',
  'noon': 'Noon',
  'iherb': 'iHerb',
  'jumia': 'Jumia',
  'ebay': 'eBay',
  'etsy': 'Etsy',
};

extension ImportRequestX on ImportRequest {
  String get statusLabel => _statusLabels[status] ?? status;
  String get marketplaceDisplay =>
      _marketplaceNames[marketplace] ?? marketplace.toUpperCase();
  String get shortId => id.length >= 8 ? id.substring(0, 8).toUpperCase() : id;
}
