import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_tw.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_error_banner.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authProvider.notifier)
        .resetPassword(_emailCtrl.text.trim());
    if (ok && mounted) setState(() => _sent = true);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Tw.s6,
            vertical: Tw.s4,
          ),
          child: _sent
              ? _SuccessView(onBack: () => context.go('/login'))
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mot de passe oublié',
                        style: GoogleFonts.poppins(
                          fontSize: Tw.text3xl,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey900,
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                      const Gap(Tw.s2),
                      Text(
                        'Entrez votre adresse email. Nous vous enverrons un lien pour réinitialiser votre mot de passe.',
                        style: GoogleFonts.poppins(
                          fontSize: Tw.textSm,
                          color: AppColors.grey500,
                          height: 1.5,
                        ),
                      ).animate().fadeIn(delay: 50.ms),
                      const Gap(Tw.s8),

                      TwCard(
                        padding: const EdgeInsets.all(Tw.s6),
                        shadow: Tw.shadow,
                        child: Column(
                          children: [
                            AppTextField(
                              label: AppStrings.email,
                              hint: 'vous@exemple.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                              prefixIcon: const Icon(Icons.email_outlined),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _send(),
                            ),
                            if (state.error != null) ...[
                              const Gap(Tw.s4),
                              AppErrorBanner(message: state.error!),
                            ],
                            const Gap(Tw.s6),
                            AppButton(
                              label: AppStrings.sendResetLink,
                              onPressed: _send,
                              isLoading: state.isLoading,
                              icon: Icons.send_rounded,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onBack;
  const _SuccessView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: AppColors.primary,
              size: 48,
            ),
          ).animate().scale(
                begin: const Offset(0.5, 0.5),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
          const Gap(Tw.s6),
          Text(
            'Email envoyé !',
            style: GoogleFonts.poppins(
              fontSize: Tw.text2xl,
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
            ),
          ),
          const Gap(Tw.s2),
          Text(
            'Vérifiez votre boîte mail et\nsuivez le lien de réinitialisation.',
            style: GoogleFonts.poppins(
              fontSize: Tw.textBase,
              color: AppColors.grey500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(Tw.s8),
          AppButton(
            label: 'Retour à la connexion',
            onPressed: onBack,
            icon: Icons.arrow_back_rounded,
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
