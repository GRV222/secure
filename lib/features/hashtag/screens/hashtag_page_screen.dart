import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/post_card_widget.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/hashtag_model.dart';
import '../../../models/post_model.dart';

class HashtagPageScreen extends StatefulWidget {
  final String hashtagName;
  const HashtagPageScreen({super.key, required this.hashtagName});

  @override
  State<HashtagPageScreen> createState() => _HashtagPageScreenState();
}

class _HashtagPageScreenState extends State<HashtagPageScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isFollowing = false;

  HashtagModel? get _hashtag {
    try {
      return DummyData.dummyHashtags
          .firstWhere((h) => h.name == widget.hashtagName);
    } catch (_) {
      return null;
    }
  }

  List<PostModel> get _hashtagPosts => DummyData.dummyPosts
      .where((p) => p.hashtags.contains(widget.hashtagName))
      .toList();

  List<PostModel> get _topRated {
    final posts = List<PostModel>.from(_hashtagPosts);
    posts.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
    return posts;
  }

  List<PostModel> get _latest {
    final posts = List<PostModel>.from(_hashtagPosts);
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  bool get _isCompetition => _hashtag?.isCompetitionTag == true;

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AuthProvider>().currentUser;
    _isFollowing = currentUser?.followedHashtags
        .contains(widget.hashtagName) ?? false;
    _tabController = TabController(
      length: _isCompetition ? 3 : 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final hashtag = _hashtag;
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            forceElevated: innerBoxIsScrolled,
            title: Text(
              '#${widget.hashtagName}',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.sm),
                  _buildBadgeRow(hashtag),
                  const SizedBox(height: AppSizes.sm),
                  _buildStats(hashtag),
                  if (_isCompetition) ...[
                    const SizedBox(height: AppSizes.sm),
                    _buildCompetitionBadge(),
                  ],
                  const SizedBox(height: AppSizes.md),
                  _buildActionRow(),
                  const SizedBox(height: AppSizes.sm),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: [
                  const Tab(text: 'Top Rated'),
                  const Tab(text: 'Latest'),
                  if (_isCompetition) const Tab(text: 'Competition'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _PostList(posts: _topRated),
            _PostList(posts: _latest, showAutoSplit: (hashtag?.postCount ?? 0) > 500),
            if (_isCompetition) _CompetitionTab(hashtag: hashtag!, topPosts: _topRated),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeRow(HashtagModel? hashtag) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final categoryLabel = hashtag?.category == 'digital' ? 'Digital' : 'Traditional';

    final postCount = hashtag?.postCount ?? 0;
    final String powerEmoji;
    final String powerLabel;
    if (postCount >= 1000) {
      powerEmoji = '⚡';
      powerLabel = 'Established';
    } else if (postCount >= 100) {
      powerEmoji = '🔥';
      powerLabel = 'Rising';
    } else {
      powerEmoji = '🌱';
      powerLabel = 'Emerging';
    }

    return Wrap(
      spacing: AppSizes.sm,
      children: [
        _Pill(label: categoryLabel, color: primary),
        _Pill(label: '$powerEmoji $powerLabel', color: AppColors.textSubFor(isDigital)),
      ],
    );
  }

  Widget _buildStats(HashtagModel? hashtag) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return Row(
      children: [
        Text(
          '${_formatCount(hashtag?.postCount ?? 0)} posts',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(width: AppSizes.md),
        Text(
          '${_formatCount(hashtag?.followerCount ?? 0)} followers',
          style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCompetitionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 14, color: AppColors.gold),
          SizedBox(width: 4),
          Text(
            'Active Competition',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            style: _isFollowing
                ? FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: primary,
                    side: BorderSide(color: primary),
                  )
                : null,
            onPressed: () => setState(() => _isFollowing = !_isFollowing),
            child: Text(_isFollowing ? 'Following' : 'Follow'),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.push(RouteNames.createPost),
            child: const Text('Post Here'),
          ),
        ),
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _PostList extends StatelessWidget {
  final List<PostModel> posts;
  final bool showAutoSplit;
  const _PostList({required this.posts, this.showAutoSplit = false});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Text(
            'No posts yet. Be the first to post with this hashtag!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital)),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: posts.length + (showAutoSplit ? 1 : 0),
      itemBuilder: (context, i) {
        if (showAutoSplit && i == posts.length) {
          return _AutoSplitCard();
        }
        return PostCardWidget(
          post: posts[i],
          onTap: () => context.push('/post/${posts[i].postId}'),
        );
      },
    );
  }
}

class _CompetitionTab extends StatelessWidget {
  final HashtagModel hashtag;
  final List<PostModel> topPosts;
  const _CompetitionTab({required this.hashtag, required this.topPosts});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🏆 Active Competition',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Rating period: until 25th May',
                style: TextStyle(color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital), fontSize: 13),
              ),
              const SizedBox(height: AppSizes.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push(RouteNames.leaderboard),
                  child: const Text('View Leaderboard'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        const Text(
          'Top 3 Posts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: AppSizes.sm),
        ...List.generate(topPosts.take(3).length, (i) {
          final post = topPosts[i];
          final medals = [AppColors.gold, AppColors.silver, AppColors.bronze];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: medals[i].withValues(alpha: 0.2),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  color: medals[i],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              post.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 14, color: AppColors.star),
                const SizedBox(width: 2),
                Text(post.ratingAvg.toStringAsFixed(1)),
              ],
            ),
          );
        }),
        const SizedBox(height: AppSizes.md),
        OutlinedButton(
          onPressed: () => context.push(RouteNames.leaderboard),
          child: const Text('View Full Leaderboard'),
        ),
      ],
    );
  }
}

class _AutoSplitCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 Growing fast!', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSizes.xs),
          Text(
            'When one style dominates 40% of posts, SECURE creates a focused competition.',
            style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
