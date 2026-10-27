import 'package:fitness_zone_2/core/nutrition/phase_food_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('menstrual spinach is supportive', () {
    final r = scoreFoodForPhase('spinach daal', 'menstrual');
    expect(r.label, 'supportive');
  });

  test('unknown food is neutral', () {
    final r = scoreFoodForPhase('mystery dish', 'follicular');
    expect(r.score, 50);
    expect(r.label, 'neutral');
  });
}
