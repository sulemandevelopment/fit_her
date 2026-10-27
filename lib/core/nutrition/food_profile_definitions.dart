/// Shared dietary preference IDs (2NH1) — same values as trial onboarding + backend.
class FoodPreferenceOption {
  final String id;
  final String label;
  final String emoji;

  const FoodPreferenceOption(this.id, this.emoji, this.label);
}

const kFoodPreferenceOptions = <FoodPreferenceOption>[
  FoodPreferenceOption('vegetarian', '🥦', 'Vegetarian'),
  FoodPreferenceOption('halal', '🍗', 'Halal'),
  FoodPreferenceOption('lactose_free', '🥛', 'Lactose-free'),
  FoodPreferenceOption('gluten_free', '🌾', 'Gluten-free'),
  FoodPreferenceOption('eggs_ok', '🥚', 'Eggs OK'),
  FoodPreferenceOption('seafood_ok', '🐟', 'Seafood OK'),
  FoodPreferenceOption('no_restrictions', '🍽️', 'Eat everything'),
];

String foodPreferenceLabel(String id) {
  for (final o in kFoodPreferenceOptions) {
    if (o.id == id) return o.label;
  }
  return id;
}
