import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tw.dart';

class AppErrorBanner extends StatelessWidget {
  final String message;
  const AppErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: Tw.s4,
          vertical: Tw.s3,
        ),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: Tw.radiusMd,
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 16),
            const SizedBox(width: Tw.s2),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: Tw.textSm,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      );
}
