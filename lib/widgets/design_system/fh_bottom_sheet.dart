import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_spacing.dart';

class FhBottomSheet {
  FhBottomSheet._();

  static Future<T?> show<T>({
    required Widget child,
    bool isDismissible = true,
  }) {
    return Get.bottomSheet<T>(
      SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(Get.context!).padding.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.sheetTop,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4EC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
        ),
      ),
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
    );
  }
}
