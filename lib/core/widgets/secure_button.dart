import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';

class SecureButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool fullWidth;

  const SecureButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.fullWidth = true,
  });

  @override
  State<SecureButton> createState() => _SecureButtonState();
}

class _SecureButtonState extends State<SecureButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final gradient = widget.isPrimary
        ? LinearGradient(
            colors: isDigital
                ? [AppColors.digPrimary, AppColors.digAccent]
                : [AppColors.tradPrimaryDark, AppColors.tradPrimary],
          )
        : null;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.mediumImpact();
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(0, _pressed ? 2.0 : 0, 0),
        width: widget.fullWidth ? double.infinity : null,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: gradient,
          color: widget.isPrimary ? null : primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: widget.isPrimary ? null : Border.all(color: primary.withValues(alpha: 0.35)),
          boxShadow: (_pressed || !widget.isPrimary)
              ? null
              : [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: widget.isPrimary ? Colors.white : primary,
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: widget.isPrimary ? Colors.white : primary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
