import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_marketplaces.dart';
import '../../../../core/theme/app_tw.dart';

class LinkInputCard extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onAnalyze;

  const LinkInputCard({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onAnalyze,
  });

  @override
  State<LinkInputCard> createState() => _LinkInputCardState();
}

class _LinkInputCardState extends State<LinkInputCard> {
  final _focus = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _hasFocus = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      widget.controller.text = data!.text!;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controller.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: Tw.radius2xl,
        border: Border.all(
          color: _hasFocus
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.grey200,
          width: _hasFocus ? 1.5 : 1,
        ),
        boxShadow: _hasFocus ? Tw.shadowMd : Tw.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Tw.s4,
              vertical: Tw.s3,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.06),
                  AppColors.secondary.withValues(alpha: 0.04),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Tw.r2xl),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF008050)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: Tw.radiusMd,
                  ),
                  child: const Icon(Icons.add_link_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: Tw.s2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Importer un produit',
                        style: GoogleFonts.poppins(
                          fontSize: Tw.textBase,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey900,
                        ),
                      ),
                      Text(
                        'Collez le lien de n\'importe quelle boutique',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(Tw.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Marketplace chips
                SizedBox(
                  height: 30,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppMarketplaces.all.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: Tw.s2),
                    itemBuilder: (_, i) =>
                        _MarketplaceChip(marketplace: AppMarketplaces.all[i]),
                  ),
                ),
                const SizedBox(height: Tw.s3),

                // URL input
                AnimatedContainer(
                  duration: Tw.fast,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: Tw.radiusXl,
                    border: Border.all(
                      color: _hasFocus
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.grey200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: Tw.s3),
                        child: Icon(
                          Icons.link_rounded,
                          color: _hasFocus
                              ? AppColors.primary
                              : AppColors.grey400,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: widget.controller,
                          focusNode: _focus,
                          style: GoogleFonts.poppins(
                            fontSize: Tw.textSm,
                            color: AppColors.grey900,
                          ),
                          decoration: InputDecoration(
                            hintText: 'https://www.aliexpress.com/item/...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: Tw.textSm,
                              color: AppColors.grey400,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: Tw.s3,
                            ),
                          ),
                          onFieldSubmitted: (_) => widget.onAnalyze(),
                        ),
                      ),
                      // Paste button
                      Padding(
                        padding: const EdgeInsets.only(right: Tw.s1),
                        child: TextButton.icon(
                          onPressed: _paste,
                          icon: const Icon(Icons.paste_rounded, size: 14),
                          label: Text(
                            'Coller',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Tw.s2,
                              vertical: Tw.s1,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Tw.s3),

                // CTA button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.isLoading ? null : widget.onAnalyze,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(vertical: Tw.s3),
                      shape: RoundedRectangleBorder(
                          borderRadius: Tw.radiusXl),
                      elevation: 0,
                    ),
                    child: widget.isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: Tw.s2),
                              Text(
                                'Envoi en cours...',
                                style: GoogleFonts.poppins(
                                  fontSize: Tw.textSm,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded, size: 18),
                              const SizedBox(width: Tw.s2),
                              Text(
                                'Envoyer la demande',
                                style: GoogleFonts.poppins(
                                  fontSize: Tw.textSm,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }
}

class _MarketplaceChip extends StatelessWidget {
  final Marketplace marketplace;
  const _MarketplaceChip({required this.marketplace});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Tw.s3, vertical: 4),
      decoration: BoxDecoration(
        color: marketplace.bgColor.withValues(alpha: 0.12),
        borderRadius: Tw.radiusFull,
        border: Border.all(
            color: marketplace.bgColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        marketplace.name,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: marketplace.bgColor.computeLuminance() > 0.5
              ? marketplace.textColor
              : marketplace.bgColor,
        ),
      ),
    );
  }
}
