import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tw.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static const _steps = [
    (
      icon: Icons.link_rounded,
      color: Color(0xFF6C63FF),
      title: 'Collez le lien',
      desc: 'Copiez l\'URL de n\'importe quelle plateforme',
    ),
    (
      icon: Icons.calculate_outlined,
      color: Color(0xFFFF6B35),
      title: 'Prix calculé',
      desc: 'Produit + transport + service en MRU',
    ),
    (
      icon: Icons.shopping_cart_checkout,
      color: Color(0xFF006B3F),
      title: 'On achète',
      desc: 'Notre équipe commande pour vous',
    ),
    (
      icon: Icons.local_shipping_outlined,
      color: Color(0xFFD4AF37),
      title: 'Livraison MR',
      desc: 'Reçu en Mauritanie, à domicile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Tw.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comment ça marche',
            style: GoogleFonts.poppins(
              fontSize: Tw.textLg,
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: Tw.s1),
          Text(
            'Simple, rapide et sécurisé',
            style: GoogleFonts.poppins(
              fontSize: Tw.textXs,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: Tw.s4),
          // Grid 2x2
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: Tw.s3,
            mainAxisSpacing: Tw.s3,
            childAspectRatio: 1.65,
            children: _steps.indexed
                .map(
                  (entry) => _StepCard(
                    step: entry.$2,
                    number: entry.$1 + 1,
                  )
                      .animate()
                      .fadeIn(delay: (entry.$1 * 80).ms, duration: 350.ms)
                      .slideY(begin: 0.15),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final ({IconData icon, Color color, String title, String desc}) step;
  final int number;

  const _StepCard({required this.step, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Tw.s3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: Tw.radiusXl,
        border: Border.all(color: AppColors.grey200),
        boxShadow: Tw.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.1),
              borderRadius: Tw.radiusMd,
            ),
            child: Icon(step.icon, color: step.color, size: 20),
          ),
          const SizedBox(width: Tw.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: step.color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$number',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Tw.s1),
                    Flexible(
                      child: Text(
                        step.title,
                        style: GoogleFonts.poppins(
                          fontSize: Tw.textXs,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  step.desc,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.grey500,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
