import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/app_clock.dart';
import '../../../values/constants.dart';
import '../../Repos/checkin_repo/checkin_repository.dart';
import '../../models/daily_log/symptom_definitions.dart';
import '../paid_home_controller/paid_home_controller.dart';

class DailyLogController extends GetxController {
  DailyLogController({
    required this.checkinRepo,
    required this.sharedPreferences,
  });

  final CheckinRepository checkinRepo;
  final SharedPreferences sharedPreferences;

  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  String _today() {
    final now = AppClock.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  /// Saves 1NH2 core fields + optional 1NH1 symptoms in one upsert.
  Future<bool> saveQuickDailyCheckin({
    required int moodLevel,
    required int energyLevel,
    required int stressLevel,
    String? stressCause,
    required double sleepHours,
    required int sleepQuality,
    List<Map<String, dynamic>> symptoms = const [],
  }) async {
    if (isSaving.value) return false;
    isSaving.value = true;
    errorMessage.value = '';
    try {
      final token = sharedPreferences.getString(Constants.accessToken) ?? '';
      if (token.isEmpty) {
        errorMessage.value = 'Not logged in';
        return false;
      }
      final body = <String, dynamic>{
        'date': _today(),
        'moodLevel': moodLevel,
        'energyLevel': energyLevel,
        'stressLevel': stressLevel,
        'sleepHours': sleepHours,
        'sleepQuality': sleepQuality,
        'symptoms': symptoms,
      };
      if (stressLevel >= 4 && stressCause != null && stressCause.isNotEmpty) {
        body['stressCause'] = stressCause;
      }
      final response = await checkinRepo.saveDailyCheckin(
        accessToken: token,
        body: body,
      );
      final data = response.body;
      if (data is Map && data['status'] == '1') {
        if (Get.isRegistered<PaidHomeController>()) {
          await Get.find<PaidHomeController>().refreshDashboard();
        }
        return true;
      }
      errorMessage.value = (data is Map ? data['message'] : null)?.toString() ??
          'Could not save check-in';
      return false;
    } catch (e) {
      errorMessage.value = 'Error: $e';
      debugPrint('[DailyLogController] $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  static List<Map<String, dynamic>> symptomsToPayload(
    Map<String, int> severities,
    Map<String, String?> painAreas,
  ) {
    final list = <Map<String, dynamic>>[];
    for (final def in kDailySymptoms) {
      final sev = severities[def.id];
      if (sev == null || sev < 1 || sev > 3) continue;
      final entry = <String, dynamic>{'id': def.id, 'severity': sev};
      if (def.supportsPainArea) {
        final area = painAreas[def.id];
        if (area != null && area.trim().isNotEmpty) {
          entry['painArea'] = area.trim();
        }
      }
      list.add(entry);
    }
    return list;
  }
}
