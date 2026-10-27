import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'fh_button.dart';

class FhErrorState extends StatelessWidget {
  const FhErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            FhButton(
              label: 'Try again',
              variant: FhButtonVariant.secondary,
              expand: false,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
