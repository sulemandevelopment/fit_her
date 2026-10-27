import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../UI/daily_log/quick_daily_checkin_screen.dart';
import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../design_system/fh_card.dart';

/// Prompts 1NH2 quick check-in when core fields are incomplete.
class QuickCheckinBanner extends StatelessWidget {
  const QuickCheckinBanner({super.key, required this.dashboard});

  final HomeDashboardModel dashboard;

  @override
  Widget build(BuildContext context) {
    final checkin = dashboard.todayCheckin;
    if (checkin?.quickCheckinComplete == true) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FhCard(
        onTap: () async {
          await Get.to(() => QuickDailyCheckinScreen(initial: checkin));
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your daily check-in',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mood, energy, stress, and sleep — under a minute.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.brandTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
