import 'package:flutter/material.dart';

/// Reusable app logo widget — renders assets/images/Logo.png.
/// [size] controls both width and height. Use [fit] to override BoxFit.
class AppLogo extends StatelessWidget {
  final double size;
  final BoxFit fit;

  const AppLogo({super.key, this.size = 80, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Logo.png',
      width: size,
      height: size,
      fit: fit,
    );
  }
}
