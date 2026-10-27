import 'package:flutter/services.dart';

/// Light haptic feedback for primary actions (respects platform defaults).
class FhHaptics {
  FhHaptics._();

  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }
}
