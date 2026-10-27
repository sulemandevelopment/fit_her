import 'package:flutter/material.dart';

/// Durations and curves for consistent motion. Respects reduced motion via
/// [MediaQuery.disableAnimations].
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;

  static Duration pageTransition(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Duration.zero;
    }
    return normal;
  }
}
