import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../config/route_names.dart';

class TokenBadgeWidget extends StatelessWidget {
  final double shreeCoinBalance;
  final double daCoinBalance;
  final double shreedaBalance;

  const TokenBadgeWidget({
    super.key,
    required this.shreeCoinBalance,
    required this.daCoinBalance,
    required this.shreedaBalance,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.wallet),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TokenChip(
            label: 'SHREE',
            amount: shreeCoinBalance,
            color: AppColors.shreeColor,
          ),
          const SizedBox(width: 8),
          _TokenChip(
            label: 'DA',
            amount: daCoinBalance,
            color: AppColors.daColor,
          ),
          const SizedBox(width: 8),
          _TokenChip(
            label: 'SHREEDA',
            amount: shreedaBalance,
            color: AppColors.shreedaColor,
          ),
        ],
      ),
    );
  }
}

class _TokenChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _TokenChip({
    required this.label,
    required this.amount,
    required this.color,
  });

  String _format(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _format(amount),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 10, color: color.withValues(alpha: 0.6)),
            const SizedBox(width: 2),
            Text(
              'Locked',
              style: TextStyle(
                fontSize: 9,
                color: color.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
