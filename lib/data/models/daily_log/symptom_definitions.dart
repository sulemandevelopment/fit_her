/// PDF 1NH1 — daily symptom picker options (rules-only, no AI).
class SymptomDefinition {
  const SymptomDefinition(this.id, this.label, {this.supportsPainArea = false});

  final String id;
  final String label;
  final bool supportsPainArea;
}

const kDailySymptoms = [
  SymptomDefinition('cramps', 'Cramps', supportsPainArea: true),
  SymptomDefinition('headache', 'Headache', supportsPainArea: true),
  SymptomDefinition('bloating', 'Bloating'),
  SymptomDefinition('fatigue', 'Fatigue'),
  SymptomDefinition('nausea', 'Nausea'),
  SymptomDefinition('breast_tenderness', 'Breast tenderness'),
  SymptomDefinition('back_pain', 'Back pain', supportsPainArea: true),
  SymptomDefinition('acne', 'Acne'),
];

const kStressCauses = [
  ('work', 'Work'),
  ('family', 'Family'),
  ('health', 'Health'),
  ('money', 'Money'),
  ('other', 'Other'),
];
