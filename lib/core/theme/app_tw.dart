import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ---------------------------------------------------------------------------
// Tailwind-inspired design system for Flutter
// Spacing based on 4-px grid (Tailwind's default unit = 4px)
// ---------------------------------------------------------------------------

abstract final class Tw {
  // ── Spacing ──────────────────────────────────────────────────────────────
  static const double s0  =  0;
  static const double s1  =  4;
  static const double s2  =  8;
  static const double s3  = 12;
  static const double s4  = 16;
  static const double s5  = 20;
  static const double s6  = 24;
  static const double s7  = 28;
  static const double s8  = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s14 = 56;
  static const double s16 = 64;
  static const double s20 = 80;
  static const double s24 = 96;

  // ── Border-radius ─────────────────────────────────────────────────────────
  static const double rNone  =  0;
  static const double rSm    =  4;
  static const double r      =  6;
  static const double rMd    =  8;
  static const double rLg    = 12;
  static const double rXl    = 16;
  static const double r2xl   = 20;
  static const double r3xl   = 24;
  static const double rFull  = 9999;

  // ── Font sizes ────────────────────────────────────────────────────────────
  static const double textXs   = 10;
  static const double textSm   = 12;
  static const double textBase = 14;
  static const double textLg   = 16;
  static const double textXl   = 18;
  static const double text2xl  = 20;
  static const double text3xl  = 24;
  static const double text4xl  = 30;
  static const double text5xl  = 36;
  static const double text6xl  = 48;

  // ── Screen padding ────────────────────────────────────────────────────────
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: s4,
    vertical: s4,
  );
  static const EdgeInsets pagePadding = EdgeInsets.all(s4);

  // ── Shadows ──────────────────────────────────────────────────────────────
  static final List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  static final List<BoxShadow> shadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  static final List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  static final List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  static final List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  // ── Common border-radius objects ──────────────────────────────────────────
  static const BorderRadius radiusSm   = BorderRadius.all(Radius.circular(rSm));
  static const BorderRadius radiusMd   = BorderRadius.all(Radius.circular(rMd));
  static const BorderRadius radiusLg   = BorderRadius.all(Radius.circular(rLg));
  static const BorderRadius radiusXl   = BorderRadius.all(Radius.circular(rXl));
  static const BorderRadius radius2xl  = BorderRadius.all(Radius.circular(r2xl));
  static const BorderRadius radius3xl  = BorderRadius.all(Radius.circular(r3xl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(rFull));

  // ── Durations ─────────────────────────────────────────────────────────────
  static const Duration fast   = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow   = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);
}

// ---------------------------------------------------------------------------
// Utility extension — attach helpers to every widget
// ---------------------------------------------------------------------------

extension TwWidgetX on Widget {
  Widget px(double value) => Padding(
        padding: EdgeInsets.symmetric(horizontal: value),
        child: this,
      );
  Widget py(double value) => Padding(
        padding: EdgeInsets.symmetric(vertical: value),
        child: this,
      );
  Widget p(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);
  Widget pt(double value) =>
      Padding(padding: EdgeInsets.only(top: value), child: this);
  Widget pb(double value) =>
      Padding(padding: EdgeInsets.only(bottom: value), child: this);
  Widget pl(double value) =>
      Padding(padding: EdgeInsets.only(left: value), child: this);
  Widget pr(double value) =>
      Padding(padding: EdgeInsets.only(right: value), child: this);

  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);
  Widget centered() => Center(child: this);
  Widget flexible({int flex = 1}) => Flexible(flex: flex, child: this);

  Widget opacity(double value) =>
      Opacity(opacity: value.clamp(0.0, 1.0), child: this);
}

// ---------------------------------------------------------------------------
// Card / container helpers
// ---------------------------------------------------------------------------

class TwCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderRadius? radius;
  final List<BoxShadow>? shadow;
  final Border? border;

  const TwCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius,
    this.shadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding ?? const EdgeInsets.all(Tw.s4),
        decoration: BoxDecoration(
          color: color ?? AppColors.white,
          borderRadius: radius ?? Tw.radiusXl,
          boxShadow: shadow ?? Tw.shadowSm,
          border: border,
        ),
        child: child,
      );
}

// ---------------------------------------------------------------------------
// Gap (vertical / horizontal spacing shorthand)
// ---------------------------------------------------------------------------

class Gap extends StatelessWidget {
  final double size;
  final bool horizontal;

  const Gap(this.size, {super.key, this.horizontal = false});
  const Gap.h(this.size, {super.key}) : horizontal = true;

  @override
  Widget build(BuildContext context) => horizontal
      ? SizedBox(width: size)
      : SizedBox(height: size);
}

// ---------------------------------------------------------------------------
// Responsive breakpoints
// ---------------------------------------------------------------------------

abstract final class TwScreen {
  static bool isMobile(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width < 640;
  static bool isTablet(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width >= 640 &&
      MediaQuery.sizeOf(ctx).width < 1024;
  static bool isDesktop(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width >= 1024;
}
