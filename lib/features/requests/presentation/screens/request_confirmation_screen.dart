import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tw.dart';
import '../../domain/entities/import_request_entity.dart';

class RequestConfirmationScreen extends StatelessWidget {
  final ImportRequest request;

  const RequestConfirmationScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: Tw.s5, vertical: Tw.s6),
          child: Column(
            children: [
              // ── Success icon ──────────────────────────────────────────────
              _SuccessIcon()
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: Tw.s5),

              // ── Title ─────────────────────────────────────────────────────
              Text(
                'Demande envoyée\navec succès !',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey900,
                  height: 1.25,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: Tw.s2),

              Text(
                'Votre demande a été transmise à notre équipe.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: AppColors.grey600,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: Tw.s5),

              // ── Request ID chip ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Tw.s3, vertical: Tw.s1),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long_outlined,
                        size: 13, color: AppColors.grey500),
                    const SizedBox(width: 6),
                    Text(
                      'Réf. ${request.shortId}  ·  ${DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt.toLocal())}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: Tw.s5),

              // ── What happens next info box ─────────────────────────────────
              _NextStepsCard()
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: Tw.s5),

              // ── Timeline ─────────────────────────────────────────────────
              _Timeline()
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: Tw.s6),

              // ── Buttons ───────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Retour à l\'accueil',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 300.ms),

              const SizedBox(height: Tw.s3),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => context.go('/my-requests'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Voir mes demandes',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ).animate().fadeIn(delay: 650.ms, duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Big animated checkmark ────────────────────────────────────────────────────

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.success.withValues(alpha: 0.15),
            AppColors.success.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3), width: 2),
      ),
      child: const Icon(Icons.check_circle_rounded,
          color: AppColors.success, size: 60),
    );
  }
}

// ── "What happens next" card ──────────────────────────────────────────────────

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard();

  @override
  Widget build(BuildContext context) {
    const bullets = [
      'le prix du produit',
      'les frais de transport',
      'les frais de service Wagaf',
      'le délai estimé de livraison',
    ];

    return Container(
      padding: const EdgeInsets.all(Tw.s4),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(Tw.r2xl),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Vous recevrez une notification',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Nous allons analyser votre produit et vous contacter prochainement avec :',
            style: GoogleFonts.poppins(
                fontSize: 11.5, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 8),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle,
                        size: 5, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(b,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.primaryDark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Timeline ──────────────────────────────────────────────────────────────────

class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    final steps = [
      (done: true, label: 'Lien reçu'),
      (done: true, label: 'Analyse du produit'),
      (done: false, label: 'Calcul du devis'),
      (done: false, label: 'Validation par notre équipe'),
      (done: false, label: 'En attente de votre confirmation'),
    ];

    return Container(
      padding: const EdgeInsets.all(Tw.s4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Tw.r2xl),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suivi de votre demande',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: Tw.s3),
          ...steps.indexed.map((entry) {
            final (i, step) = entry;
            final isLast = i == steps.length - 1;
            return _TimelineStep(
              done: step.done,
              label: step.label,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final bool done;
  final String label;
  final bool isLast;

  const _TimelineStep({
    required this.done,
    required this.label,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.success : AppColors.grey300;
    final labelColor = done ? AppColors.grey900 : AppColors.grey500;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.grey100,
                border: Border.all(color: color, width: 1.5),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: AppColors.success)
                  : const Icon(Icons.circle, size: 6, color: AppColors.grey300),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 28,
                color: color.withValues(alpha: 0.4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
              color: labelColor,
            ),
          ),
        ),
      ],
    );
  }
}
