import 'package:fitness_zone_2/data/models/get_user_plan/get_workout_user_plan_details.dart';
import 'package:fitness_zone_2/utils/slot_session_stats.dart';
import 'package:flutter_test/flutter_test.dart';

Slot _slot({String? type, String start = '10:00 AM', String end = '11:00 AM'}) {
  return Slot(
    id: 1,
    start: start,
    end: end,
    trainerLink: null,
    trainer: null,
    type: type,
  );
}

void main() {
  final anchor = DateTime(2026, 10, 28);

  test('duration from start/end wall clock', () {
    expect(slotDurationMinutes(_slot(), anchor), 60);
  });

  test('calories scale with intensity', () {
    final high = estimateClassCalories(
      durationMinutes: 50,
      slotType: 'Power HIIT',
    );
    final low = estimateClassCalories(
      durationMinutes: 50,
      slotType: 'Gentle Yoga',
    );
    expect(high, 350);
    expect(low, 200);
    expect(high! > low!, true);
  });
}
