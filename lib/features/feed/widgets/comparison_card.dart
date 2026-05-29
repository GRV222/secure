import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../models/post_model.dart';
import '../../../models/user_model.dart';

class ComparisonCard extends StatefulWidget {
  final PostModel? postA;
  final PostModel? postB;
  final UserModel? profileA;
  final UserModel? profileB;
  final void Function(String chosenId) onChoose;
  final VoidCallback onDismiss;

  const ComparisonCard({
    super.key,
    this.postA,
    this.postB,
    this.profileA,
    this.profileB,
    required this.onChoose,
    required this.onDismiss,
  });

  @override
  State<ComparisonCard> createState() => _ComparisonCardState();
}

class _ComparisonCardState extends State<ComparisonCard> {
  String? _chosen;

  void _pick(String id) {
    if (_chosen != null) return;
    setState(() => _chosen = id);
    widget.onChoose(id);
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final isPostComp = widget.postA != null && widget.postB != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
        color: primary.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows_rounded, size: 18, color: primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isPostComp ? 'Which post do you prefer?' : 'Whose work resonates more?',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: primary),
                ),
              ),
              GestureDetector(
                onTap: widget.onDismiss,
                child: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          if (isPostComp)
            Row(
              children: [
                Expanded(child: _PostMini(post: widget.postA!, chosen: _chosen == widget.postA!.postId, onTap: () => _pick(widget.postA!.postId))),
                const SizedBox(width: 8),
                Expanded(child: _PostMini(post: widget.postB!, chosen: _chosen == widget.postB!.postId, onTap: () => _pick(widget.postB!.postId))),
              ],
            )
          else if (widget.profileA != null && widget.profileB != null)
            Row(
              children: [
                Expanded(child: _ProfileMini(user: widget.profileA!, chosen: _chosen == widget.profileA!.uid, onTap: () => _pick(widget.profileA!.uid))),
                const SizedBox(width: 8),
                Expanded(child: _ProfileMini(user: widget.profileB!, chosen: _chosen == widget.profileB!.uid, onTap: () => _pick(widget.profileB!.uid))),
              ],
            ),
          if (_chosen != null) ...[
            const SizedBox(height: AppSizes.sm),
            Center(
              child: Text(
                'Choice recorded ✓',
                style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PostMini extends StatelessWidget {
  final PostModel post;
  final bool chosen;
  final VoidCallback onTap;
  const _PostMini({required this.post, required this.chosen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: chosen ? primary : Colors.grey.shade300,
            width: chosen ? 2 : 1,
          ),
          color: chosen ? primary.withValues(alpha: 0.08) : AppColors.surfaceColor(isDigital),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.type == PostType.image)
              Container(
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: Center(child: Icon(Icons.image_outlined, color: Colors.grey.shade400)),
              ),
            const SizedBox(height: 6),
            Text(
              post.authorName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              post.content,
              style: const TextStyle(fontSize: 11, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 12, color: AppColors.tradGold),
                const SizedBox(width: 2),
                Text(post.ratingAvg.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
            if (chosen)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Icon(Icons.check_circle_rounded, color: primary, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMini extends StatelessWidget {
  final UserModel user;
  final bool chosen;
  final VoidCallback onTap;
  const _ProfileMini({required this.user, required this.chosen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: chosen ? primary : Colors.grey.shade300,
            width: chosen ? 2 : 1,
          ),
          color: chosen ? primary.withValues(alpha: 0.08) : AppColors.surfaceColor(isDigital),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: primary,
              child: Text(
                user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user.displayName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '@${user.username}',
              style: TextStyle(fontSize: 10, color: AppColors.textSubFor(isDigital)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 12, color: AppColors.tradGold),
                const SizedBox(width: 2),
                Text(user.ratingAvgLifetime.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
            if (chosen)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.check_circle_rounded, color: primary, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
