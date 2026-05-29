import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';

class FullScreenLoading extends StatelessWidget {
  const FullScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/1024.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'SECURE',
              style: TextStyle(
                color: primary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                fontFamily: 'CormorantGaramond',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: primary,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Kept for backward compatibility
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital);
    return Center(child: CircularProgressIndicator(color: primary));
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final base = isDigital ? AppColors.digCard : const Color(0xFFE0E0E0);
    final highlight = isDigital ? AppColors.digSurface : const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: highlight, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, width: 130, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 6),
                      Container(height: 10, width: 90, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 12, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 6),
            Container(height: 12, width: 220, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 6),
            Container(height: 12, width: 160, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(height: 24, width: 60, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(12))),
                const SizedBox(width: 12),
                Container(height: 24, width: 60, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(12))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
