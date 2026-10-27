import 'package:fitness_zone_2/core/nutrition/phase_food_score.dart';
import 'package:fitness_zone_2/data/controllers/cycle_theme_controller/cycle_theme_controller.dart';
import 'package:fitness_zone_2/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 2NH2 — rules-based phase fit under a planned meal. Not medical advice.
class PhaseFoodScoreBanner extends StatelessWidget {
  const PhaseFoodScoreBanner({super.key, required this.foodName});

  final String foodName;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CycleThemeController>()) {
      return const SizedBox.shrink();
    }
    return Obx(() {
      final phase = Get.find<CycleThemeController>().phase.value.name;
      final result = scoreFoodForPhase(foodName, phase);
      if (result.label == 'neutral' || result.label == 'unknown_phase') {
        return const SizedBox.shrink();
      }
      final supportive = result.label == 'supportive';
      final color = supportive ? AppColors.primaryDeep : AppColors.accent;
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          result.note,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    });
  }
}
