import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tw.dart';
import '../../../../l10n/app_localizations.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  static const _stats = [
    (value: '1 250+', label: 'Commandes\nlivrées', icon: Icons.check_circle_outline),
    (value: '890+',   label: 'Clients\nsatisfaits', icon: Icons.people_outline),
    (value: '12',     label: 'Pays\ncouverts',      icon: Icons.public_outlined),
    (value: '21j',    label: 'Délai\nmoyen',        icon: Icons.schedule_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Tw.s4),
      padding: const EdgeInsets.symmetric(
        vertical: Tw.s5,
        horizontal: Tw.s4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF8E8), Color(0xFFFAF3D0)],
        ),
        borderRadius: Tw.radius2xl,
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.25),
        ),
        boxShadow: Tw.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Tw.s2),
              Text(
                '${context.l10n.appName} en chiffres',
                style: GoogleFonts.poppins(
                  fontSize: Tw.textSm,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryDark,
                ),
              ),
              const SizedBox(width: Tw.s2),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: Tw.s4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _stats.indexed
                .map(
                  (entry) => _StatItem(stat: entry.$2)
                      .animate()
                      .fadeIn(delay: (entry.$1 * 100).ms, duration: 400.ms)
                      .slideY(begin: 0.2),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final ({String value, String label, IconData icon}) stat;
  const _StatItem({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(stat.icon, color: AppColors.secondaryDark, size: 20),
        ),
        const SizedBox(height: Tw.s2),
        Text(
          stat.value,
          style: GoogleFonts.poppins(
            fontSize: Tw.text2xl,
            fontWeight: FontWeight.w800,
            color: AppColors.grey900,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          stat.label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.grey600,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
