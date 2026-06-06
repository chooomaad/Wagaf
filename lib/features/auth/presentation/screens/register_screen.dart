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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _cityCtrl    = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Tw.s6,
            vertical: Tw.s2,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────
                Text(
                  'Créer un compte',
                  style: GoogleFonts.poppins(
                    fontSize: Tw.text3xl,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
                const Gap(Tw.s1),
                Text(
                  context.l10n.registerSubtitle,
                  style: GoogleFonts.poppins(
                    fontSize: Tw.textSm,
                    color: AppColors.grey500,
                  ),
                ).animate().fadeIn(delay: 50.ms, duration: 300.ms),

                const Gap(Tw.s6),

                // ── Informations personnelles ─────────────────────
                TwCard(
                  padding: const EdgeInsets.all(Tw.s5),
                  shadow: Tw.shadow,
                  child: Column(
                    children: [
                      const _SectionLabel(label: 'Informations personnelles'),
                      const Gap(Tw.s4),
                      AppTextField(
                        label: AppStrings.fullName,
                        hint: 'Mohamed Ali',
                        controller: _nameCtrl,
                        validator: (v) => Validators.required(v, 'Le nom'),
                        prefixIcon: const Icon(Icons.person_outline),
                        textInputAction: TextInputAction.next,
                      ),
                      const Gap(Tw.s3),
                      AppTextField(
                        label: AppStrings.email,
                        hint: 'vous@exemple.com',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        prefixIcon: const Icon(Icons.email_outlined),
                        textInputAction: TextInputAction.next,
                      ),
                      const Gap(Tw.s3),
                      AppTextField(
                        label: AppStrings.phone,
                        hint: '+222 XX XX XX XX',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        textInputAction: TextInputAction.next,
                      ),
                      const Gap(Tw.s3),
                      AppTextField(
                        label: AppStrings.city,
                        hint: 'Nouakchott',
                        controller: _cityCtrl,
                        validator: (v) => Validators.required(v, 'La ville'),
                        prefixIcon: const Icon(Icons.location_city_outlined),
                        textInputAction: TextInputAction.next,
                      ),
                      const Gap(Tw.s3),
                      AppTextField(
                        label: 'Adresse de livraison',
                        hint: 'Quartier, rue, numéro...',
                        controller: _addressCtrl,
                        prefixIcon: const Icon(Icons.home_outlined),
                        textInputAction: TextInputAction.next,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.05),

                const Gap(Tw.s4),

                // ── Sécurité ─────────────────────────────────────
                TwCard(
                  padding: const EdgeInsets.all(Tw.s5),
                  shadow: Tw.shadow,
                  child: Column(
                    children: [
                      const _SectionLabel(label: 'Sécurité'),
                      const Gap(Tw.s4),
                      AppTextField(
                        label: AppStrings.password,
                        hint: '••••••••',
                        controller: _passCtrl,
                        obscureText: true,
                        validator: Validators.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        textInputAction: TextInputAction.next,
                      ),
                      const Gap(Tw.s3),
                      AppTextField(
                        label: AppStrings.confirmPassword,
                        hint: '••••••••',
                        controller: _confirmCtrl,
                        obscureText: true,
                        validator: (v) =>
                            Validators.confirmPassword(v, _passCtrl.text),
                        prefixIcon: const Icon(Icons.lock_outline),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _signUp(),
                      ),

                      if (state.error != null) ...[
                        const Gap(Tw.s4),
                        AppErrorBanner(message: state.error!),
                      ],

                      const Gap(Tw.s5),
                      AppButton(
                        label: AppStrings.signUp,
                        onPressed: _signUp,
                        isLoading: state.isLoading,
                        icon: Icons.person_add_outlined,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 140.ms, duration: 400.ms).slideY(begin: 0.05),

                const Gap(Tw.s5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.hasAccount,
                      style: GoogleFonts.poppins(
                        fontSize: Tw.textSm,
                        color: AppColors.grey500,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: Tw.s2),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        AppStrings.signIn,
                        style: GoogleFonts.poppins(
                          fontSize: Tw.textSm,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 250.ms),

                const Gap(Tw.s4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: Tw.textSm,
            fontWeight: FontWeight.w600,
            color: AppColors.grey600,
            letterSpacing: 0.3,
          ),
        ),
      );
}
