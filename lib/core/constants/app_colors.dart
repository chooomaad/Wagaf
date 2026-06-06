import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primary = Color(0xFF006B3F); // Vert Mauritanie
  static const Color secondary = Color(0xFFD4AF37); // Or Mauritanie
  static const Color white = Color(0xFFFFFFFF);
  static const Color sand = Color(0xFFEAD7A1); // Sable

  // Primary Shades
  static const Color primaryLight = Color(0xFF00A060);
  static const Color primaryDark = Color(0xFF004D2D);
  static const Color primarySurface = Color(0xFFE8F5EF);

  // Secondary Shades
  static const Color secondaryLight = Color(0xFFE8C84C);
  static const Color secondaryDark = Color(0xFFA88A20);
  static const Color secondarySurface = Color(0xFFFDF8E8);

  // Neutral
  static const Color black = Color(0xFF1A1A2E);
  static const Color grey100 = Color(0xFFF8F9FA);
  static const Color grey200 = Color(0xFFE9ECEF);
  static const Color grey300 = Color(0xFFDEE2E6);
  static const Color grey400 = Color(0xFFCED4DA);
  static const Color grey500 = Color(0xFFADB5BD);
  static const Color grey600 = Color(0xFF6C757D);
  static const Color grey700 = Color(0xFF495057);
  static const Color grey800 = Color(0xFF343A40);
  static const Color grey900 = Color(0xFF212529);

  // Semantic
  static const Color success = Color(0xFF28A745);
  static const Color successLight = Color(0xFFD4EDDA);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF3CD);
  static const Color error = Color(0xFFDC3545);
  static const Color errorLight = Color(0xFFF8D7DA);
  static const Color info = Color(0xFF17A2B8);
  static const Color infoLight = Color(0xFFD1ECF1);

  // Status Colors
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusPayment = Color(0xFF17A2B8);
  static const Color statusPurchased = Color(0xFF6F42C1);
  static const Color statusTransit = Color(0xFFFF6B35);
  static const Color statusArrived = Color(0xFF20C997);
  static const Color statusDelivered = Color(0xFF28A745);
  static const Color statusCancelled = Color(0xFFDC3545);

  // Background
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Shadows
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x26000000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF006B3F), Color(0xFF004D2D)],
  );
}
