/// 2NH14 — client copy matching partner_backend/helper/periodWhatToExpect.js.
String? periodWhatToExpect({String? phase, int? periodInDays}) {
  final p = (phase ?? '').toLowerCase();
  if (p.isEmpty) return null;
  if (periodInDays == 0) {
    return 'Your next period is due around now. Flow can be light, spotting, or heavier. This is an estimate from your cycle length, not a diagnosis.';
  }
  if (periodInDays != null &&
      periodInDays > 0 &&
      periodInDays <= 3 &&
      p == 'luteal') {
    return 'Your period may start in the next few days. Some women notice cramps, bloating, or mood shifts. This is an estimate, not a diagnosis.';
  }
  switch (p) {
    case 'menstrual':
      return 'Bleeding days. Energy is often lower. You can log flow or spotting in your daily check-in.';
    case 'follicular':
      return 'After bleeding, energy often picks up. This describes a typical pattern, not a personal medical prediction.';
    case 'ovulatory':
      return 'This short window is often when energy feels higher. Timing is estimated from your last period date.';
    case 'luteal':
      return 'The days before a period can feel heavier. Your estimated start uses your usual cycle length.';
    default:
      return null;
  }
}
