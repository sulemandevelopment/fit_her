/// F-02 — Session duration and calorie estimates from real slot times
/// and class type intensity (rules-based, not AI).
library;

import 'package:fitness_zone_2/data/models/get_user_plan/get_workout_user_plan_details.dart';
import 'package:fitness_zone_2/data/services/recommendation_service.dart';
import 'package:fitness_zone_2/utils/slot_input_builder.dart';

/// Minutes between slot [start] and [end] on [anchorDate], or null if unparsable.
int? slotDurationMinutes(Slot slot, DateTime anchorDate) {
  final start = parseSlotWallClock(slot.start, anchorDate);
  final end = parseSlotWallClock(slot.end, anchorDate);
  if (start == null || end == null) return null;
  var mins = end.difference(start).inMinutes;
  if (mins <= 0) mins = end.add(const Duration(days: 1)).difference(start).inMinutes;
  return mins > 0 ? mins : null;
}

/// Approximate active calories for a live class (MET-style by intensity tier).
int? estimateClassCalories({
  required int? durationMinutes,
  String? slotType,
}) {
  if (durationMinutes == null || durationMinutes <= 0) return null;
  final intensity = RecommendationService.getSlotIntensity(slotType);
  final kcalPerMin = switch (intensity) {
    'high' => 7.0,
    'medium' => 5.5,
    'low' => 4.0,
    _ => 5.0,
  };
  return (durationMinutes * kcalPerMin).round();
}

String formatDurationLabel(int? minutes) {
  if (minutes == null || minutes <= 0) return '—';
  return '$minutes Min';
}

String formatCaloriesLabel(int? kcal) {
  if (kcal == null || kcal <= 0) return '—';
  return '$kcal';
}
