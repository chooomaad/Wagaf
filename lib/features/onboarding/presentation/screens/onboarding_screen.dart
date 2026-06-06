import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/onboarding_provider.dart';

// ---------------------------------------------------------------------------
// Onboarding Screen
// ---------------------------------------------------------------------------

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) => setState(() => _page = index);

  void _next() {
    if (_page < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).complete();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLast = _page == 3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Pages ──────────────────────────────────────────────────────────
          PageView(
            controller: _controller,
            onPageChanged: _onPageChanged,
            children: const [
              _Page1(),
              _Page2(),
              _Page3(),
              _Page4(),
            ],
          ),

          // ── Top bar: language selector + skip ──────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  _LanguageSelector(),
                  const Spacer(),
                  if (!isLast)
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        l10n.skip,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Bottom bar: dots + next button ─────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
                child: Row(
                  children: [
                    _DotsIndicator(count: 4, current: _page),
                    const Spacer(),
                    _NextButton(
                      isLast: isLast,
                      label: isLast ? l10n.getStarted : l10n.next,
                      onTap: _next,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language Selector
// ---------------------------------------------------------------------------

class _LanguageSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final notifier = ref.read(localeProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangChip(
            label: 'FR',
            selected: locale.languageCode == 'fr',
            onTap: () => notifier.setLocale(const Locale('fr')),
          ),
          const SizedBox(width: 4),
          _LangChip(
            label: 'AR',
            selected: locale.languageCode == 'ar',
            onTap: () => notifier.setLocale(const Locale('ar')),
          ),
          const SizedBox(width: 4),
          _LangChip(
            label: 'EN',
            selected: locale.languageCode == 'en',
            onTap: () => notifier.setLocale(const Locale('en')),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.grey600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dots indicator
// ---------------------------------------------------------------------------

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 6),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.grey300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Next / Get Started button
// ---------------------------------------------------------------------------

class _NextButton extends StatelessWidget {
  final bool isLast;
  final String label;
  final VoidCallback onTap;
  const _NextButton({
    required this.isLast,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLast) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page base widget
// ---------------------------------------------------------------------------

class _PageBase extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String body;
  final Color illustrationBg;
  final Widget? extra;

  const _PageBase({
    required this.illustration,
    required this.title,
    required this.body,
    required this.illustrationBg,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      children: [
        // ── Illustration ────────────────────────────────────────────────────
        Expanded(
          flex: 55,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: illustrationBg,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: illustration,
                ),
              ),
            ),
          ),
        ),

        // ── Text ────────────────────────────────────────────────────────────
        Expanded(
          flex: 45,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 80),
            child: Column(
              crossAxisAlignment:
                  isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                    height: 1.2,
                  ),
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.grey600,
                    height: 1.6,
                  ),
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                if (extra != null) ...[
                  const SizedBox(height: 20),
                  extra!.animate().fadeIn(delay: 200.ms, duration: 400.ms),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Page 1 — World shopping
// ---------------------------------------------------------------------------

class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _PageBase(
      illustrationBg: const Color(0xFFE8F5EF),
      title: l10n.onboarding1Title,
      body: l10n.onboarding1Body,
      illustration: _WorldIllustration(),
    );
  }
}

class _WorldIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 230,
          height: 230,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.06),
          ),
        ),
        // Middle ring
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
        // Globe
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF006B3F), Color(0xFF004D2D)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.language_rounded, color: Colors.white, size: 60),
        ),
        // Orbiting package icons
        ..._orbitItems(),
      ],
    )
        .animate(onPlay: (c) => c.repeat())
        .rotate(duration: 12.seconds, curve: Curves.linear);
  }

  List<Widget> _orbitItems() {
    const items = [
      (angle: 0.0, icon: Icons.shopping_bag_outlined, color: Color(0xFFD4AF37)),
      (angle: math.pi / 2, icon: Icons.local_shipping_outlined, color: Color(0xFF006B3F)),
      (angle: math.pi, icon: Icons.inventory_2_outlined, color: Color(0xFFD4AF37)),
      (angle: 3 * math.pi / 2, icon: Icons.phone_iphone_rounded, color: Color(0xFF006B3F)),
    ];
    return items.map((item) {
      final x = 115 * math.cos(item.angle);
      final y = 115 * math.sin(item.angle);
      return Transform.translate(
        offset: Offset(x, y),
        child: Transform.rotate(
          angle: -item.angle,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
        ),
      );
    }).toList();
  }
}

// ---------------------------------------------------------------------------
// Page 2 — Copy a link
// ---------------------------------------------------------------------------

