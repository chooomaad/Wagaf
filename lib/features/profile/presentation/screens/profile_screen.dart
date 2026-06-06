import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_tw.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Loyalty tier derived from total spent
    final tier = _loyaltyTier(user.totalSpent);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.white, size: 22),
                onPressed: () => _showEditDialog(context, ref),
                tooltip: 'Modifier le profil',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(
                  user: user, tier: tier, isAdmin: isAdmin),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Tw.s4),

                // ── Stats cards ──────────────────────────────────────
                _StatsRow(user: user).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: Tw.s5),

                // ── Info cards ───────────────────────────────────────
                _InfoSection(user: user)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: Tw.s5),

                // ── Loyalty ─────────────────────────────────────────
                _LoyaltyCard(tier: tier, spent: user.totalSpent)
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms),
                const SizedBox(height: Tw.s5),

                // ── Menu ────────────────────────────────────────────
                _MenuSection(
                  items: [
                    _MenuItem(
                      icon: Icons.receipt_long_outlined,
                      label: 'Mes commandes',
                      onTap: () => context.push('/orders'),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.help_outline,
                      label: 'Aide & Support',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.language_outlined,
                      label: 'Langue / Language / اللغة',
                      onTap: () => _showLanguagePicker(context, ref),
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      label: context.l10n.about,
                      onTap: () {},
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                if (isAdmin) ...[
                  const SizedBox(height: Tw.s4),
                  _MenuSection(
                    title: 'Administration',
                    items: [
                      _MenuItem(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Dashboard Admin',
                        onTap: () => context.push('/admin'),
                        color: AppColors.secondary,
                      ),
                    ],
                  ).animate().fadeIn(delay: 220.ms),
                ],

                const SizedBox(height: Tw.s5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Tw.s4),
                  child: AppButton(
                    label: 'Se déconnecter',
                    onPressed: () async {
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) context.go('/login');
                    },
                    isOutlined: true,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: Tw.s10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.read(localeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(Tw.r3xl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: Tw.radiusFull,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.changeLanguage,
                style: GoogleFonts.poppins(
                  fontSize: Tw.textLg,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
              const SizedBox(height: 16),
              ...[
                ('fr', '🇫🇷', 'Français'),
                ('ar', '🇲🇷', 'العربية'),
                ('en', '🇬🇧', 'English'),
              ].map((item) {
                final selected = current.languageCode == item.$1;
                return ListTile(
                  leading: Text(item.$2, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    item.$3,
                    style: GoogleFonts.poppins(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected ? AppColors.primary : AppColors.grey800,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(Locale(item.$1));
                    Navigator.of(context).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(ref: ref, user: user),
    );
  }

  static _LoyaltyTierInfo _loyaltyTier(double spent) {
    if (spent >= 100000) {
      return const _LoyaltyTierInfo('Premium', Color(0xFF6C63FF),
          Icons.diamond_outlined, 'Client VIP — avantages exclusifs');
    } else if (spent >= 50000) {
      return const _LoyaltyTierInfo('Gold', Color(0xFFD4AF37),
          Icons.star_rounded, 'Livraison prioritaire incluse');
    } else if (spent >= 20000) {
      return const _LoyaltyTierInfo('Silver', Color(0xFF9E9E9E),
          Icons.verified_outlined, '5% de réduction sur les frais');
    }
    return const _LoyaltyTierInfo('Bronze', Color(0xFFCD7F32),
        Icons.workspace_premium_outlined, 'Bienvenue chez Wagaf !');
  }
}

// ── Data holders ──────────────────────────────────────────────────────────────

class _LoyaltyTierInfo {
  final String name;
  final Color color;
  final IconData icon;
  final String perk;
  const _LoyaltyTierInfo(this.name, this.color, this.icon, this.perk);
}

// ── Profile Header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  final _LoyaltyTierInfo tier;
  final bool isAdmin;
  const _ProfileHeader(
      {required this.user, required this.tier, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF006B3F), Color(0xFF003D24)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Avatar
            CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      (user.fullName?.isNotEmpty == true
                              ? user.fullName![0]
                              : user.email[0])
                          .toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: Tw.s3),
            // Name
            Text(
              user.fullName ?? user.email.split('@').first,
              style: GoogleFonts.poppins(
                fontSize: Tw.textXl,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              user.email,
              style: GoogleFonts.poppins(
                fontSize: Tw.textXs,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: Tw.s3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loyalty badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Tw.s3, vertical: Tw.s1),
                  decoration: BoxDecoration(
                    color: tier.color.withValues(alpha: 0.25),
                    borderRadius: Tw.radiusFull,
                    border: Border.all(
                        color: tier.color.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tier.icon, color: tier.color, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        tier.name,
                        style: GoogleFonts.poppins(
                          fontSize: Tw.textXs,
                          fontWeight: FontWeight.w700,
                          color: tier.color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: Tw.s2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Tw.s3, vertical: Tw.s1),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      borderRadius: Tw.radiusFull,
                    ),
                    child: Text(
                      'ADMIN',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends ConsumerWidget {
  final dynamic user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);

    // Real stats from orders
    final orders = ordersState.orders;
    final inTransit =
        orders.where((o) => o.status == 'in_transit').length;
    final delivered =
        orders.where((o) => o.status == 'delivered').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Tw.s4),
      child: Row(
        children: [
          _StatCard(
            label: 'Commandes',
            value: '${user.totalOrders}',
            icon: Icons.receipt_long_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: Tw.s3),
          _StatCard(
            label: 'En transit',
            value: '$inTransit',
            icon: Icons.local_shipping_outlined,
            color: AppColors.statusTransit,
          ),
          const SizedBox(width: Tw.s3),
          _StatCard(
            label: 'Livrés',
            value: '$delivered',
            icon: Icons.check_circle_outline,
            color: AppColors.statusDelivered,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(Tw.s3),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: Tw.radiusXl,
          border: Border.all(color: AppColors.grey200),
          boxShadow: Tw.shadowSm,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: Tw.s1),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: Tw.textLg,
                fontWeight: FontWeight.w800,
                color: AppColors.grey900,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Section ──────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final dynamic user;
  const _InfoSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final items = <_InfoItem>[
      if (user.phone != null && user.phone!.isNotEmpty)
        _InfoItem(
            icon: Icons.phone_outlined, label: 'Téléphone', value: user.phone!),
      if (user.city != null && user.city!.isNotEmpty)
        _InfoItem(
            icon: Icons.location_city_outlined,
            label: 'Ville',
            value: user.city!),
      if (user.address != null && user.address!.isNotEmpty)
        _InfoItem(
            icon: Icons.home_outlined,
            label: 'Adresse',
            value: user.address!),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Tw.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations',
            style: GoogleFonts.poppins(
              fontSize: Tw.textBase,
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: Tw.s3),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: Tw.radiusXl,
              border: Border.all(color: AppColors.grey200),
              boxShadow: Tw.shadowSm,
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: Tw.radiusMd,
                        ),
                        child: Icon(item.icon,
                            color: AppColors.primary, size: 18),
                      ),
                      title: Text(
                        item.label,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.grey500,
                        ),
                      ),
                      subtitle: Text(
                        item.value,
                        style: GoogleFonts.poppins(
                          fontSize: Tw.textSm,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                      ),
                    ),
                    if (i < items.length - 1)
                      const Divider(
                          height: 1, indent: Tw.s5, endIndent: Tw.s4),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: Tw.s3),
          // Total spent
          Container(
            padding: const EdgeInsets.all(Tw.s4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFDF8E8), Color(0xFFFAF3D0)],
              ),
              borderRadius: Tw.radiusXl,
              border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.secondaryDark, size: 22),
                const SizedBox(width: Tw.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total dépensé',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.grey500,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatMRU(user.totalSpent),
                        style: GoogleFonts.poppins(
                          fontSize: Tw.textLg,
                          fontWeight: FontWeight.w800,
                          color: AppColors.grey900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({required this.icon, required this.label, required this.value});
}

// ── Loyalty Card ──────────────────────────────────────────────────────────────

class _LoyaltyCard extends StatelessWidget {
  final _LoyaltyTierInfo tier;
  final double spent;
  const _LoyaltyCard({required this.tier, required this.spent});

  static const _tiers = [0.0, 20000.0, 50000.0, 100000.0];
  static const _tierNames = ['Bronze', 'Silver', 'Gold', 'Premium'];

  @override
  Widget build(BuildContext context) {
    final nextThreshold = _tiers.firstWhere(
      (t) => t > spent,
      orElse: () => spent,
    );
    final progress = nextThreshold > 0
        ? (spent / nextThreshold).clamp(0.0, 1.0)
        : 1.0;
    final isMax = spent >= 100000;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Tw.s4),
      child: Container(
        padding: const EdgeInsets.all(Tw.s4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: Tw.radius2xl,
          border: Border.all(color: tier.color.withValues(alpha: 0.3)),
          boxShadow: Tw.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(tier.icon, color: tier.color, size: 24),
                const SizedBox(width: Tw.s2),
                Text(
                  'Fidélité ${tier.name}',
                  style: GoogleFonts.poppins(
                    fontSize: Tw.textBase,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Tw.s2),
            Text(
              tier.perk,
              style: GoogleFonts.poppins(
                  fontSize: Tw.textXs, color: AppColors.grey600),
            ),
            const SizedBox(height: Tw.s3),
            ClipRRect(
              borderRadius: Tw.radiusFull,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(tier.color),
              ),
            ),
            const SizedBox(height: Tw.s2),
            if (!isMax)
              Text(
                '${CurrencyFormatter.formatMRU(spent)} / ${CurrencyFormatter.formatMRU(nextThreshold)} → ${_tierNames[_tiers.indexOf(nextThreshold)]}',
                style: GoogleFonts.poppins(
                    fontSize: 10, color: AppColors.grey500),
              )
            else
              Text(
                'Niveau maximum atteint 🎉',
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: tier.color,
                    fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Menu Section ──────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final String? title;
  final List<_MenuItem> items;
  const _MenuSection({this.title, required this.items});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Tw.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: GoogleFonts.poppins(
                  fontSize: Tw.textBase,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
              const SizedBox(height: Tw.s3),
            ],
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: Tw.radiusXl,
                border: Border.all(color: AppColors.grey200),
                boxShadow: Tw.shadowSm,
              ),
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          item.icon,
                          color: item.color ?? AppColors.grey700,
                          size: 22,
                        ),
                        title: Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            fontSize: Tw.textSm,
                            fontWeight: FontWeight.w500,
                            color: item.color ?? AppColors.grey800,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.grey400,
                        ),
                        onTap: item.onTap,
                      ),
                      if (i < items.length - 1)
                        const Divider(
                            height: 1,
                            indent: Tw.s5,
                            endIndent: Tw.s4),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});
}

// ── Edit Profile Bottom Sheet ─────────────────────────────────────────────────

class _EditProfileSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final dynamic user;
  const _EditProfileSheet({required this.ref, required this.user});

  @override
  ConsumerState<_EditProfileSheet> createState() =>
      _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _addressCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.fullName ?? '');
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _cityCtrl = TextEditingController(text: widget.user.city ?? '');
    _addressCtrl = TextEditingController(text: widget.user.address ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await ref.read(authProvider.notifier).updateProfile(
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );
    setState(() => _saving = false);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(Tw.s5, Tw.s5, Tw.s5, bottom + Tw.s5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Tw.r3xl)),
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
                margin: const EdgeInsets.only(bottom: Tw.s4),
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: Tw.radiusFull,
                ),
              ),
            ),
            Text(
              'Modifier le profil',
              style: GoogleFonts.poppins(
                fontSize: Tw.textLg,
                fontWeight: FontWeight.w700,
                color: AppColors.grey900,
              ),
            ),
            const SizedBox(height: Tw.s4),
            AppTextField(
              label: 'Nom complet',
              controller: _nameCtrl,
              prefixIcon: const Icon(Icons.person_outline),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: Tw.s3),
            AppTextField(
              label: 'Téléphone',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: Tw.s3),
            AppTextField(
              label: 'Ville',
              controller: _cityCtrl,
              prefixIcon: const Icon(Icons.location_city_outlined),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: Tw.s3),
            AppTextField(
              label: 'Adresse de livraison',
              controller: _addressCtrl,
              prefixIcon: const Icon(Icons.home_outlined),
              textInputAction: TextInputAction.done,
              maxLines: 2,
            ),
            const SizedBox(height: Tw.s5),
            AppButton(
              label: 'Enregistrer',
              onPressed: _save,
              isLoading: _saving,
              icon: Icons.save_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
