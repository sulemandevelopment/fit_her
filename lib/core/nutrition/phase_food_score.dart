/// 2NH2 — client mirror of partner_backend/helper/phaseFoodScore.js.
class PhaseFoodScore {
  final int? score;
  final String label;
  final String note;

  const PhaseFoodScore({
    required this.score,
    required this.label,
    required this.note,
  });
}

const _tags = <String, List<String>>{
  'iron': ['spinach', 'lentil', 'daal', 'beef', 'dates', 'beet'],
  'warm': ['soup', 'khichdi', 'ginger', 'porridge'],
  'light': ['salad', 'yogurt', 'fruit', 'soup', 'khichdi'],
  'fresh': ['salad', 'fruit', 'cucumber'],
  'protein': ['chicken', 'egg', 'fish', 'paneer', 'lentil', 'daal', 'yogurt'],
  'hydrating': ['watermelon', 'cucumber', 'lassi', 'coconut', 'fruit'],
  'fiber': ['oats', 'salad', 'beans', 'chana', 'apple'],
  'magnesium': ['almond', 'banana', 'spinach', 'oats'],
  'complex_carb': ['oats', 'brown rice', 'sweet potato', 'roti', 'daal'],
  'high_sugar': ['cake', 'soda', 'mithai', 'candy', 'ice cream'],
  'fried': ['pakora', 'samosa', 'fried', 'paratha'],
};

const _boost = {
  'menstrual': ['iron', 'warm', 'light'],
  'follicular': ['fresh', 'protein', 'fiber'],
  'ovulatory': ['hydrating', 'light', 'fiber'],
  'luteal': ['magnesium', 'complex_carb', 'protein'],
};

const _penalty = {
  'menstrual': ['fried', 'high_sugar'],
  'follicular': ['fried'],
  'ovulatory': ['fried', 'high_sugar'],
  'luteal': ['high_sugar', 'fried'],
};

PhaseFoodScore scoreFoodForPhase(String foodName, String? phase) {
  final key = (phase ?? '').toLowerCase();
  if (!_boost.containsKey(key)) {
    return const PhaseFoodScore(
      score: null,
      label: 'unknown_phase',
      note: 'Cycle phase is not available.',
    );
  }
  final name = foodName.toLowerCase();
  final tags = <String>[];
  _tags.forEach((tag, words) {
    if (words.any(name.contains)) tags.add(tag);
  });
  if (tags.isEmpty) {
    return const PhaseFoodScore(
      score: 50,
      label: 'neutral',
      note: 'No phase-specific match in the food name.',
    );
  }
  var score = 50;
  for (final t in tags) {
    if (_boost[key]!.contains(t)) score += 15;
    if (_penalty[key]!.contains(t)) score -= 20;
  }
  score = score.clamp(0, 100);
  final label = score >= 65
      ? 'supportive'
      : score <= 40
          ? 'heavier'
          : 'neutral';
  final note = label == 'supportive'
      ? 'This looks supportive for your current phase.'
      : label == 'heavier'
          ? 'This may feel heavier in your current phase.'
          : 'This is a neutral match for your current phase.';
  return PhaseFoodScore(score: score, label: label, note: note);
}
