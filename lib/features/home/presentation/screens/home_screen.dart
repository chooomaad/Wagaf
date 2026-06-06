import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_tw.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
// search_provider kept for setCurrentUrl access
import '../widgets/hero_section.dart';
import '../widgets/link_input_card.dart';
import '../widgets/how_it_works_section.dart';
import '../../../../shared/widgets/marketplace_carousel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _urlCtrl = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  void _analyzeLink() {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;
    if (!Validators.isSupportedProductUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.errorInvalidUrl,
            style: GoogleFonts.poppins(fontSize: Tw.textSm),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: Tw.radiusXl),
          margin: const EdgeInsets.all(Tw.s4),
        ),
      );
      return;
    }
    ref.read(searchProvider.notifier).setCurrentUrl(url);
    context.push('/product-detail');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final firstName = user?.fullName?.split(' ').first ?? 'ami';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _AppBar(cartCount: cartCount),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: Tw.s4),

                // ── Hero ─────────────────────────────────────────────────
                HeroSection(
                  userName: firstName,
                  onImportTap: () {
                    // Scroll down to the link input
                  },
                ),
                const SizedBox(height: Tw.s5),

                // ── Link import card ─────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: Tw.s4),
                  child: LinkInputCard(
                    controller: _urlCtrl,
                    isLoading: false,
                    onAnalyze: _analyzeLink,
                  ),
                ),
                const SizedBox(height: Tw.s6),

                // ── Marketplaces ─────────────────────────────────────────
                MarketplacesSection(
                  onTap: (mp) {
                    // Pre-fill hint or navigate to marketplace page
                  },
                ),
                const SizedBox(height: Tw.s6),

                // ── How it works ─────────────────────────────────────────
                const HowItWorksSection(),
                const SizedBox(height: Tw.s6),

              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) {
          setState(() => _selectedIndex = i);
          switch (i) {
            case 1:
              context.push('/my-requests');
            case 2:
              context.push('/cart');
            case 3:
              context.push('/profile');
            default:
              break;
          }
        },
      ),
    );
  }
}

// ── App bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final int cartCount;
  const _AppBar({required this.cartCount});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: Tw.s4,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF008050)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: Tw.radiusMd,
            ),
            child: const Icon(Icons.shopping_bag_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: Tw.s2),
          Text(
            AppStrings.appName,
            style: GoogleFonts.poppins(
              fontSize: Tw.textLg,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined,
                  color: AppColors.grey700),
              onPressed: () => context.push('/cart'),
            ),
            if (cartCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.grey700),
          onPressed: () {},
        ),
        const SizedBox(width: Tw.s1),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.grey200),
      ),
    );
  }
}

// ── Bottom navigation ────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Tw.s4, vertical: Tw.s2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Accueil',
                selected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Demandes',
                selected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.shopping_cart_outlined,
                label: 'Panier',
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Profil',
                selected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Tw.fast,
        padding: const EdgeInsets.symmetric(
            horizontal: Tw.s3, vertical: Tw.s2),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: Tw.radiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.grey500,
              size: 22,
            ),
            if (selected) ...[
              const SizedBox(width: Tw.s1),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: Tw.textXs,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
