import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_completed') ?? false;
    if (!mounted) return;
    if (!onboardingDone) {
      context.go('/onboarding');
      return;
    }
    final status = ref.read(authProvider).status;
    if (status == AuthStatus.authenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo
              const AppLogo(size: 120)
                  .animate(controller: _controller)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: AppSizes.lg),

              // App name
              Text(
                context.l10n.appName,
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  letterSpacing: 2,
                ),
              )
                  .animate(controller: _controller)
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0, delay: 400.ms),

              const SizedBox(height: AppSizes.sm),

              // Tagline
              Text(
                context.l10n.appTagline,
                style: GoogleFonts.poppins(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(controller: _controller)
                  .fadeIn(delay: 700.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0, delay: 700.ms),

              // Gold accent line
              const SizedBox(height: AppSizes.lg),
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
              )
                  .animate(controller: _controller)
                  .scaleX(begin: 0, end: 1, delay: 900.ms, duration: 500.ms)
                  .fadeIn(delay: 900.ms),

              const Spacer(),

              // Loading indicator
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.xxl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Text(
                      'Chargement...',
                      style: GoogleFonts.poppins(
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(controller: _controller)
                  .fadeIn(delay: 1200.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
