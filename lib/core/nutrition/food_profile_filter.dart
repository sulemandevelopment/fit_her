/// Client-side mirror of partner_backend/helper/foodProfileFilter.js (2NH1).
library;

class FoodProfileConflict {
  final String code;
  final String detail;

  const FoodProfileConflict({required this.code, required this.detail});
}

class FoodProfileInput {
  final String? allergies;
  final List<String> dietaryPreferences;

  const FoodProfileInput({
    this.allergies,
    this.dietaryPreferences = const [],
  });
}

List<String> parseAllergyKeywords(String? raw) {
  final seen = <String>{};
  for (final part in (raw ?? '').split(',')) {
    final kw = part.trim().toLowerCase();
    if (kw.length >= 3) seen.add(kw);
  }
  return seen.toList();
}

const _meat = [
  'chicken', 'beef', 'mutton', 'goat', 'lamb', 'steak', 'mince', 'keema',
  'sausage', 'bacon', 'ham', 'salami', 'pepperoni',
];
const _pork = ['pork', 'bacon', 'ham', 'lard', 'pepperoni', 'salami'];
const _alcohol = ['alcohol', 'wine', 'beer', 'vodka', 'whiskey', 'rum'];
const _seafood = [
  'fish', 'salmon', 'tuna', 'shrimp', 'prawn', 'seafood', 'crab', 'lobster',
];
const _egg = ['egg', 'omelette', 'omelet', 'mayonnaise', 'mayo'];
const _lactose = [
  'milk', 'cheese', 'yogurt', 'yoghurt', 'cream', 'butter', 'whey', 'lactose',
  'paneer', 'dahi',
];
const _gluten = [
  'wheat', 'bread', 'roti', 'naan', 'paratha', 'pasta', 'gluten', 'barley',
  'rye', 'semolina', 'flour', 'maida',
];

String? _containsAny(String haystack, List<String> keywords) {
  for (final kw in keywords) {
    if (haystack.contains(kw)) return kw;
  }
  return null;
}

List<String> _normalizePrefs(List<dynamic>? raw) {
  if (raw == null) return [];
  return raw.map((e) => e.toString().trim().toLowerCase()).where((s) => s.isNotEmpty).toList();
}

FoodProfileEvaluation evaluateFoodAgainstProfile(
  String foodName,
  FoodProfileInput profile,
) {
  final conflicts = <FoodProfileConflict>[];
  final name = foodName.trim().toLowerCase();
  if (name.isEmpty) {
    return FoodProfileEvaluation(allowed: true, conflicts: conflicts);
  }

  for (final allergy in parseAllergyKeywords(profile.allergies)) {
    if (name.contains(allergy)) {
      conflicts.add(FoodProfileConflict(
        code: 'allergy',
        detail: 'Matches your allergy: $allergy',
      ));
    }
  }

  final prefs = _normalizePrefs(profile.dietaryPreferences);
  if (prefs.contains('no_restrictions')) {
    return FoodProfileEvaluation(
      allowed: conflicts.isEmpty,
      conflicts: conflicts,
    );
  }

  if (prefs.contains('vegetarian')) {
    final meat = _containsAny(name, _meat);
    if (meat != null) {
      conflicts.add(FoodProfileConflict(
        code: 'vegetarian',
        detail: 'Contains meat ($meat)',
      ));
    }
    final fish = _containsAny(name, _seafood);
    if (fish != null && !prefs.contains('seafood_ok')) {
      conflicts.add(FoodProfileConflict(
        code: 'vegetarian',
        detail: 'Contains seafood ($fish)',
      ));
    }
    final egg = _containsAny(name, _egg);
    if (egg != null && !prefs.contains('eggs_ok')) {
      conflicts.add(FoodProfileConflict(
        code: 'vegetarian',
        detail: 'Contains eggs ($egg)',
      ));
    }
  }

  if (prefs.contains('halal')) {
    final pork = _containsAny(name, _pork);
    if (pork != null) {
      conflicts.add(FoodProfileConflict(
        code: 'halal',
        detail: 'Not halal ($pork)',
      ));
    }
    final alcohol = _containsAny(name, _alcohol);
    if (alcohol != null) {
      conflicts.add(FoodProfileConflict(
        code: 'halal',
        detail: 'Contains alcohol ($alcohol)',
      ));
    }
  }

  if (prefs.contains('lactose_free')) {
    final dairy = _containsAny(name, _lactose);
    if (dairy != null) {
      conflicts.add(FoodProfileConflict(
        code: 'lactose_free',
        detail: 'Contains dairy ($dairy)',
      ));
    }
  }

  if (prefs.contains('gluten_free')) {
    final gluten = _containsAny(name, _gluten);
    if (gluten != null) {
      conflicts.add(FoodProfileConflict(
        code: 'gluten_free',
        detail: 'Contains gluten ($gluten)',
      ));
    }
  }

  return FoodProfileEvaluation(
    allowed: conflicts.isEmpty,
    conflicts: conflicts,
  );
}

class FoodProfileEvaluation {
  final bool allowed;
  final List<FoodProfileConflict> conflicts;

  const FoodProfileEvaluation({
    required this.allowed,
    required this.conflicts,
  });
}
