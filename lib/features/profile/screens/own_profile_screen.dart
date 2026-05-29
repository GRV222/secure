import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/profile_growth_ring.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/post_model.dart';
import '../../../models/journey_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/storage_service.dart';


class OwnProfileScreen extends StatefulWidget {
  const OwnProfileScreen({super.key});

  @override
  State<OwnProfileScreen> createState() => _OwnProfileScreenState();
}

class _OwnProfileScreenState extends State<OwnProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _changeProfilePhoto() async {
    final file = await _storageService.pickImageFromGallery();
    if (file == null || !mounted) return;
    final auth = context.read<AuthProvider>();
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final url = await _storageService.uploadProfilePhoto(uid: uid, imageFile: file);
      await _firestoreService.updateUser(uid, {'photoURL': url});
      if (mounted) await auth.initialize();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update photo. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return Scaffold(backgroundColor: AppColors.bg(isDigital), body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.bg(isDigital),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded,
                color: AppColors.adaptivePrimary(isDigital)),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text('@${user.username}', style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RouteNames.settings),
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ProfileGrowthRing(
                        ratingAvg: user.ratingAvgLifetime,
                        competitionWins: user.competitionWins,
                        daGiven: user.totalDaDonated,
                        postCount: 0,
                        size: 90,
                        child: user.photoURL?.isNotEmpty == true
                            ? CircleAvatar(
                                radius: 45,
                                backgroundImage:
                                    CachedNetworkImageProvider(user.photoURL!),
                              )
                            : CircleAvatar(
                                radius: 45,
                                backgroundColor:
                                    AppColors.adaptivePrimary(isDigital),
                                child: Text(
                                  user.displayName.isNotEmpty
                                      ? user.displayName[0].toUpperCase()
                                      : 'G',
                                  style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 2,
                        left: 4,
                        child: GestureDetector(
                          onTap: _changeProfilePhoto,
                          child: CircleAvatar(
                            radius: 13,
                            backgroundColor:
                                AppColors.adaptivePrimary(isDigital),
                            child:
                                const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(user.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('@${user.username}', style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 14)),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(user.bio!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSubFor(isDigital)),
                      const SizedBox(width: 3),
                      Text('Porbandar, India', style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [user.professionalRole, user.artisticRole].whereType<String>().join(' • '),
                    style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 13),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat(label: 'Rating', value: user.ratingAvgLifetime.toStringAsFixed(1), icon: '⭐'),
                      _Stat(label: 'Wins', value: '${user.competitionWins}', icon: '🏆'),
                      _Stat(label: 'DA Given', value: user.totalDaDonated.toStringAsFixed(0), icon: '💚'),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _WalletPreview(user: user)),
          SliverToBoxAdapter(child: _IdentitiesSection(user: user)),
          SliverToBoxAdapter(child: _FieldsFollowedSection(user: user)),
          SliverToBoxAdapter(child: _PostedInSection(user: user)),
          SliverToBoxAdapter(child: _JourneysSection(uid: user.uid)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [Tab(text: 'Posts'), Tab(text: 'Saved'), Tab(text: 'Groups')],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _RealPostsGrid(uid: user.uid),
            _RealSavedPostsGrid(savedPostIds: user.savedPosts),
            _RealGroupsList(uid: user.uid),
          ],
        ),
      ),
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

// ─── Wallet Preview ────────────────────────────────────────────────────────────

class _WalletPreview extends StatelessWidget {
  final dynamic user;
  const _WalletPreview({required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.wallet),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital), AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital).withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TokenChip(symbol: 'SHREE', amount: user.shreeCoinBalance),
                Container(width: 1, height: 28, color: AppColors.white.withValues(alpha: 0.3)),
                _TokenChip(symbol: 'DA', amount: user.daCoinBalance),
                Container(width: 1, height: 28, color: AppColors.white.withValues(alpha: 0.3)),
                _TokenChip(symbol: 'SHREEDA', amount: user.shreedaBalance),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to view wallet →',
              style: TextStyle(color: AppColors.white.withValues(alpha: 0.75), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenChip extends StatelessWidget {
  final String symbol;
  final double amount;
  const _TokenChip({required this.symbol, required this.amount});

  @override
  Widget build(BuildContext context) {
    final display = amount % 1 == 0 ? amount.toInt().toString() : amount.toStringAsFixed(1);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 11, color: AppColors.white.withValues(alpha: 0.8)),
            const SizedBox(width: 3),
            Text(display, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
        Text(symbol, style: TextStyle(color: AppColors.white.withValues(alpha: 0.75), fontSize: 10)),
      ],
    );
  }
}

// ─── Identities Section ────────────────────────────────────────────────────────

class _IdentitiesSection extends StatelessWidget {
  final dynamic user;
  const _IdentitiesSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'My Identities',
      action: Icon(Icons.edit_outlined, size: 16, color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital)),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          ...user.identityHashtags.map<Widget>((tag) => _HashChip(label: '#$tag', color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital))),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                border: Border.all(color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital).withValues(alpha: 0.4)),
              ),
              child: Text('+ Add Identity', style: TextStyle(fontSize: 12, color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital))),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fields Followed Section ───────────────────────────────────────────────────

