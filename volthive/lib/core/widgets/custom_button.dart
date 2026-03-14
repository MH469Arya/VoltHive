import 'package:flutter/material.dart';
import 'package:volthive/core/theme/app_colors.dart';
import 'package:volthive/core/theme/app_spacing.dart';

/// Reusable custom button widget
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (type == ButtonType.primary) {
      return SizedBox(
        width: width,
        height: height ?? AppSpacing.buttonHeightMd,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: AppSpacing.iconSm),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(text),
                  ],
                ),
        ),
      );
    } else if (type == ButtonType.secondary) {
      return SizedBox(
        width: width,
        height: height ?? AppSpacing.buttonHeightMd,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: AppSpacing.iconSm),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(text),
                  ],
                ),
        ),
      );
    } else {
      return SizedBox(
        width: width,
        height: height,
        child: TextButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: AppSpacing.iconSm),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(text),
                  ],
                ),
        ),
      );
    }
  }
}

enum ButtonType {
  primary,
  secondary,
  text,
}