class _Page2 extends StatelessWidget {
  const _Page2();

  static const _marketplaces = [
    ('aliexpress', 'AliExpress', Color(0xFFFF6A00)),
    ('alibaba', 'Alibaba', Color(0xFFFF6A00)),
    ('amazon', 'Amazon', Color(0xFF232F3E)),
    ('temu', 'Temu', Color(0xFFE34A22)),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _PageBase(
      illustrationBg: const Color(0xFFFFF8E7),
      title: l10n.onboarding2Title,
      body: l10n.onboarding2Body,
      illustration: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PhoneMockup(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _marketplaces.map((m) => _MarketplaceChip(
                code: m.$1,
                name: m.$2,
                color: m.$3,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.link_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 2.seconds, color: AppColors.secondary.withValues(alpha: 0.3));
  }
}

class _MarketplaceChip extends StatelessWidget {
  final String code;
  final String name;
  final Color color;
  const _MarketplaceChip({
    required this.code,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/marketplaces/$code.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.store_rounded, color: color, size: 28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Page 3 — Delivery to Mauritania
// ---------------------------------------------------------------------------

class _Page3 extends StatelessWidget {
  const _Page3();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _PageBase(
      illustrationBg: const Color(0xFFEAF6FF),
      title: l10n.onboarding3Title,
      body: l10n.onboarding3Body,
      illustration: _DeliveryIllustration(),
    );
  }
}

class _DeliveryIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background map-like dots
        CustomPaint(
          size: const Size(280, 200),
          painter: _MapDotsPainter(),
        ),
        // Delivery path line
        const SizedBox(width: 280, height: 200),
        // Truck + package
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Origin
                const _LocationPin(label: '🌍', color: AppColors.secondary),
                // Dashed line
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.grey300,
                    ),
                  ),
                ),
                // Truck
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_shipping_rounded,
                      color: Colors.white, size: 28),
                ),
                // Dashed line
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(color: AppColors.grey300),
                  ),
                ),
                // Destination (Mauritania)
                const _LocationPin(label: '🇲🇷', color: AppColors.primary),
              ],
            ).animate(onPlay: (c) => c.repeat(reverse: true)).slideX(
                  begin: -0.05,
                  end: 0.05,
                  duration: 2.seconds,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Nouakchott, Mauritanie',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationPin extends StatelessWidget {
  final String label;
  final Color color;
  const _LocationPin({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(label, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}

class _MapDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    const points = [
      Offset(0.1, 0.2), Offset(0.2, 0.5), Offset(0.3, 0.1), Offset(0.4, 0.7),
      Offset(0.5, 0.3), Offset(0.6, 0.6), Offset(0.7, 0.2), Offset(0.8, 0.5),
      Offset(0.9, 0.3), Offset(0.15, 0.8), Offset(0.55, 0.85), Offset(0.75, 0.9),
    ];
    for (final p in points) {
      canvas.drawCircle(Offset(size.width * p.dx, size.height * p.dy), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Page 4 — Real-time tracking
// ---------------------------------------------------------------------------

class _Page4 extends StatelessWidget {
  const _Page4();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _PageBase(
      illustrationBg: const Color(0xFFF3F0FF),
      title: l10n.onboarding4Title,
      body: l10n.onboarding4Body,
      illustration: _TrackingIllustration(),
      extra: Center(
        child: OutlinedButton(
          onPressed: () => context.go('/login'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            context.l10n.hasAccount.trim(),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackingIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.receipt_outlined, 'Commande créée', true),
      (Icons.payment_outlined, 'Paiement confirmé', true),
      (Icons.inventory_2_outlined, 'Produit acheté', true),
      (Icons.local_shipping_outlined, 'En transit', false),
      (Icons.home_outlined, 'Livré', false),
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Notification card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.appName,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Votre commande est en transit 📦',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .slideY(begin: -0.03, end: 0.03, duration: 2.seconds, curve: Curves.easeInOut),
          const SizedBox(height: 20),
          // Mini timeline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: steps.map((step) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: step.$3
                              ? AppColors.primary
                              : AppColors.grey200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step.$1,
                          size: 14,
                          color:
                              step.$3 ? Colors.white : AppColors.grey400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        step.$2,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: step.$3
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: step.$3
                              ? AppColors.grey900
                              : AppColors.grey400,
                        ),
                      ),
                      const Spacer(),
                      if (step.$3)
                        const Icon(Icons.check_rounded,
                            color: AppColors.success, size: 16),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
