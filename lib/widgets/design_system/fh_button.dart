import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_typography.dart';
import '../../utils/fh_haptics.dart';

enum FhButtonVariant { primary, secondary, ghost }

class FhButton extends StatelessWidget {
  const FhButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = FhButtonVariant.primary,
    this.loading = false,
    this.enabled = true,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final FhButtonVariant variant;
  final bool loading;
  final bool enabled;
  final bool expand;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled || loading || onPressed == null;
    Widget child = loading
        ? SizedBox(
            width: 22.w,
            height: 22.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: variant == FhButtonVariant.primary
                  ? AppColors.textOnPrimary
                  : AppColors.primary,
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, SizedBox(width: 8.w)],
              Text(
                label,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _textColor(disabled),
                ),
              ),
            ],
          );

    final radius = BorderRadius.circular(16.r);

    VoidCallback? handler = disabled
        ? null
        : () async {
            await FhHaptics.lightTap();
            onPressed?.call();
          };

    if (variant == FhButtonVariant.primary) {
      return SizedBox(
        width: expand ? double.infinity : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: disabled
                ? null
                : const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
            color: disabled ? AppColors.primary.withValues(alpha: 0.45) : null,
            boxShadow: disabled ? null : AppShadows.primaryGlow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: handler,
              borderRadius: radius,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      );
    }

    if (variant == FhButtonVariant.secondary) {
      return SizedBox(
        width: expand ? double.infinity : null,
        child: OutlinedButton(
          onPressed: handler,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            side: BorderSide(
              color: disabled ? AppColors.divider : AppColors.textPrimary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: child,
        ),
      );
    }

    return TextButton(
      onPressed: handler,
      child: child,
    );
  }

  Color _textColor(bool disabled) {
    if (disabled) return AppColors.textHint;
    switch (variant) {
      case FhButtonVariant.primary:
        return AppColors.textOnPrimary;
      case FhButtonVariant.secondary:
        return AppColors.textPrimary;
      case FhButtonVariant.ghost:
        return AppColors.textTertiary;
    }
  }
}
