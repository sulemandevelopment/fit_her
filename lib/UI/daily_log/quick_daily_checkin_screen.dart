import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../data/controllers/daily_log_controller/daily_log_controller.dart';
import '../../data/models/daily_log/symptom_definitions.dart';
import '../../data/models/home_dashboard/home_dashboard_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/design_system/design_system.dart';

/// 1NH2 — Quick daily check-in (mood, energy, stress, sleep) + 1NH1 symptoms.
class QuickDailyCheckinScreen extends StatefulWidget {
  const QuickDailyCheckinScreen({super.key, this.initial});

  final TodayCheckin? initial;

  @override
  State<QuickDailyCheckinScreen> createState() =>
      _QuickDailyCheckinScreenState();
}

class _QuickDailyCheckinScreenState extends State<QuickDailyCheckinScreen> {
  final DailyLogController _controller = Get.find();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  int? _mood;
  int? _energy;
  int? _stress;
  String? _stressCause;
  int? _appetite;
  String? _craving;
  int? _digestion;
  String? _periodFlow;
  String? _skin;
  String? _hair;
  final _supplements = TextEditingController();
  double _sleepHours = 7;
  int? _sleepQuality;
  final Map<String, int> _symptomSeverity = {};
  final Map<String, String> _painAreas = {};

