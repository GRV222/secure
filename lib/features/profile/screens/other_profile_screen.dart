import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/subscribe_button.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/post_model.dart';
import '../../../services/firestore_service.dart';
import '../providers/profile_provider.dart';

class OtherProfileScreen extends StatefulWidget {
  final String uid;
  const OtherProfileScreen({super.key, required this.uid});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile(widget.uid);
      _checkSubscription();
    });
  }

  Future<void> _checkSubscription() async {
    final myUid = context.read<AuthProvider>().currentUser?.uid;
    if (myUid == null) return;
    final subscribed = await FirestoreService().isSubscribed(
      subscriberUid: myUid,
      targetUid: widget.uid,
    );
    if (mounted) setState(() => _isSubscribed = subscribed);
  }

  Future<void> _toggleSubscribe() async {
    final myUid = context.read<AuthProvider>().currentUser?.uid;
    if (myUid == null) return;
    try {
      final nowSubscribed = await FirestoreService().toggleSubscribe(
        subscriberUid: myUid,
        targetUid: widget.uid,
      );
      if (mounted) setState(() => _isSubscribed = nowSubscribed);
    } catch (e) {
      debugPrint('toggleSubscribe error: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _fmtCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  void _sendMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request sent! They'll be notified")),
    );
  }

  void _report(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reported')),
    );
  }

  void _block(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Blocked')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
    final profileUser = profileProv.profileUser;
    final posts = profileProv.userPosts;

    final name = profileUser?.displayName ?? 'Unknown User';
    final username = profileUser?.username ?? widget.uid;
    final bio = profileUser?.bio ?? '';
    final identities = profileUser?.identityHashtags ?? [];
    final categories = profileUser?.followedCategoryHashtags ?? [];
    final rating = profileUser?.ratingAvgLifetime ?? 0.0;
    final wins = profileUser?.competitionWins ?? 0;
    final daGiven = profileUser?.totalDaDonated ?? 0.0;
    final pastUsernames = profileUser?.pastUsernames ?? [];
    final showSubscribe = profileUser?.hasSubscribeButton ?? false;
    final subscriberCount = profileUser?.subscriberCount ?? 0;

    if (profileProv.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('@${widget.uid}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        title: Text('@$username', style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'report') _report(context);
              if (v == 'block') _block(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'report', child: Text('Report')),
              PopupMenuItem(value: 'block', child: Text('Block')),
            ],
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, 0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: primary,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.white, fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('@$username', style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 14)),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(bio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                  ],
                  const SizedBox(height: AppSizes.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat(label: 'Rating', value: rating.toStringAsFixed(1), icon: '⭐'),
                      _Stat(label: 'Wins', value: '$wins', icon: '🏆'),
                      _Stat(label: 'DA Given', value: daGiven.toStringAsFixed(0), icon: '💚'),
                      if (showSubscribe)
                        _Stat(label: 'Subscribers', value: _fmtCount(subscriberCount), icon: '👥'),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  if (showSubscribe) ...[
                    SubscribeButton(
                      isSubscribed: _isSubscribed,
                      isDigital: isDigital,
                      onTap: _toggleSubscribe,
                    ),
                    const SizedBox(height: AppSizes.sm),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _sendMessage(context),
                      icon: const Icon(Icons.message_outlined, size: 16),
                      label: const Text('Send Message'),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
              ),
            ),
          ),
          if (identities.isNotEmpty)
            SliverToBoxAdapter(child: _buildIdentitiesSection(identities)),
          if (categories.isNotEmpty)
            SliverToBoxAdapter(child: _buildCategoriesSection(context, categories)),
          if (pastUsernames.isNotEmpty)
            SliverToBoxAdapter(child: _buildPastUsernamesSection(pastUsernames)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [Tab(text: 'Posts'), Tab(text: 'Info')],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _PostsGrid(posts: posts),
            _buildInfoTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentitiesSection(List<String> identities) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return _Section(
      title: 'Identities',
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: identities
            .map((id) => _HashChip(label: '#$id', color: AppColors.adaptivePrimary(isDigital)))
            .toList(),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, List<String> categories) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return _Section(
      title: 'Category Fields',
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: categories
            .map((c) => GestureDetector(
                  onTap: () => context.push('/hashtag/$c'),
                  child: _HashChip(label: '#$c', color: AppColors.adaptivePrimary(isDigital)),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPastUsernamesSection(List<String> pastUsernames) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    return _Section(
      title: 'Past Usernames',
      child: Text(
        pastUsernames.join(', '),
        style: TextStyle(fontSize: 12, color: AppColors.textSubFor(isDigital)),
      ),
    );
  }

  Widget _buildInfoTab() {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: primary.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Accountability on SECURE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Text(
                'Past usernames are visible to all users. This ensures accountability and builds trust in the community.',
                style: TextStyle(fontSize: 13, color: AppColors.textSubFor(isDigital), height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stat ──────────────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _Stat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$icon $value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital), fontSize: 12)),
      ],
    );
  }
}

// ─── Posts Grid ────────────────────────────────────────────────────────────────

class _PostsGrid extends StatelessWidget {
  final List<PostModel> posts;
  const _PostsGrid({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      final isDigital = context.watch<ThemeProvider>().isDigital;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_library_outlined, size: 48, color: AppColors.textSubFor(isDigital)),
              const SizedBox(height: 12),
              Text(
                'No posts yet',
                style: TextStyle(
                  color: AppColors.textSubFor(isDigital),
                  fontFamily: 'CormorantGaramond',
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => context.push('/post/${posts[i].postId}'),
        child: Container(
          color: Colors.grey.shade200,
          child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 28),
        ),
      ),
    );
  }
}

// ─── Shared ────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          child,
          const SizedBox(height: AppSizes.md),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

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
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
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
    return Material(color: Theme.of(context).scaffoldBackgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
