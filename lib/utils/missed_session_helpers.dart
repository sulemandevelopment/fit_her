/// X7 — Find next / similar class occurrences from the user's schedule.
library;

import 'package:fitness_zone_2/data/models/get_user_plan/get_workout_user_plan_details.dart';
import 'package:fitness_zone_2/data/services/recommendation_service.dart';
import 'package:fitness_zone_2/utils/slot_input_builder.dart';

class ScheduledSlotOccurrence {
  final Slot slot;
  final DateTime anchorDate;
  final String weekdayName;

  const ScheduledSlotOccurrence({
    required this.slot,
    required this.anchorDate,
    required this.weekdayName,
  });

  DateTime? get startAt => parseSlotWallClock(slot.start, anchorDate);
}

const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

DateTime _dateForWeekdayOnOrAfter(DateTime from, int weekday) {
  var d = DateTime(from.year, from.month, from.day);
  while (d.weekday != weekday) {
    d = d.add(const Duration(days: 1));
  }
  return d;
}

/// Expand recurring [trainerSlots] into concrete occurrences within [daysAhead].
List<ScheduledSlotOccurrence> expandScheduleOccurrences(
  List<TrainerSlot> trainerSlots, {
  required DateTime fromDate,
  int daysAhead = 14,
}) {
  final end = fromDate.add(Duration(days: daysAhead));
  final out = <ScheduledSlotOccurrence>[];

  for (final dayBlock in trainerSlots) {
    final weekdayIdx = _weekdayNames.indexOf(dayBlock.day);
    if (weekdayIdx < 0) continue;
    final weekday = weekdayIdx + DateTime.monday;

    var cursor = _dateForWeekdayOnOrAfter(fromDate, weekday);
    while (!cursor.isAfter(end)) {
      for (final slot in dayBlock.slots) {
        if (slot.status == 'Cancelled') continue;
        out.add(ScheduledSlotOccurrence(
          slot: slot,
          anchorDate: cursor,
          weekdayName: dayBlock.day,
        ));
      }
      cursor = cursor.add(const Duration(days: 7));
    }
  }

  out.sort((a, b) {
    final as = a.startAt;
    final bs = b.startAt;
    if (as == null && bs == null) return 0;
    if (as == null) return 1;
    if (bs == null) return -1;
    return as.compareTo(bs);
  });
  return out;
}

/// First class after [missedAnchor] / [missedSlot] ends (exclusive).
ScheduledSlotOccurrence? findNextClassAfter({
  required List<TrainerSlot> trainerSlots,
  required Slot missedSlot,
  required DateTime missedAnchor,
  required DateTime now,
}) {
  final missedEnd = parseSlotWallClock(missedSlot.end, missedAnchor);
  final cutoff = missedEnd ?? missedAnchor;

  final occurrences = expandScheduleOccurrences(
    trainerSlots,
    fromDate: DateTime(now.year, now.month, now.day),
  );

  for (final occ in occurrences) {
    if (occ.slot.id == missedSlot.id &&
        _sameDay(occ.anchorDate, missedAnchor)) {
      continue;
    }
    final start = occ.startAt;
    if (start == null) continue;
    if (start.isAfter(cutoff)) return occ;
  }
  return null;
}

/// Same intensity bucket as [missedSlot], excluding the missed occurrence.
List<ScheduledSlotOccurrence> findSimilarUpcomingClasses({
  required List<TrainerSlot> trainerSlots,
  required Slot missedSlot,
  required DateTime missedAnchor,
  required DateTime now,
  int limit = 5,
}) {
  final targetIntensity =
      RecommendationService.getSlotIntensity(missedSlot.type ?? missedSlot.level);
  final missedEnd = parseSlotWallClock(missedSlot.end, missedAnchor);
  final cutoff = missedEnd ?? missedAnchor;

  final results = <ScheduledSlotOccurrence>[];
  final occurrences = expandScheduleOccurrences(
    trainerSlots,
    fromDate: DateTime(now.year, now.month, now.day),
  );

  final seenSlotIds = <int>{};
  for (final occ in occurrences) {
    if (results.length >= limit) break;
    if (occ.slot.id == missedSlot.id &&
        _sameDay(occ.anchorDate, missedAnchor)) {
      continue;
    }
    final start = occ.startAt;
    if (start == null || !start.isAfter(cutoff)) continue;

    final intensity = RecommendationService.getSlotIntensity(
      occ.slot.type ?? occ.slot.level,
    );
    if (targetIntensity != null) {
      if (intensity != targetIntensity) continue;
    } else if (occ.slot.type != missedSlot.type) {
      continue;
    }
    if (!seenSlotIds.add(occ.slot.id)) continue;
    results.add(occ);
  }
  return results;
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
