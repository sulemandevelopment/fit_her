import 'package:fitness_zone_2/data/controllers/food_profile_controller/food_profile_controller.dart';
import 'package:fitness_zone_2/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shows when a planned meal may conflict with saved allergies/preferences (2NH1).
class FoodProfileConflictBanner extends StatelessWidget {
  const FoodProfileConflictBanner({super.key, required this.foodName});

  final String foodName;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FoodProfileController>()) {
      return const SizedBox.shrink();
    }
    final eval = Get.find<FoodProfileController>().evaluateFood(foodName);
    if (eval.allowed || eval.conflicts.isEmpty) {
      return const SizedBox.shrink();
    }
    final first = eval.conflicts.first;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: AppColors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'May not match your profile: ${first.detail}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
