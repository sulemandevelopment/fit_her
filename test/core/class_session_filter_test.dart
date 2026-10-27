import 'package:fitness_zone_2/core/movement/class_session_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('knee injury hides HIIT and keeps gentle yoga', () {
    final plan = planClassSessions(
      types: const ['Power HIIT', 'Gentle Yoga'],
      injuries: 'knee pain',
      energy: 4,
    );
    expect(plan.hiddenCount, 1);
    expect(plan.indexes, [1]);
  });

  test('low energy lists the gentler class first', () {
    final plan = planClassSessions(
      types: const ['Power HIIT', 'Gentle Yoga'],
      injuries: '',
      energy: 2,
    );
    expect(plan.indexes, [1, 0]);
    expect(plan.note, contains('Gentler classes'));
  });

  test('does not hide every class', () {
    final plan = planClassSessions(
      types: const ['Power HIIT', 'Cardio Blast'],
      injuries: 'knee',
      energy: 3,
    );
    expect(plan.hiddenCount, 0);
    expect(plan.indexes, [0, 1]);
  });
}
