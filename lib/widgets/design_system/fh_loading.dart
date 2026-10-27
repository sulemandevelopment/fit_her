import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class FhLoadingIndicator extends StatelessWidget {
  const FhLoadingIndicator({super.key, this.size = 28, this.strokeWidth = 2.5});

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: AppColors.primary,
      ),
    );
  }
}
