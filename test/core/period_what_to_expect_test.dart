import 'package:fitness_zone_2/core/cycle/period_what_to_expect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('due now mentions spotting and is not a diagnosis', () {
    final text = periodWhatToExpect(phase: 'luteal', periodInDays: 0);
    expect(text, contains('spotting'));
    expect(text, contains('not a diagnosis'));
  });

  test('luteal window within 3 days warns the period may start', () {
    final text = periodWhatToExpect(phase: 'luteal', periodInDays: 2);
    expect(text, contains('next few days'));
  });

  test('follicular stays a typical-pattern note', () {
    final text = periodWhatToExpect(phase: 'follicular', periodInDays: 14);
    expect(text, contains('typical pattern'));
  });
}
