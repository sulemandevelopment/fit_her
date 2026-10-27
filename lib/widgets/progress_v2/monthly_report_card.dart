import 'package:fitness_zone_2/data/Repos/progress_v2/progress_repository.dart';
import 'package:fitness_zone_2/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 2NH13 — last 30 days of check-ins and meals. Rules and bars, no AI write-up.
class MonthlyReportCard extends StatefulWidget {
  const MonthlyReportCard({super.key});

  @override
  State<MonthlyReportCard> createState() => _MonthlyReportCardState();
}

class _MonthlyReportCardState extends State<MonthlyReportCard> {
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
    final data = await Get.find<ProgressRepository>().getMonthlyReport();
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
    final charts = _data?['charts'];
    final lines = _data?['summaryLines'];

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
            'This month',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandTextDark,
                ),
          ),
          const SizedBox(height: 6),
          Text(headline, style: Theme.of(context).textTheme.bodyMedium),
          if (lines is List) ...[
            const SizedBox(height: 8),
            for (final line in lines)
              if (line != null &&
                  line.toString().isNotEmpty &&
                  line.toString() != headline)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${line.toString()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
          ],
          if (charts is List && charts.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final raw in charts)
              if (raw is Map) _ChartRow(raw: Map<String, dynamic>.from(raw)),
          ],
        ],
      ),
    );
  }
}

class _ChartRow extends StatelessWidget {
  const _ChartRow({required this.raw});

  final Map<String, dynamic> raw;

  @override
  Widget build(BuildContext context) {
    final label = raw['label']?.toString() ?? '';
    final value = raw['value'];
    final maxRaw = raw['max'];
    final max = maxRaw is num && maxRaw > 0 ? maxRaw.toDouble() : 5.0;
    final number = value is num ? value.toDouble() : 0.0;
    final fraction = (number / max).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: const Color(0xFFE3EDE0),
                color: AppColors.brandTextDark,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              number.toString(),
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
