import 'package:fitness_zone_2/core/nutrition/food_profile_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('allergy blocks matching food', () {
    final r = evaluateFoodAgainstProfile(
      'peanut butter toast',
      FoodProfileInput(allergies: 'peanut', dietaryPreferences: []),
    );
    expect(r.allowed, false);
  });

  test('vegetarian blocks chicken', () {
    final r = evaluateFoodAgainstProfile(
      'Chicken karahi',
      FoodProfileInput(
        allergies: '',
        dietaryPreferences: ['vegetarian'],
      ),
    );
    expect(r.allowed, false);
  });
}
