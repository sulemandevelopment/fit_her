import 'package:fitness_zone_2/core/nutrition/food_profile_definitions.dart';
import 'package:fitness_zone_2/data/controllers/food_profile_controller/food_profile_controller.dart';
import 'package:fitness_zone_2/theme/app_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/design_system/design_system.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 2NH1 — Food preferences & allergies (rules-based filters).
class FoodPreferencesScreen extends StatefulWidget {
  const FoodPreferencesScreen({super.key});

  @override
  State<FoodPreferencesScreen> createState() => _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState extends State<FoodPreferencesScreen> {
  final _allergies = TextEditingController();
  final _selected = <String>{};
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = Get.find<FoodProfileController>();
    if (c.allergies.value == null && c.dietaryPreferences.isEmpty) {
      await c.refreshFromServer();
    }
    final a = c.allergies.value ?? '';
    _allergies.text = a.toLowerCase() == 'none' ? '' : a;
    _selected
      ..clear()
      ..addAll(c.dietaryPreferences);
    if (_selected.isEmpty) _selected.add('no_restrictions');
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _allergies.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    var prefs = _selected.toList();
    if (prefs.contains('no_restrictions')) {
      prefs = ['no_restrictions'];
    }
    final ok = await Get.find<FoodProfileController>().save(
      allergiesText: _allergies.text.trim().isEmpty ? 'None' : _allergies.text.trim(),
      prefs: prefs,
    );
    setState(() => _saving = false);
    if (ok) {
      CustomToast.successToast(msg: 'Food preferences saved');
      if (mounted) Get.back();
    } else {
      CustomToast.failToast(msg: 'Could not save. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FhScaffold(
      appBar: HelpingWidgets().appBarWidget(
        () => Get.back(),
        text: 'Food preferences',
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'We use these rules to flag meals that may not fit your choices. '
                    'This is not medical advice — talk to your dietitian for personal guidance.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Food allergies',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  FhTextField(
                    controller: _allergies,
                    hint: 'e.g. peanuts, shellfish (comma-separated)',
                    maxLines: 2,
                  ),
                  TextButton(
                    onPressed: () => setState(() => _allergies.clear()),
                    child: const Text('No allergies'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dietary preferences',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kFoodPreferenceOptions.map((opt) {
                      final on = _selected.contains(opt.id);
                      return FilterChip(
                        label: Text('${opt.emoji} ${opt.label}'),
                        selected: on,
                        onSelected: (v) {
                          setState(() {
                            if (opt.id == 'no_restrictions') {
                              _selected
                                ..clear()
                                ..add('no_restrictions');
                              return;
                            }
                            _selected.remove('no_restrictions');
                            if (v) {
                              _selected.add(opt.id);
                            } else {
                              _selected.remove(opt.id);
                            }
                            if (_selected.isEmpty) {
                              _selected.add('no_restrictions');
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  FhButton(
                    label: 'Save',
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
    );
  }
}
