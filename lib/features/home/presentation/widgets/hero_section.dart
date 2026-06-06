import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tw.dart';

class HeroSection extends StatelessWidget {
  final String userName;
  final VoidCallback onImportTap;

  const HeroSection({
    super.key,
    required this.userName,
    required this.onImportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Tw.s4),
      decoration: BoxDecoration(
        borderRadius: Tw.radius3xl,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF006B3F),
            Color(0xFF004D2D),
            Color(0xFF003D24),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: Tw.radius3xl,
        child: Stack(
          children: [
            // ── Desert dune background decoration ────────────────────────
            Positioned.fill(child: _DunesPainter()),
            // ── Gold accent circles ───────────────────────────────────────
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.05),
                ),
              ),
            ),
            // ── Content ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(Tw.s6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Tw.s3,
                      vertical: Tw.s1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: Tw.radiusFull,
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                          'Salam $userName 👋',   // greeting (stays as Islamic greeting)
                          style: GoogleFonts.poppins(
                            fontSize: Tw.textXs,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: Tw.s3),

                  // Main title
                  Text(
                    'Commandez\npartout dans\nle monde',
                    style: GoogleFonts.poppins(
                      fontSize: Tw.text4xl,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                  const SizedBox(height: Tw.s3),

                  // Subtitle
                  Text(
                    'AliExpress, Amazon, Temu, SHEIN\net plus encore livrés en Mauritanie.',
                    style: GoogleFonts.poppins(
                      fontSize: Tw.textSm,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: Tw.s5),

                  // CTA buttons row
                  Row(
                    children: [
                      // Primary CTA
                      Expanded(
                        child: GestureDetector(
                          onTap: onImportTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: Tw.s3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: Tw.radiusLg,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.secondary.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_link_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: Tw.s2),
                                Text(
                                  'Importer un produit',
                                  style: GoogleFonts.poppins(
                                    fontSize: Tw.textSm,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Tw.s3),
                      // Secondary: how it works
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Tw.s4,
                          vertical: Tw.s3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: Tw.radiusLg,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          'Comment\nça marche',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                  const SizedBox(height: Tw.s2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desert dune painter — subtle geometric dunes overlay
// ---------------------------------------------------------------------------

class _DunesPainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DuneCustomPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _DuneCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x08EAD7A1)
      ..style = PaintingStyle.fill;

    // Dune 1 — large bottom wave
    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.cubicTo(
      size.width * 0.25, size.height * 0.55,
      size.width * 0.55, size.height * 0.8,
      size.width, size.height * 0.6,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    // Dune 2 — smaller wave
    final paint2 = Paint()
      ..color = const Color(0x06EAD7A1)
      ..style = PaintingStyle.fill;
    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);
    path2.cubicTo(
      size.width * 0.3, size.height * 0.72,
      size.width * 0.65, size.height * 0.9,
      size.width, size.height * 0.78,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Stars / dots decorations
    final dotPaint = Paint()
      ..color = const Color(0x20D4AF37)
      ..style = PaintingStyle.fill;
    const random = [
      Offset(0.1, 0.15), Offset(0.3, 0.08), Offset(0.5, 0.2),
      Offset(0.75, 0.12), Offset(0.9, 0.25), Offset(0.2, 0.45),
    ];
    for (final r in random) {
      canvas.drawCircle(
        Offset(size.width * r.dx, size.height * r.dy),
        2,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
