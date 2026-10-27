import 'package:fitness_zone_2/data/models/get_user_plan/get_workout_user_plan_details.dart';
import 'package:fitness_zone_2/utils/missed_session_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

Slot _slot(int id, String type, {String start = '10:00 AM', String end = '11:00 AM'}) {
  return Slot(
    id: id,
    start: start,
    end: end,
    trainerLink: null,
    trainer: null,
    type: type,
  );
}

void main() {
  test('findNextClassAfter skips missed occurrence', () {
    final trainerSlots = [
      TrainerSlot(
        id: 1,
        day: 'Tuesday',
        slots: [_slot(1, 'Power HIIT', start: '10:00 AM', end: '11:00 AM')],
      ),
      TrainerSlot(
        id: 2,
        day: 'Wednesday',
        slots: [_slot(2, 'Dance Fitness', start: '10:00 AM', end: '11:00 AM')],
      ),
    ];
    // Tuesday Oct 27 2026 (Oct 28 is Wednesday)
    final missedAnchor = DateTime(2026, 10, 27);
    final now = DateTime(2026, 10, 27, 12, 0);
    final next = findNextClassAfter(
      trainerSlots: trainerSlots,
      missedSlot: trainerSlots.first.slots.first,
      missedAnchor: missedAnchor,
      now: now,
    );
    expect(next, isNotNull);
    expect(next!.slot.id, 2);
    expect(next.weekdayName, 'Wednesday');
  });

  test('findSimilarUpcomingClasses matches intensity', () {
    final trainerSlots = [
      TrainerSlot(
        id: 1,
        day: 'Tuesday',
        slots: [_slot(1, 'Power HIIT')],
      ),
      TrainerSlot(
        id: 2,
        day: 'Thursday',
        slots: [
          _slot(2, 'Cardio Blast'),
          _slot(3, 'Gentle Yoga'),
        ],
      ),
    ];
    final missedAnchor = DateTime(2026, 10, 27);
    final now = DateTime(2026, 10, 27, 12, 0);
    final similar = findSimilarUpcomingClasses(
      trainerSlots: trainerSlots,
      missedSlot: trainerSlots.first.slots.first,
      missedAnchor: missedAnchor,
      now: now,
    );
    expect(similar.length, 2);
    expect(similar.map((e) => e.slot.id).toList(), [2, 1]);
  });
}
