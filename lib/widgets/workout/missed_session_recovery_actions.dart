import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/data/models/get_user_plan/get_workout_user_plan_details.dart';
import 'package:fitness_zone_2/helper/analytics_helper.dart';
import 'package:fitness_zone_2/utils/app_clock.dart';
import 'package:fitness_zone_2/utils/missed_session_helpers.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/design_system/fh_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// X7 / F-01 — Join next class & find similar after a missed live session.
class MissedSessionRecoveryActions extends StatelessWidget {
  const MissedSessionRecoveryActions({
    super.key,
    required this.parentContext,
    required this.missedSlot,
    required this.missedAnchor,
    required this.homeController,
  });

  final BuildContext parentContext;
  final Slot missedSlot;
  final DateTime missedAnchor;
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    final workOut = Get.find<WorkOutController>();
    final trainerSlots =
        workOut.getUserWorkoutPlanDetailsPlan?.trainerSlots ?? [];
    final now = AppClock.now();

    final next = findNextClassAfter(
      trainerSlots: trainerSlots,
      missedSlot: missedSlot,
      missedAnchor: missedAnchor,
      now: now,
    );
    final similar = findSimilarUpcomingClasses(
      trainerSlots: trainerSlots,
      missedSlot: missedSlot,
      missedAnchor: missedAnchor,
      now: now,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (next != null)
            FhButton(
              label: 'Join next class',
              onPressed: () => _openOccurrence(
                sheetContext: context,
                occ: next,
                action: 'join_next',
              ),
            ),
          if (next != null && similar.isNotEmpty) const SizedBox(height: 10),
          if (similar.isNotEmpty)
            FhButton(
              label: 'Find a similar class',
              variant: FhButtonVariant.secondary,
              onPressed: () => _showSimilarPicker(context, similar),
            ),
          if (next == null && similar.isEmpty)
            Text(
              'No upcoming classes on your schedule yet. Pull to refresh on the Workout tab or check back later.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Future<void> _openOccurrence({
    required BuildContext sheetContext,
    required ScheduledSlotOccurrence occ,
    required String action,
  }) async {
    await AnalyticsHelper.trackClassMissed(
      occ.slot.type ?? occ.slot.level ?? 'Class',
      classType: occ.slot.type,
      instructorName: occ.slot.trainerName,
      reason: action,
    );
    if (!sheetContext.mounted) return;
    Navigator.of(sheetContext).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!parentContext.mounted) return;
      HelpingWidgets.showWorkoutBottomSheet(
        context: parentContext,
        slot: occ.slot,
        homeController: homeController,
        anchorDate: occ.anchorDate,
      );
    });
  }

  void _showSimilarPicker(
    BuildContext sheetContext,
    List<ScheduledSlotOccurrence> similar,
  ) {
    showModalBottomSheet<void>(
      context: sheetContext,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Similar classes for you',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: similar.length,
                  itemBuilder: (_, i) {
                    final occ = similar[i];
                    final start = occ.startAt;
                    final subtitle = start != null
                        ? '${DateFormat('EEE, MMM d').format(occ.anchorDate)} · ${DateFormat('h:mm a').format(start)}'
                        : occ.weekdayName;
                    return ListTile(
                      title: Text(
                        occ.slot.type ??
                            occ.slot.level ??
                            'Workout class',
                      ),
                      subtitle: Text(subtitle),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _openOccurrence(
                          sheetContext: sheetContext,
                          occ: occ,
                          action: 'find_similar',
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
