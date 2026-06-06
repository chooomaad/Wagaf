// Plain Dart class — mirrors UserModel but lives in the domain layer.
class UserEntity {
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

  const UserEntity({
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

  bool get isAdmin => role == 'admin' || role == 'super_admin';
  String get displayName => fullName?.isNotEmpty == true ? fullName! : email.split('@').first;
  String get firstName => displayName.split(' ').first;

  UserEntity copyWith({
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
    return UserEntity(
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
      other is UserEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
