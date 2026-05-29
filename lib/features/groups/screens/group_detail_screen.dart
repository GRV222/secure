import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../models/post_model.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  GroupModel get _group => DummyData.dummyGroups.firstWhere((g) => g.id == groupId);

  CharityPoolModel? get _pool =>
      DummyData.dummyPools.where((p) => p.groupId == groupId).firstOrNull;

  List<PostModel> get _groupPosts => DummyData.dummyPosts
      .where((p) => _group.memberIds.contains(p.uid))
      .toList();

  static const _memberNames = {
    'user_001': ('Gaurav Bathia', 'GB'),
    'user_002': ('Priya Sharma', 'PS'),
    'user_003': ('Arjun Mehta', 'AM'),
    'user_004': ('Kavya Nair', 'KN'),
    'user_005': ('Rohit Verma', 'RV'),
    'user_006': ('Sneha Patel', 'SP'),
  };

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final group = _group;
    final pool = _pool;
    final posts = _groupPosts;
    final color = AppColors.adaptivePrimary(isDigital);
    final isTraditional = group.category == 'traditional';
    final approaching50 = !group.isCommunity && group.memberCount >= 40 && group.memberCount < 50;

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${group.memberCount} members', style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital))),
          ],
        ),
        titleSpacing: 0,
        actions: [
          if (group.isCommunity)
            Container(
              margin: const EdgeInsets.only(right: AppSizes.md),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_outlined, size: 14, color: AppColors.gold),
                  SizedBox(width: 4),
                  Text('Community', style: TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Approaching-50 banner ──────────────────────────────────────
          if (approaching50)
            Container(
              margin: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, 0),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Almost a Community! ${group.memberCount}/50 members — auto-converts at 50',
                      style: const TextStyle(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSizes.md),

          // ── Description ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _HashChip(label: '#${group.identityHashtag}', color: color),
                    const SizedBox(width: 8),
                    _HashChip(
                      label: isTraditional ? 'Traditional' : 'Digital',
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                Text(group.description, style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSubFor(isDigital))),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const Divider(),

          // ── Charity Pool ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Active Charity Pool', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: AppSizes.sm),
                if (pool != null)
                  _PoolCard(pool: pool, onTap: () => context.push('/groups/pool/${pool.id}'))
                else
                  _NoPoolCard(),
              ],
            ),
          ),
          const Divider(),

          // ── Members ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Members (${group.memberCount})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Full member list — coming soon')),
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: group.memberIds.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final uid = group.memberIds[i];
                      final info = _memberNames[uid];
                      final initials = info?.$2 ?? '?';
                      final name = info?.$1.split(' ').first ?? 'User';
                      final isCurrentUser = uid == 'user_001';
                      return Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? color.withValues(alpha: 0.2)
                                  : color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: isCurrentUser
                                  ? Border.all(color: color, width: 2)
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isCurrentUser ? 'You' : name,
                            style: TextStyle(
                              fontSize: 10,
                              color: isCurrentUser ? color : AppColors.textSubFor(isDigital),
                              fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // ── Group Posts ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Group Posts (${posts.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: AppSizes.sm),
                if (posts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
                    child: Center(child: Text('No posts yet', style: TextStyle(color: AppColors.textSubFor(isDigital)))),
                  )
                else
                  for (final post in posts) _CompactPostCard(post: post),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

// ── Pool Card ────────────────────────────────────────────────────────────────

class _PoolCard extends StatelessWidget {
  final CharityPoolModel pool;
  final VoidCallback onTap;
  const _PoolCard({required this.pool, required this.onTap});

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    final pct = (pool.raisedDA / pool.targetDA).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite_outline, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pool.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text('Active', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 7,
                backgroundColor: AppColors.success.withValues(alpha: 0.12),
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_fmt(pool.raisedDA)} / ${_fmt(pool.targetDA)} DA raised',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${(pct * 100).round()}%',
                  style: const TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onTap,
                style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                icon: const Icon(Icons.volunteer_activism, size: 16),
                label: const Text('Donate DA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoPoolCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.textSubFor(isDigital).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.add_circle_outline, size: 32, color: AppColors.textSubFor(isDigital)),
          const SizedBox(height: 8),
          Text('No active pool yet', style: TextStyle(color: AppColors.textSubFor(isDigital))),
          const SizedBox(height: AppSizes.sm),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Create Pool — coming in Phase 2')),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Create Charity Pool'),
          ),
        ],
      ),
    );
  }
}

// ── Compact post card ────────────────────────────────────────────────────────

class _CompactPostCard extends StatelessWidget {
  final PostModel post;
  const _CompactPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return GestureDetector(
      onTap: () => context.push('/post/${post.postId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.textSubFor(isDigital).withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                post.authorName[0].toUpperCase(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primary),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(
                    post.content,
                    style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('⭐ ${post.ratingAvg.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('${post.ratingCount}', style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hash Chip ────────────────────────────────────────────────────────────────

class _HashChip extends StatelessWidget {
  final String label;
  final Color color;
  const _HashChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