class _FieldsFollowedSection extends StatelessWidget {
  final dynamic user;
  const _FieldsFollowedSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Fields I Follow',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((user.followedIdentityHashtags as List).isNotEmpty) ...[
            Text('Identity fields', style: TextStyle(fontSize: 11, color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital).withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: (user.followedIdentityHashtags as List<String>)
                  .map((tag) => GestureDetector(
                        onTap: () => context.push('/hashtag/$tag'),
                        child: _HashChip(label: '#$tag', color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
          if ((user.followedCategoryHashtags as List).isNotEmpty) ...[
            Text('Category fields', style: TextStyle(fontSize: 11, color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital).withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: (user.followedCategoryHashtags as List<String>)
                  .map((tag) => GestureDetector(
                        onTap: () => context.push('/hashtag/$tag'),
                        child: _HashChip(label: '#$tag', color: AppColors.adaptivePrimary(context.watch<ThemeProvider>().isDigital)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
          GestureDetector(
            onTap: () => context.push(RouteNames.explore),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                border: Border.all(color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital).withValues(alpha: 0.4)),
              ),
              child: Text('+ Explore Fields', style: TextStyle(fontSize: 12, color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital))),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Posted In Section ─────────────────────────────────────────────────────────

class _PostedInSection extends StatelessWidget {
  final dynamic user;
  const _PostedInSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final tags = user.postedInHashtags as List<String>;
    if (tags.isEmpty) return const SizedBox.shrink();

    final counts = <String, int>{};
    for (final tag in tags) {
      counts[tag] = (counts[tag] ?? 0) + 1;
    }

    final isDigital = context.watch<ThemeProvider>().isDigital;
    return _Section(
      title: 'Posted In',
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: counts.entries.map((e) {
          return GestureDetector(
            onTap: () => context.push('/hashtag/${e.key}'),
            child: _HashChip(label: '#${e.key}  ×${e.value}', color: AppColors.adaptivePrimary(isDigital)),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Journeys Section ─────────────────────────────────────────────────────────

class _JourneysSection extends StatefulWidget {
  final String uid;
  const _JourneysSection({required this.uid});
  @override
  State<_JourneysSection> createState() => _JourneysSectionState();
}

class _JourneysSectionState extends State<_JourneysSection> {
  List<JourneyModel> _journeys = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final journeys = await FirestoreService().getUserJourneys(widget.uid);
      if (mounted) setState(() { _journeys = journeys; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_journeys.isEmpty) return const SizedBox.shrink();

    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    return _Section(
      title: 'My Journeys',
      action: GestureDetector(
        onTap: () => context.push(RouteNames.createJourney),
        child: Icon(Icons.add, size: 18, color: primary),
      ),
      child: Column(
        children: _journeys.map((j) {
          return GestureDetector(
            onTap: () => context.push(RouteNames.journeyDetail, extra: j),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_stories_outlined, color: primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(j.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text('${j.dayCount} days · ${j.isActive ? "Active" : "Completed"}',
                            style: TextStyle(color: AppColors.textSubFor(isDigital), fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textSubFor(isDigital), size: 18),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Real Posts Grid ───────────────────────────────────────────────────────────

class _RealPostsGrid extends StatefulWidget {
  final String uid;
  const _RealPostsGrid({required this.uid});
  @override
  State<_RealPostsGrid> createState() => _RealPostsGridState();
}

class _RealPostsGridState extends State<_RealPostsGrid> {
  List<PostModel> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final posts = await FirestoreService().getUserPosts(widget.uid);
      if (mounted) setState(() { _posts = posts; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Text('No posts yet', style: TextStyle(color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital))),
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2,
      ),
      itemCount: _posts.length,
      itemBuilder: (_, i) {
        final post = _posts[i];
        return GestureDetector(
          onTap: () => context.push('/post/${post.postId}'),
          child: Container(
            color: Colors.grey.shade200,
            child: (post.mediaURL ?? '').isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: post.mediaURL!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1.5))),
                    ),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 28),
                  )
                : Icon(
                    post.type.name == 'text' ? Icons.text_fields : Icons.image_outlined,
                    color: Colors.grey.shade400,
                    size: 28,
                  ),
          ),
        );
      },
    );
  }
}

// ─── Real Saved Posts Grid ─────────────────────────────────────────────────────

class _RealSavedPostsGrid extends StatefulWidget {
  final List<String> savedPostIds;
  const _RealSavedPostsGrid({required this.savedPostIds});
  @override
  State<_RealSavedPostsGrid> createState() => _RealSavedPostsGridState();
}

class _RealSavedPostsGridState extends State<_RealSavedPostsGrid> {
  List<PostModel> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final svc = FirestoreService();
      final futures = widget.savedPostIds.map((id) => svc.getPost(id));
      final results = await Future.wait(futures);
      final posts = results.whereType<PostModel>().toList();
      if (mounted) setState(() { _posts = posts; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Text('No saved posts', style: TextStyle(color: AppColors.textSubFor(context.watch<ThemeProvider>().isDigital))),
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2,
      ),
      itemCount: _posts.length,
      itemBuilder: (_, i) {
        final post = _posts[i];
        return GestureDetector(
          onTap: () => context.push('/post/${post.postId}'),
          child: Container(
            color: Colors.grey.shade200,
            child: (post.mediaURL ?? '').isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: post.mediaURL!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1.5))),
                    ),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 28),
                  )
                : Icon(
                    post.type.name == 'text' ? Icons.text_fields : Icons.image_outlined,
                    color: Colors.grey.shade400,
                    size: 28,
                  ),
          ),
        );
      },
    );
  }
}

// ─── Shared widgets ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const _Section({required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              if (action != null) ...[const Spacer(), action!],
            ],
          ),
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

// ─── Real Groups List ──────────────────────────────────────────────────────────

class _RealGroupsList extends StatefulWidget {
  final String uid;
  const _RealGroupsList({required this.uid});
  @override
  State<_RealGroupsList> createState() => _RealGroupsListState();
}

class _RealGroupsListState extends State<_RealGroupsList> {
  List<Map<String, dynamic>> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final groups = await FirestoreService().getUserGroups(widget.uid);
      if (mounted) setState(() { _groups = groups; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    if (_groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined, size: 40, color: AppColors.textSubFor(isDigital)),
            const SizedBox(height: AppSizes.sm),
            Text('No groups yet', style: TextStyle(color: AppColors.textSubFor(isDigital))),
            const SizedBox(height: AppSizes.sm),
            OutlinedButton(
              onPressed: () => context.push(RouteNames.groups),
              child: const Text('Browse Groups'),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My Groups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            GestureDetector(
              onTap: () => context.push(RouteNames.groups),
              child: Text('See All →', style: TextStyle(fontSize: 13, color: primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        for (final g in _groups) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: primary,
              child: Text(
                ((g['name'] as String?) ?? 'G')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(g['name'] ?? ''),
            subtitle: Text('${g['memberCount'] ?? 0} members'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSubFor(isDigital)),
            onTap: () => context.push('/groups/${g['id']}'),
          ),
          const SizedBox(height: AppSizes.sm),
        ],
      ],
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
