import 'package:fitness_zone_2/data/api_provider/api_provider.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 1P8 — day counter and one-tap continue on the plan page.
class SubscriptionTrialCard extends StatefulWidget {
  const SubscriptionTrialCard({super.key, this.onContinue});

  final VoidCallback? onContinue;

  @override
  State<SubscriptionTrialCard> createState() => _SubscriptionTrialCardState();
}

class _SubscriptionTrialCardState extends State<SubscriptionTrialCard> {
  Map<String, dynamic>? _view;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String? get _token {
    if (!Get.isRegistered<AuthController>()) return null;
    final token =
        Get.find<AuthController>().sharedPreferences.getString(Constants.accessToken);
    if (token == null || token.isEmpty) return null;
    return token;
  }

  Future<void> _load() async {
    final token = _token;
    if (token == null || !Get.isRegistered<ApiProvider>()) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final response = await Get.find<ApiProvider>().getData(
        Constants.subscriptionTrial,
        headers: {'accessToken': token},
      );
      final body = response.body;
      if (!mounted) return;
      if (body is Map && body['status'] == '1' && body['data'] is Map) {
        setState(() {
          _view = Map<String, dynamic>.from(body['data'] as Map);
          _loading = false;
          _error = null;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _post(String path) async {
    final token = _token;
    if (token == null || !Get.isRegistered<ApiProvider>()) return;
    setState(() => _error = null);
    try {
      final response = await Get.find<ApiProvider>().postData(
        path,
        body: const <String, dynamic>{},
        headers: {'accessToken': token},
      );
      final body = response.body;
      if (!mounted) return;
      if (body is Map && body['status'] == '1' && body['data'] is Map) {
        setState(() => _view = Map<String, dynamic>.from(body['data'] as Map));
      } else if (body is Map && body['message'] is String) {
        setState(() => _error = body['message'] as String);
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not update the trial. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }
    final view = _view;
    if (view == null) return const SizedBox.shrink();
    final active = view['active'] == true;
    final eligible = view['eligible'] == true;
    final status = view['status']?.toString() ?? 'none';
    if (!active && !eligible && status == 'none') return const SizedBox.shrink();

    final day = view['day'];
    final total = view['daysTotal'] ?? 7;
    String title = '7-day free trial';
    String body = 'Try the plan page trial. It does not replace a paid plan.';
    if (active) {
      title = 'Day $day of $total';
      body = 'Your trial is running. Continue opens checkout. Payment still confirms the plan.';
    } else if (status == 'ended' || status == 'continued') {
      title = 'Trial finished';
      body = 'Continue opens checkout for a paid plan.';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.35)),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Color(0xFFD64545), fontSize: 12)),
          ],
          const SizedBox(height: 10),
          if (eligible)
            FilledButton(
              onPressed: () => _post('${Constants.subscriptionTrial}/start'),
              child: const Text('Start 7-day trial'),
            )
          else if (widget.onContinue != null)
            FilledButton(
              onPressed: () async {
                await _post('${Constants.subscriptionTrial}/continue');
                if (!mounted) return;
                widget.onContinue?.call();
              },
              child: const Text('Continue'),
            ),
        ],
      ),
    );
  }
}
