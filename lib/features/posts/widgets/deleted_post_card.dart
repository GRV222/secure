import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../models/post_model.dart';

class DeletedPostCard extends StatelessWidget {
  final PostModel post;
  const DeletedPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        color: Colors.orange.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: Colors.orange),
              const SizedBox(width: 6),
              const Text('Post Deleted', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.orange)),
              const Spacer(),
              Text(
                'by @${post.authorUsername}',
                style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
              ),
            ],
          ),
          if (post.deletionReason != null && post.deletionReason!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                color: AppColors.surfaceColor(isDigital),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reason', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSubFor(isDigital))),
                  const SizedBox(height: 2),
                  Text(post.deletionReason!, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.sm),
          Text(
            'SECURE requires celebrities to disclose when and why posts are removed.',
            style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital), height: 1.4),
          ),
          if (post.viewsAtDeletion > 0 || post.ratingAtDeletion > 0) ...[
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                _Stat(label: 'Views at deletion', value: '${post.viewsAtDeletion}'),
                const SizedBox(width: AppSizes.lg),
                _Stat(label: 'Rating at deletion', value: post.ratingAtDeletion.toStringAsFixed(1)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital))),
      ],
    );
  }
}
