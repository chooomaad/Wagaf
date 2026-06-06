// Plain Dart class — no Freezed, full snake_case Supabase support.
class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? city;
  final String? address;
  final String? avatarUrl;
  final String role;
  final String status;
  final String? fcmToken;
  final String preferredLanguage;
  final int totalOrders;
  final double totalSpent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.city,
    this.address,
    this.avatarUrl,
    this.role = 'user',
    this.status = 'active',
    this.fcmToken,
    this.preferredLanguage = 'fr',
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  /// Construct from Supabase snake_case response.
  factory UserModel.fromSupabase(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
      status: json['status'] as String? ?? 'active',
      fcmToken: json['fcm_token'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'fr',
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? city,
    String? address,
    String? avatarUrl,
    String? role,
    String? status,
    String? fcmToken,
    String? preferredLanguage,
    int? totalOrders,
    double? totalSpent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      fcmToken: fcmToken ?? this.fcmToken,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
