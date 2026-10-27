import 'dart:convert';

import 'package:fitness_zone_2/core/nutrition/food_profile_filter.dart';
import 'package:fitness_zone_2/data/Repos/home_repo/home_repo.dart';
import 'package:fitness_zone_2/data/controllers/consultation_controller/consultation_controller.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2NH1 — Cached allergies + preferences for in-app meal filtering.
class FoodProfileController extends GetxController {
  FoodProfileController({
    required this.homeRepo,
    required this.sharedPreferences,
  });

  final HomeRepo homeRepo;
  final SharedPreferences sharedPreferences;

  final RxBool loading = false.obs;
  final RxnString allergies = RxnString();
  final RxList<String> dietaryPreferences = <String>[].obs;

  String get _token =>
      sharedPreferences.getString(Constants.accessToken) ?? '';

  FoodProfileInput get input => FoodProfileInput(
        allergies: allergies.value,
        dietaryPreferences: dietaryPreferences.toList(),
      );

  @override
  void onInit() {
    super.onInit();
    refreshFromServer();
  }

  Future<void> refreshFromServer() async {
    loading.value = true;
    try {
      final r = await homeRepo.getFoodProfile(accessToken: _token);
      final parsed = r.body is String ? jsonDecode(r.body) : r.body;
      if (parsed is Map &&
          parsed['status'] == '1' &&
          parsed['data']?['profile'] is Map) {
        final p = Map<String, dynamic>.from(parsed['data']['profile'] as Map);
        allergies.value = p['allergies'] as String?;
        final prefs = p['dietaryPreferences'];
        if (prefs is List) {
          dietaryPreferences.assignAll(prefs.map((e) => e.toString()));
        } else {
          dietaryPreferences.clear();
        }
        return;
      }
      await _fallbackPreConsult();
    } catch (_) {
      await _fallbackPreConsult();
    } finally {
      loading.value = false;
    }
  }

  Future<void> _fallbackPreConsult() async {
    if (!Get.isRegistered<ConsultationController>()) return;
    final profile = await Get.find<ConsultationController>().loadProfile();
    if (profile == null) return;
    allergies.value = profile.allergies;
    dietaryPreferences.assignAll(
      profile.dietaryPreferences?.map((e) => e.toString()) ?? [],
    );
  }

  FoodProfileEvaluation evaluateFood(String foodName) {
    return evaluateFoodAgainstProfile(foodName, input);
  }

  Future<bool> save({
    required String allergiesText,
    required List<String> prefs,
  }) async {
    if (!Get.isRegistered<ConsultationController>()) return false;
    final ok = await Get.find<ConsultationController>().patchProfile({
      'allergies': allergiesText.trim().isEmpty ? 'None' : allergiesText.trim(),
      'dietaryPreferences': prefs,
      'step': 'food_profile',
    });
    if (ok) {
      allergies.value = allergiesText.trim().isEmpty ? 'None' : allergiesText.trim();
      dietaryPreferences.assignAll(prefs);
    }
    return ok;
  }
}
