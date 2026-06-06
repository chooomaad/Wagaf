import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_tw.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_error_banner.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).signIn(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Tw.s6,
            vertical: Tw.s8,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(Tw.s8),

                // ── Logo + Brand ───────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: Tw.radius2xl,
                          boxShadow: Tw.shadowMd,
                        ),
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          color: AppColors.white,
                          size: 44,
                        ),
                      ),
                      const Gap(Tw.s4),
                      Text(
                        AppStrings.appName,
                        style: GoogleFonts.poppins(
                          fontSize: Tw.text4xl,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Gap(Tw.s1),
                      Text(
                        AppStrings.welcomeBack,
                        style: GoogleFonts.poppins(
                          fontSize: Tw.textBase,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

                const Gap(Tw.s8),

                // ── Card ──────────────────────────────────────────────────
                TwCard(
                  padding: const EdgeInsets.all(Tw.s6),
                  shadow: Tw.shadow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connexion',
                        style: GoogleFonts.poppins(
                          fontSize: Tw.text2xl,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey900,
                        ),
                      ),
                      const Gap(Tw.s1),
                      Text(
                        context.l10n.loginSubtitle,
                        style: GoogleFonts.poppins(
                          fontSize: Tw.textSm,
                          color: AppColors.grey500,
                        ),
                      ),
                      const Gap(Tw.s6),

                      AppTextField(
                        label: AppStrings.email,
                        hint: 'vous@exemple.com',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        prefixIcon: const Icon(Icons.email_outlined),
                        textInputAction: TextInputAction.next,
                      ),
                      const Gap(Tw.s4),

                      AppTextField(
                        label: AppStrings.password,
                        hint: '••••••••',
                        controller: _passCtrl,
                        obscureText: true,
                        validator: Validators.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _signIn(),
                      ),
                      const Gap(Tw.s2),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            AppStrings.forgotPassword,
                            style: GoogleFonts.poppins(
                              fontSize: Tw.textSm,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      if (state.error != null) ...[
                        const Gap(Tw.s3),
                        AppErrorBanner(message: state.error!),
                      ],

                      const Gap(Tw.s5),

                      AppButton(
                        label: AppStrings.signIn,
                        onPressed: _signIn,
                        isLoading: state.isLoading,
                        icon: Icons.login_rounded,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1),

                const Gap(Tw.s5),

                // ── Register link ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.noAccount,
                      style: GoogleFonts.poppins(
                        fontSize: Tw.textSm,
                        color: AppColors.grey500,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: Tw.s2),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        AppStrings.signUp,
                        style: GoogleFonts.poppins(
                          fontSize: Tw.textSm,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