  String? _formError;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _mood = i?.moodLevel;
    _energy = i?.energyLevel;
    _stress = i?.stressLevel;
    _sleepHours = i?.sleepHours ?? 7;
    _sleepQuality = i?.sleepQuality;
    for (final s in i?.symptoms ?? const []) {
      if (s is Map) {
        final id = s['id']?.toString();
        final sev = s['severity'];
        if (id != null && sev is num) {
          _symptomSeverity[id] = sev.toInt().clamp(1, 3);
        }
        final area = s['painArea']?.toString();
        if (id != null && area != null) _painAreas[id] = area;
      }
    }
  }

  @override
  void dispose() {
    _supplements.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fhSetLightStatusBar();
    return FhScaffold(
      softBrandBackground: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.brandSoftBackground,
        title: Text('Daily check-in', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW =
                constraints.maxWidth > 520 ? 520.0 : constraints.maxWidth;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'How are you today?',
                          style: AppTypography.h3
                              .copyWith(color: AppColors.brandTextDark),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Mood, energy, stress, sleep, appetite, and cravings. '
                          'Optional symptoms help your weekly reports.',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.brandTextMuted),
                        ),
                        SizedBox(height: 20.h),
                        _scaleSection(
                          key: const ValueKey('mood'),
                          label: 'Mood',
                          value: _mood,
                          onPick: (v) => setState(() => _mood = v),
                        ),
                        _scaleSection(
                          key: const ValueKey('energy'),
                          label: 'Energy',
                          value: _energy,
                          onPick: (v) => setState(() => _energy = v),
                        ),
                        _scaleSection(
                          key: const ValueKey('stress'),
                          label: 'Stress',
                          value: _stress,
                          onPick: (v) => setState(() {
                            _stress = v;
                            if (v < 4) _stressCause = null;
                          }),
                        ),
                        if ((_stress ?? 0) >= 4) ...[
                          SizedBox(height: 8.h),
                          _stressCauseChips(),
                        ],
                        _scaleSection(
                          key: const ValueKey('appetite'),
                          label: 'Appetite (1 low – 5 strong)',
                          value: _appetite,
                          onPick: (v) => setState(() => _appetite = v),
                        ),
                        SizedBox(height: 8.h),
                        Text('Cravings',
                            style: AppTypography.label
                                .copyWith(color: AppColors.brandLabel)),
                        SizedBox(height: 8.h),
                        _cravingChips(),
                        _scaleSection(
                          key: const ValueKey('digestion'),
                          label: 'Digestion (1 comfortable – 5 uncomfortable)',
                          value: _digestion,
                          onPick: (v) => setState(() => _digestion = v),
                        ),
                        SizedBox(height: 8.h),
                        Text('Period flow (optional)',
                            style: AppTypography.label
                                .copyWith(color: AppColors.brandLabel)),
                        SizedBox(height: 8.h),
                        _choiceChips(
                          selected: _periodFlow,
                          options: const [
                            ('spotting', 'Spotting'),
                            ('light', 'Light'),
                            ('medium', 'Medium'),
                            ('heavy', 'Heavy'),
                          ],
                          onPick: (v) => setState(() => _periodFlow = v),
                        ),
                        SizedBox(height: 12.h),
                        Text('Skin (optional)',
                            style: AppTypography.label
                                .copyWith(color: AppColors.brandLabel)),
                        SizedBox(height: 8.h),
                        _choiceChips(
                          selected: _skin,
                          options: const [
                            ('clear', 'Clear'),
                            ('breakout', 'Breakout'),
                            ('dry', 'Dry'),
                            ('oily', 'Oily'),
                            ('sensitive', 'Sensitive'),
                          ],
                          onPick: (v) => setState(() => _skin = v),
                        ),
                        SizedBox(height: 12.h),
                        Text('Hair (optional)',
                            style: AppTypography.label
                                .copyWith(color: AppColors.brandLabel)),
                        SizedBox(height: 8.h),
                        _choiceChips(
                          selected: _hair,
                          options: const [
                            ('normal', 'Normal'),
                            ('shedding', 'Shedding'),
                            ('dry', 'Dry'),
                            ('oily', 'Oily'),
                          ],
                          onPick: (v) => setState(() => _hair = v),
                        ),
                        SizedBox(height: 12.h),
                        FhTextField(
                          controller: _supplements,
                          label: 'Medications or supplements today (optional)',
                          hint: 'e.g. iron, vitamin D',
                        ),
                        SizedBox(height: 16.h),
                        Text('Sleep last night',
                            style: AppTypography.label
                                .copyWith(color: AppColors.brandLabel)),
                        SizedBox(height: 8.h),
                        Text(
                          '${_sleepHours.toStringAsFixed(1)} hours',
                          style: AppTypography.body,
                        ),
                        Slider(
                          value: _sleepHours.clamp(0, 12),
                          min: 0,
                          max: 12,
                          divisions: 24,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _sleepHours = v),
                        ),
                        _restedRow(),
                        SizedBox(height: 20.h),
                        Text('Symptoms (optional)',
                            style: AppTypography.h3.copyWith(fontSize: 16.sp)),
                        SizedBox(height: 8.h),
                        ...kDailySymptoms.map(_symptomTile),
                        if (_formError != null) ...[
                          SizedBox(height: 12.h),
                          Text(
                            _formError!,
                            style: AppTypography.labelSmall
                                .copyWith(color: AppColors.error),
                          ),
                        ],
                        SizedBox(height: 20.h),
                        Obx(() => FhButton(
                              label: 'Save check-in',
                              loading: _controller.isSaving.value,
                              onPressed: _submit,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _scaleSection({
    required Key key,
    required String label,
    required int? value,
    required ValueChanged<int> onPick,
  }) {
    return Padding(
      key: key,
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.label.copyWith(color: AppColors.brandLabel)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final level = i + 1;
              final selected = value == level;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Material(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => onPick(level),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 44.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.divider,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          '$level',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandTextDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _choiceChips({
    required String? selected,
    required List<(String, String)> options,
    required ValueChanged<String> onPick,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((c) {
        return FilterChip(
          label: Text(c.$2),
          selected: selected == c.$1,
          onSelected: (_) => onPick(c.$1),
        );
      }).toList(),
    );
  }

  Widget _cravingChips() {
    const options = [
      ('sweet', 'Sweet'),
      ('salty', 'Salty'),
      ('carbs', 'Carbs'),
      ('comfort', 'Comfort'),
      ('none', 'None'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((c) {
        final selected = _craving == c.$1;
        return FilterChip(
          label: Text(c.$2),
          selected: selected,
          onSelected: (_) => setState(() => _craving = c.$1),
        );
      }).toList(),
    );
  }

  Widget _stressCauseChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kStressCauses.map((c) {
        final selected = _stressCause == c.$1;
        return ChoiceChip(
          label: Text(c.$2),
          selected: selected,
          onSelected: (_) => setState(() => _stressCause = c.$1),
          selectedColor: AppColors.primary.withValues(alpha: 0.25),
        );
      }).toList(),
    );
  }

  Widget _restedRow() {
    const labels = ['Low', 'OK', 'Rested'];
    return Row(
      children: List.generate(3, (i) {
        final level = i + 1;
        final selected = _sleepQuality == level;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: OutlinedButton(
              onPressed: () => setState(() => _sleepQuality = level),
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    selected ? AppColors.cardGreen : Colors.white,
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.divider,
                ),
              ),
              child: Text(labels[i], style: AppTypography.labelSmall),
            ),
          ),
        );
      }),
    );
  }

  Widget _symptomTile(SymptomDefinition def) {
    final sev = _symptomSeverity[def.id];
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: FhCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(def.label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Row(
              children: [1, 2, 3].map((level) {
                final selected = sev == level;
                const labels = ['', 'Mild', 'Moderate', 'Strong'];
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: FilterChip(
                    label: Text(labels[level]),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        if (selected) {
                          _symptomSeverity.remove(def.id);
                          _painAreas.remove(def.id);
                        } else {
                          _symptomSeverity[def.id] = level;
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            if (def.supportsPainArea && sev != null) ...[
              SizedBox(height: 6.h),
              TextFormField(
                key: ValueKey('pain-${def.id}'),
                initialValue: _painAreas[def.id],
                decoration: const InputDecoration(
                  hintText: 'Where? (optional)',
                  isDense: true,
                ),
                onChanged: (v) => _painAreas[def.id] = v,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _formError = null);
    if (_mood == null ||
        _energy == null ||
        _stress == null ||
        _sleepQuality == null ||
        _appetite == null ||
        _craving == null) {
      setState(() {
        _formError =
            'Please rate mood, energy, stress, sleep, appetite, and cravings.';
      });
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
      return;
    }
    if (_stress! >= 4 && (_stressCause == null || _stressCause!.isEmpty)) {
      setState(() {
        _formError = 'Please choose what is causing your stress today.';
      });
      return;
    }
    final symptoms = DailyLogController.symptomsToPayload(
      _symptomSeverity,
      _painAreas,
    );
    final ok = await _controller.saveQuickDailyCheckin(
      moodLevel: _mood!,
      energyLevel: _energy!,
      stressLevel: _stress!,
      stressCause: _stressCause,
      appetiteLevel: _appetite!,
      cravingType: _craving!,
      sleepHours: _sleepHours,
      sleepQuality: _sleepQuality!,
      symptoms: symptoms,
      digestionLevel: _digestion,
      supplementLog: _supplements.text,
      periodFlow: _periodFlow,
      skinStatus: _skin,
      hairStatus: _hair,
    );
    if (!mounted) return;
    if (ok) {
      Get.back(result: true);
      return;
    }
    setState(() {
      _formError = _controller.errorMessage.value.isNotEmpty
          ? _controller.errorMessage.value
          : 'Could not save. Try again.';
    });
  }
}
