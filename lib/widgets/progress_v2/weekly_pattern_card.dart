import 'package:fitness_zone_2/data/Repos/progress_v2/progress_repository.dart';
import 'package:fitness_zone_2/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 2NH10 — last 7 days of check-ins, rules summary from the server.
class WeeklyPatternCard extends StatefulWidget {
  const WeeklyPatternCard({super.key});

  @override
  State<WeeklyPatternCard> createState() => _WeeklyPatternCardState();
}

class _WeeklyPatternCardState extends State<WeeklyPatternCard> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!Get.isRegistered<ProgressRepository>()) {
      setState(() => _loading = false);
      return;
    }
    final data = await Get.find<ProgressRepository>().getWeeklyPattern();
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }
    final headline = _data?['headline']?.toString();
    if (headline == null || headline.isEmpty) {
      return const SizedBox.shrink();
    }
    final averages = _data?['averages'];
    final mood = averages is Map ? averages['mood'] : null;
    final energy = averages is Map ? averages['energy'] : null;
    final stress = averages is Map ? averages['stress'] : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardGreenLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This week',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandTextDark,
                ),
          ),
          const SizedBox(height: 6),
          Text(headline, style: Theme.of(context).textTheme.bodyMedium),
          if (_data?['summaryLines'] is List) ...[
            const SizedBox(height: 8),
            for (final line in (_data!['summaryLines'] as List))
              if (line != null && line.toString().isNotEmpty && line.toString() != headline)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${line.toString()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
          ],
          if (mood != null || energy != null || stress != null) ...[
            const SizedBox(height: 8),
            Text(
              'Averages · mood $mood · energy $energy · stress $stress',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.brandTextMuted,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
