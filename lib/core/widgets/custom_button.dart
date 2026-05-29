import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ButtonVariant { primary, secondary, textOnly }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final bool isOutlined;
  final IconData? icon;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.isOutlined = false,
    this.icon,
    this.width,
  });

  const CustomButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  })  : variant = ButtonVariant.primary,
        isOutlined = false;

  const CustomButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  })  : variant = ButtonVariant.secondary,
        isOutlined = true;

  const CustomButton.textOnly({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  })  : variant = ButtonVariant.textOnly,
        isOutlined = false;

  bool get _isDisabled => onPressed == null || isLoading;

  // isOutlined overrides variant to secondary when set to true on default constructor
  ButtonVariant get _effectiveVariant =>
      isOutlined && variant == ButtonVariant.primary ? ButtonVariant.secondary : variant;

  Widget _buildChild(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: contentColor),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: contentColor),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: contentColor, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      );
    }
    return Text(label, style: TextStyle(color: contentColor, fontSize: 16, fontWeight: FontWeight.w600));
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? double.infinity;

    switch (_effectiveVariant) {
      case ButtonVariant.primary:
        return SizedBox(
          width: effectiveWidth,
          height: 52,
          child: ElevatedButton(
            onPressed: _isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isDisabled ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            ),
            child: _buildChild(AppColors.white),
          ),
        );

      case ButtonVariant.secondary:
        return SizedBox(
          width: effectiveWidth,
          height: 52,
          child: OutlinedButton(
            onPressed: _isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: _isDisabled ? AppColors.primary.withValues(alpha: 0.4) : AppColors.primary,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _buildChild(
              _isDisabled ? AppColors.primary.withValues(alpha: 0.4) : AppColors.primary,
            ),
          ),
        );

      case ButtonVariant.textOnly:
        return SizedBox(
          width: effectiveWidth,
          height: 52,
          child: TextButton(
            onPressed: _isDisabled ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _buildChild(
              _isDisabled ? AppColors.primary.withValues(alpha: 0.4) : AppColors.primary,
            ),
          ),
        );
    }
  }
}
