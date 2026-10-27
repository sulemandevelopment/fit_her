import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_typography.dart';
import 'fh_button.dart';

class FhDialog {
  FhDialog._();

  static Future<void> showSuccess({
    required String title,
    required String message,
    String buttonLabel = 'OK',
    VoidCallback? onClose,
  }) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTypography.h3),
        content: Text(message, style: AppTypography.bodySmall),
        actions: [
          FhButton(
            label: buttonLabel,
            expand: false,
            onPressed: () {
              Get.back();
              onClose?.call();
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
