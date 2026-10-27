/// 1M1 / 1M2 — injury hide list and low-energy ordering.
/// Uses the injury note she already saved and today's energy check-in.
class ClassSessionPlan {
  const ClassSessionPlan({
    required this.indexes,
    required this.hiddenCount,
    this.note,
  });

  final List<int> indexes;
  final int hiddenCount;
  final String? note;
}

bool classConflictsWithInjury(String? slotType, String injuries) {
  final injury = injuries.toLowerCase();
  final type = (slotType ?? '').toLowerCase();
  if (injury.trim().isEmpty || type.isEmpty) return false;
  final highImpact = type.contains('hiit') ||
      type.contains('cardio') ||
      type.contains('strength');
  final lowerBody = injury.contains('knee') ||
      injury.contains('ankle') ||
      injury.contains('hip');
  final shoulder = injury.contains('shoulder');
  if (lowerBody && highImpact) return true;
  if (shoulder && (type.contains('strength') || type.contains('hiit'))) {
    return true;
  }
  return false;
}

int _energyRank(String? slotType) {
  final type = (slotType ?? '').toLowerCase();
  if (type.contains('gentle') ||
      type.contains('stretch') ||
      type.contains('restore') ||
      type.contains('meditation') ||
      type.contains('breath')) {
    return 0;
  }
  if (type.contains('hiit') ||
      type.contains('cardio') ||
      type.contains('strength')) {
    return 2;
  }
  return 1;
}

/// [types] stay in start-time order. Low energy (1–2) lists gentler
/// classes first. Injury conflicts are removed unless that would hide
/// every class.
ClassSessionPlan planClassSessions({
  required List<String?> types,
  required String injuries,
  int? energy,
}) {
  final conflicts = <int>[];
  final kept = <int>[];
  for (var i = 0; i < types.length; i++) {
    if (classConflictsWithInjury(types[i], injuries)) {
      conflicts.add(i);
    } else {
      kept.add(i);
    }
  }
  final hide = kept.isEmpty ? 0 : conflicts.length;
  final indexes = kept.isEmpty ? List<int>.generate(types.length, (i) => i) : kept;
  if (energy != null && energy <= 2) {
    indexes.sort((a, b) {
      final rank = _energyRank(types[a]).compareTo(_energyRank(types[b]));
      if (rank != 0) return rank;
      return a.compareTo(b);
    });
  }

  final notes = <String>[];
  if (hide > 0) {
    notes.add(
      'Hid $hide ${hide == 1 ? 'class' : 'classes'} that usually load the area you listed as an injury.',
    );
  }
  if (energy != null && energy <= 2) {
    notes.add('Energy is low today. Gentler classes are listed first.');
  } else if (energy != null && energy >= 4) {
    notes.add('Energy is higher today. Intense classes stay on the schedule.');
  }
  return ClassSessionPlan(
    indexes: indexes,
    hiddenCount: hide,
    note: notes.isEmpty ? null : notes.join(' '),
  );
}
